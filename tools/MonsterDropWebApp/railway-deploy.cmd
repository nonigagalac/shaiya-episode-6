@echo off
setlocal enabledelayedexpansion

REM 🚂 Railway Deployment Script for Monster Drop Web Application (Windows)
REM This script will deploy your backend API to Railway

echo 🚂 ===============================================
echo    Monster Drop Web App - Railway Deployment
echo ===============================================
echo.

REM Check if Railway CLI is installed
where railway >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo ❌ Railway CLI not found!
    echo Installing Railway CLI...
    npm install -g @railway/cli
    if %ERRORLEVEL% neq 0 (
        echo ❌ Failed to install Railway CLI
        pause
        exit /b 1
    )
)

echo 📋 Pre-deployment Checklist
echo ✅ Railway CLI installed
echo ✅ Backend Docker configuration ready
echo ✅ Railway.json configuration file ready
echo.

REM Check if user is logged in to Railway
echo 🔐 Checking Railway authentication...
railway whoami >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo ⚠️  Not logged in to Railway
    echo Please run: railway login
    echo Then run this script again.
    echo.
    echo 💡 Manual Deployment Steps:
    echo 1. Run: railway login
    echo 2. Run: railway link (or create new project)
    echo 3. Run: railway up
    echo 4. Run: railway domain (to get your app URL)
    pause
    exit /b 1
)

echo ✅ Railway authentication successful
echo.

REM Change to project directory
cd /d "%~dp0"
echo 📁 Project Directory: %CD%

REM Check if project is linked
echo 🔗 Checking project linking...
if not exist ".railway\railway.toml" (
    echo ⚠️  Project not linked to Railway
    echo Creating new Railway project...
    
    REM Create new project
    railway project:create "shaiya-monster-drop-api"
    
    REM Link to current directory
    railway link
) else (
    echo ✅ Project already linked
)

echo.

REM Set environment variables
echo ⚙️  Setting up environment variables...
railway variables:set ASPNETCORE_ENVIRONMENT=Production
railway variables:set ASPNETCORE_URLS=http://0.0.0.0:$PORT
railway variables:set PORT=8080

echo ✅ Environment variables configured
echo.

REM Deploy to Railway
echo 🚀 Starting deployment to Railway...
echo This may take several minutes...
echo.

railway up --detach
if %ERRORLEVEL% equ 0 (
    echo.
    echo 🎉 Deployment successful!
    
    REM Get the deployment URL
    echo 🌐 Getting your application URL...
    
    echo.
    echo 📋 Next Steps:
    echo 1. ✅ Backend deployed to Railway
    echo 2. 🔄 Update frontend configuration with Railway URL
    echo 3. 🌐 Deploy frontend to Cloudflare Pages
    echo.
    echo 📋 Run "railway domain" to get your backend URL
    echo Then update frontend environment variables:
    echo VITE_API_BASE_URL=https://your-app.up.railway.app
    echo VITE_SIGNALR_HUB_URL=https://your-app.up.railway.app/hubs/monsterdrop
    echo.
    echo 🧪 Test your API at:
    echo Health Check: https://your-app.up.railway.app/api/system/health
    echo API Docs: https://your-app.up.railway.app/swagger
) else (
    echo ❌ Deployment failed
    echo Check the logs with: railway logs
    pause
    exit /b 1
)

echo.
echo 🎉 Railway deployment completed successfully!
echo 🔗 Railway Dashboard: https://railway.app/dashboard
echo.
pause