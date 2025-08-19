#!/bin/bash

# Shaiya Monster Drop Web App Deployment Script
# This script builds and deploys both frontend and backend

set -e  # Exit on any error

echo "🚀 Deploying Shaiya Monster Drop Web Application..."

# Check if required tools are installed
check_dependencies() {
    echo "📋 Checking dependencies..."
    
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js is required but not installed."
        echo "Please install Node.js from: https://nodejs.org/"
        exit 1
    fi
    
    if ! command -v dotnet &> /dev/null; then
        echo "❌ .NET 8.0 SDK is required but not installed."
        echo "Please install .NET 8.0 SDK from: https://dotnet.microsoft.com/download"
        exit 1
    fi
    
    echo "✅ All dependencies are installed."
}

# Build frontend
build_frontend() {
    echo "🏗️ Building frontend..."
    cd Frontend
    
    # Install dependencies
    echo "📦 Installing frontend dependencies..."
    npm install
    
    # Build for production
    echo "🔨 Building frontend for production..."
    npm run build
    
    # Copy deployment files
    cp _headers dist/
    cp _redirects dist/
    
    echo "✅ Frontend build completed."
    cd ..
}

# Build backend
build_backend() {
    echo "🏗️ Building backend..."
    cd Backend
    
    # Restore dependencies
    echo "📦 Restoring backend dependencies..."
    dotnet restore
    
    # Build for production
    echo "🔨 Building backend for production..."
    dotnet build --configuration Release
    
    # Publish
    echo "📦 Publishing backend..."
    dotnet publish --configuration Release --output ./publish
    
    echo "✅ Backend build completed."
    cd ..
}

# Deploy to Railway (Backend)
deploy_backend() {
    echo "🚀 Deploying backend to Railway..."
    
    if ! command -v railway &> /dev/null; then
        echo "⚠️ Railway CLI not found. Installing..."
        npm install -g @railway/cli
    fi
    
    # Login check
    if ! railway whoami &> /dev/null; then
        echo "🔐 Please login to Railway:"
        railway login
    fi
    
    echo "🚂 Deploying to Railway..."
    railway up
    
    echo "✅ Backend deployed to Railway."
}

# Deploy to Cloudflare Pages (Frontend)
deploy_frontend() {
    echo "🌐 Deploying frontend to Cloudflare Pages..."
    
    # Check if Wrangler is installed
    if ! command -v wrangler &> /dev/null; then
        echo "⚠️ Wrangler not found. Installing..."
        npm install -g wrangler
    fi
    
    # Login check
    if ! wrangler whoami &> /dev/null; then
        echo "🔐 Please login to Cloudflare:"
        wrangler login
    fi
    
    cd Frontend
    
    # Deploy to Cloudflare Pages
    echo "☁️ Deploying to Cloudflare Pages..."
    wrangler pages deploy dist --project-name=shaiya-monster-drop-editor
    
    echo "✅ Frontend deployed to Cloudflare Pages."
    cd ..
}

# Create Docker setup
create_docker_setup() {
    echo "🐳 Setting up Docker deployment..."
    
    # Build Docker images
    echo "🔨 Building Docker images..."
    docker-compose build
    
    echo "✅ Docker setup completed."
    echo "💡 To run locally with Docker: docker-compose up -d"
}

# Main deployment function
main() {
    echo "======================================"
    echo "🎮 Shaiya Monster Drop Web App Deploy"
    echo "======================================"
    
    check_dependencies
    
    # Build applications
    build_frontend
    build_backend
    
    # Create Docker setup
    create_docker_setup
    
    # Ask user what deployment method they prefer
    echo ""
    echo "🎯 Choose deployment method:"
    echo "1) Deploy to Cloud (Railway + Cloudflare Pages) - Recommended"
    echo "2) Docker setup only (for local/custom hosting)"
    echo "3) Skip deployment (build only)"
    read -r -p "Enter choice (1-3): " choice
    
    case $choice in
        1)
            echo "☁️ Deploying to cloud services..."
            deploy_backend
            
            # Get backend URL from Railway
            BACKEND_URL=$(railway status --json | grep -o '"url":"[^"]*' | cut -d'"' -f4)
            if [ -n "$BACKEND_URL" ]; then
                echo "🔧 Updating frontend API configuration..."
                # Update _redirects with actual backend URL
                sed -i.bak "s|https://shaiya-monsterdrop-api.railway.app|$BACKEND_URL|g" Frontend/_redirects
                
                # Rebuild frontend with updated config
                build_frontend
            fi
            
            deploy_frontend
            ;;
        2)
            echo "🐳 Docker setup completed. Use 'docker-compose up -d' to run."
            ;;
        3)
            echo "📦 Build completed. Deployment skipped."
            ;;
        *)
            echo "❌ Invalid choice. Exiting."
            exit 1
            ;;
    esac
    
    echo ""
    echo "======================================"
    echo "🎉 Deployment Summary"
    echo "======================================"
    
    if [ "$choice" = "1" ]; then
        echo "✅ Backend API: Deployed to Railway"
        echo "✅ Frontend: Deployed to Cloudflare Pages"
        echo ""
        echo "🌐 Your application URLs:"
        echo "   Frontend: https://shaiya-monster-drop-editor.pages.dev"
        if [ -n "$BACKEND_URL" ]; then
            echo "   Backend API: $BACKEND_URL"
        else
            echo "   Backend API: Check Railway dashboard for URL"
        fi
        echo ""
        echo "📋 Next steps:"
        echo "1. Test the application in your browser"
        echo "2. Configure any custom domains if needed"
        echo "3. Set up monitoring and alerts"
    elif [ "$choice" = "2" ]; then
        echo "🐳 Docker containers ready"
        echo "   Frontend: http://localhost:80"
        echo "   Backend API: http://localhost:8080"
        echo ""
        echo "🏃 To start: docker-compose up -d"
        echo "🛑 To stop: docker-compose down"
    fi
    
    echo ""
    echo "🔧 Configuration files created:"
    echo "   - Backend/Dockerfile"
    echo "   - docker-compose.yml"
    echo "   - railway.json"
    echo "   - Frontend/_headers"
    echo "   - Frontend/_redirects"
    echo ""
    echo "🎮 Your Shaiya Monster Drop Editor is ready!"
    echo "======================================"
}

# Run main function
main "$@"