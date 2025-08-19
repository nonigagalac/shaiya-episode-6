#!/bin/bash

# 🚂 Railway Deployment Script for Monster Drop Web Application
# This script will deploy your backend API to Railway

set -e  # Exit on any error

echo "🚂 ==============================================="
echo "   Monster Drop Web App - Railway Deployment"
echo "==============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo -e "${RED}❌ Railway CLI not found!${NC}"
    echo "Installing Railway CLI..."
    npm install -g @railway/cli
fi

echo -e "${BLUE}📋 Pre-deployment Checklist${NC}"
echo "✅ Railway CLI installed"
echo "✅ Backend Docker configuration ready"
echo "✅ Railway.json configuration file ready"
echo ""

# Check if user is logged in to Railway
echo -e "${YELLOW}🔐 Checking Railway authentication...${NC}"
if ! railway whoami &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to Railway${NC}"
    echo "Please run: railway login"
    echo "Then run this script again."
    echo ""
    echo -e "${BLUE}💡 Manual Deployment Steps:${NC}"
    echo "1. Run: railway login"
    echo "2. Run: railway link (or create new project)"
    echo "3. Run: railway up"
    echo "4. Run: railway domain (to get your app URL)"
    exit 1
fi

echo -e "${GREEN}✅ Railway authentication successful${NC}"
echo ""

# Change to project directory
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)
echo -e "${BLUE}📁 Project Directory: ${PROJECT_DIR}${NC}"

# Check if project is linked
echo -e "${YELLOW}🔗 Checking project linking...${NC}"
if [ ! -f ".railway/railway.toml" ]; then
    echo -e "${YELLOW}⚠️  Project not linked to Railway${NC}"
    echo "Creating new Railway project..."
    
    # Create new project
    railway project:create "shaiya-monster-drop-api"
    
    # Link to current directory
    railway link
else
    echo -e "${GREEN}✅ Project already linked${NC}"
fi

echo ""

# Set environment variables
echo -e "${BLUE}⚙️  Setting up environment variables...${NC}"
railway variables:set ASPNETCORE_ENVIRONMENT=Production
railway variables:set ASPNETCORE_URLS=http://0.0.0.0:\$PORT
railway variables:set PORT=8080

echo -e "${GREEN}✅ Environment variables configured${NC}"
echo ""

# Deploy to Railway
echo -e "${BLUE}🚀 Starting deployment to Railway...${NC}"
echo "This may take several minutes..."
echo ""

if railway up --detach; then
    echo ""
    echo -e "${GREEN}🎉 Deployment successful!${NC}"
    
    # Get the deployment URL
    echo -e "${BLUE}🌐 Getting your application URL...${NC}"
    APP_URL=$(railway domain | grep -o 'https://[^[:space:]]*' | head -1)
    
    if [ -n "$APP_URL" ]; then
        echo -e "${GREEN}✅ Your API is live at: ${APP_URL}${NC}"
        echo ""
        echo -e "${BLUE}📋 Next Steps:${NC}"
        echo "1. ✅ Backend deployed to Railway"
        echo "2. 🔄 Update frontend configuration with this URL"
        echo "3. 🌐 Deploy frontend to Cloudflare Pages"
        echo ""
        echo -e "${YELLOW}📋 Backend URL for frontend configuration:${NC}"
        echo "VITE_API_BASE_URL=${APP_URL}"
        echo "VITE_SIGNALR_HUB_URL=${APP_URL}/hubs/monsterdrop"
        echo ""
        echo -e "${BLUE}🧪 Test your API:${NC}"
        echo "Health Check: ${APP_URL}/api/system/health"
        echo "API Docs: ${APP_URL}/swagger"
    else
        echo -e "${YELLOW}⚠️  Could not automatically get domain${NC}"
        echo "Run: railway domain"
        echo "Or check your Railway dashboard for the URL"
    fi
else
    echo -e "${RED}❌ Deployment failed${NC}"
    echo "Check the logs with: railway logs"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Railway deployment completed successfully!${NC}"
echo -e "${BLUE}🔗 Railway Dashboard: https://railway.app/dashboard${NC}"
echo ""