@echo off
REM Shaiya Monster Drop Web App Deployment Script for Windows
REM This script builds and deploys both frontend and backend

echo 🚀 Deploying Shaiya Monster Drop Web Application...

REM Check dependencies
:check_dependencies
echo 📋 Checking dependencies...

node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is required but not installed.
    echo Please install Node.js from: https://nodejs.org/
    pause
    exit /b 1
)

dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ .NET 8.0 SDK is required but not installed.
    echo Please install .NET 8.0 SDK from: https://dotnet.microsoft.com/download
    pause
    exit /b 1
)

echo ✅ All dependencies are installed.

REM Build frontend
:build_frontend
echo 🏗️ Building frontend...
cd Frontend

echo 📦 Installing frontend dependencies...
call npm install
if %errorlevel% neq 0 (
    echo ❌ Frontend dependency installation failed
    pause
    exit /b 1
)

echo 🔨 Building frontend for production...
call npm run build
if %errorlevel% neq 0 (
    echo ❌ Frontend build failed
    pause
    exit /b 1
)

REM Copy deployment files
copy _headers dist\ >nul
copy _redirects dist\ >nul

echo ✅ Frontend build completed.
cd ..

REM Build backend
:build_backend
echo 🏗️ Building backend...
cd Backend

echo 📦 Restoring backend dependencies...
dotnet restore
if %errorlevel% neq 0 (
    echo ❌ Backend restore failed
    pause
    exit /b 1
)

echo 🔨 Building backend for production...
dotnet build --configuration Release
if %errorlevel% neq 0 (
    echo ❌ Backend build failed
    pause
    exit /b 1
)

echo 📦 Publishing backend...
dotnet publish --configuration Release --output ./publish
if %errorlevel% neq 0 (
    echo ❌ Backend publish failed
    pause
    exit /b 1
)

echo ✅ Backend build completed.
cd ..

REM Docker setup
:docker_setup
echo 🐳 Setting up Docker deployment...
docker --version >nul 2>&1
if %errorlevel% equ 0 (
    echo 🔨 Building Docker images...
    docker-compose build
    if %errorlevel% equ 0 (
        echo ✅ Docker setup completed.
    ) else (
        echo ⚠️ Docker build failed, but continuing...
    )
) else (
    echo ⚠️ Docker not found. Skipping Docker setup.
    echo Install Docker Desktop to enable container deployment.
)

REM Deployment options
:deployment_menu
echo.
echo ======================================"
echo 🎮 Shaiya Monster Drop Web App Deploy
echo ======================================
echo.
echo 🎯 Choose deployment method:
echo 1^) Manual deployment ^(build completed^)
echo 2^) Docker setup ^(if available^)
echo 3^) Show deployment URLs
echo 4^) Exit
echo.
set /p choice="Enter choice (1-4): "

if "%choice%"=="1" goto manual_deploy
if "%choice%"=="2" goto docker_deploy
if "%choice%"=="3" goto show_urls
if "%choice%"=="4" goto end
echo ❌ Invalid choice. Please try again.
goto deployment_menu

:manual_deploy
echo.
echo 📦 Manual Deployment Ready
echo ===========================
echo.
echo ✅ Frontend built: Frontend\dist\
echo    Ready for static hosting (Netlify, Vercel, Cloudflare Pages, etc.)
echo.
echo ✅ Backend built: Backend\publish\
echo    Ready for cloud hosting (Railway, Heroku, Azure, AWS, etc.)
echo.
echo 📋 Manual deployment steps:
echo 1. Deploy Backend:
echo    - Upload Backend\publish\ to your cloud provider
echo    - Set environment: ASPNETCORE_ENVIRONMENT=Production
echo    - Ensure port 8080 is exposed
echo.
echo 2. Deploy Frontend:
echo    - Upload Frontend\dist\ to static hosting
echo    - Update _redirects file with your backend URL
echo    - Configure custom domain if needed
echo.
echo 3. Update Configuration:
echo    - Update Frontend\_redirects with actual backend URL
echo    - Rebuild frontend if API URL changed
echo.
goto deployment_menu

:docker_deploy
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed or not running.
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    goto deployment_menu
)

echo.
echo 🐳 Docker Deployment
echo ====================
echo.
echo Starting containers...
docker-compose up -d
if %errorlevel% equ 0 (
    echo ✅ Application started successfully!
    echo.
    echo 🌐 Access URLs:
    echo    Frontend: http://localhost:80
    echo    Backend API: http://localhost:8080
    echo    API Docs: http://localhost:8080/swagger
    echo.
    echo 🛑 To stop: docker-compose down
) else (
    echo ❌ Failed to start containers.
    echo Check Docker Desktop is running and try again.
)
echo.
goto deployment_menu

:show_urls
echo.
echo 🌐 Deployment URLs and Services
echo ================================
echo.
echo 📋 Recommended Cloud Services:
echo.
echo Frontend Hosting:
echo    🔸 Cloudflare Pages: https://pages.cloudflare.com/
echo    🔸 Netlify: https://www.netlify.com/
echo    🔸 Vercel: https://vercel.com/
echo.
echo Backend Hosting:
echo    🔸 Railway: https://railway.app/
echo    🔸 Render: https://render.com/
echo    🔸 Heroku: https://www.heroku.com/
echo.
echo 🔧 Configuration Notes:
echo    - Backend needs Windows server for memory access
echo    - Frontend works on any static hosting
echo    - Update _redirects file with actual backend URL
echo.
goto deployment_menu

:end
echo.
echo ======================================
echo 🎉 Deployment Complete!
echo ======================================
echo.
echo 📁 Build Output:
echo    Frontend: Frontend\dist\
echo    Backend: Backend\publish\
echo.
echo 🐳 Docker: docker-compose.yml ready
echo.
echo 📖 Documentation: README.md
echo.
echo 🎮 Your Shaiya Monster Drop Editor is ready for deployment!
echo.
echo Thank you for using the deployment script!
echo ======================================
pause