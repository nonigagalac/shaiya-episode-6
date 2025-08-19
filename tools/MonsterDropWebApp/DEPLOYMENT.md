# 🚀 Deployment Guide - Shaiya Monster Drop Web Application

Your application is **production-ready** and can be deployed using multiple methods. Here are the complete deployment instructions:

## 📦 **What's Ready for Deployment**

✅ **Frontend**: Built and optimized for production (`Frontend/dist/`)
✅ **Backend**: .NET 8.0 API with Docker support (`Backend/`)
✅ **Docker**: Complete containerization setup (`docker-compose.yml`)
✅ **Configuration**: Production environment files and settings
✅ **Build Scripts**: Automated build and deployment scripts

---

## 🌐 **Method 1: Cloud Deployment (Recommended)**

### **Frontend → Cloudflare Pages**

1. **Go to [Cloudflare Pages](https://pages.cloudflare.com/)**

2. **Connect Your Repository**
   - Click "Create a project"
   - Connect to GitHub: `nonigagalac/shaiya-episode-6`
   - Select branch: `genspark_ai_developer`

3. **Configure Build Settings**
   ```
   Framework preset: None
   Build command: cd tools/MonsterDropWebApp/Frontend && npm install && npm run build
   Build output directory: tools/MonsterDropWebApp/Frontend/dist
   ```

4. **Environment Variables**
   ```
   VITE_API_BASE_URL=https://your-backend-url.up.railway.app
   VITE_SIGNALR_HUB_URL=https://your-backend-url.up.railway.app/hubs/monsterdrop
   ```

5. **Deploy**: Click "Save and Deploy"

### **Backend → Railway**

1. **Go to [Railway](https://railway.app/)**

2. **Deploy from GitHub**
   - Click "New Project" → "Deploy from GitHub repo"
   - Select: `nonigagalac/shaiya-episode-6`
   - Branch: `genspark_ai_developer`

3. **Configure Service**
   ```
   Root Directory: tools/MonsterDropWebApp/Backend
   Build Command: dotnet publish --configuration Release --output ./publish
   Start Command: dotnet MonsterDropWebAPI.dll
   ```

4. **Environment Variables**
   ```
   ASPNETCORE_ENVIRONMENT=Production
   ASPNETCORE_URLS=http://0.0.0.0:$PORT
   ```

5. **Deploy**: Railway will auto-deploy

---

## 🐳 **Method 2: Docker Deployment**

### **Local/Server Docker Deployment**

1. **Clone and Build**
   ```bash
   git clone https://github.com/nonigagalac/shaiya-episode-6.git
   cd shaiya-episode-6/tools/MonsterDropWebApp
   ```

2. **Run with Docker Compose**
   ```bash
   docker-compose up -d
   ```

3. **Access Your Application**
   - Frontend: http://localhost:80
   - Backend API: http://localhost:8080
   - Swagger Docs: http://localhost:8080/swagger

### **Production Docker (Server)**

1. **Update Production URLs**
   ```bash
   # Edit Frontend/_redirects with your server IP/domain
   /api/* https://your-server.com:8080/api/:splat 200
   /hubs/* https://your-server.com:8080/hubs/:splat 200
   ```

2. **Deploy to Server**
   ```bash
   # Copy files to server
   scp -r . user@your-server:/opt/shaiya-drop-editor/
   
   # On server
   cd /opt/shaiya-drop-editor
   docker-compose up -d
   ```

---

## 💻 **Method 3: Manual Deployment**

### **Frontend (Static Hosting)**

Deploy `Frontend/dist/` folder to any static hosting:

- **Netlify**: Drag & drop the `dist` folder
- **Vercel**: Connect GitHub repo with build settings
- **GitHub Pages**: Push `dist` contents to `gh-pages` branch
- **Any Web Server**: Upload files to web root

**Required Files in `dist/`:**
- `index.html` - Main app file
- `assets/` - JavaScript, CSS, and other assets
- `_headers` - Security headers configuration
- `_redirects` - SPA routing and API proxy rules

### **Backend (Cloud Hosting)**

Deploy `Backend/publish/` folder to any .NET hosting:

- **Azure App Service**: Deploy via Visual Studio or CLI
- **AWS Elastic Beanstalk**: Upload application package
- **Google Cloud Run**: Deploy as containerized app
- **DigitalOcean App Platform**: Connect GitHub repo

**Required Configuration:**
- Environment: `ASPNETCORE_ENVIRONMENT=Production`
- Port: Usually 8080 or assigned by platform
- Memory Access: Application needs Windows server for memory operations

---

## ⚙️ **Configuration Updates**

### **After Backend Deployment**

1. **Get your backend URL** (e.g., `https://your-app.up.railway.app`)

2. **Update Frontend Configuration**
   ```bash
   # Edit Frontend/_redirects
   /api/* https://your-backend-url/api/:splat 200
   /hubs/* https://your-backend-url/hubs/:splat 200
   ```

3. **Update Environment Variables**
   ```bash
   # Frontend .env.production
   VITE_API_BASE_URL=https://your-backend-url
   VITE_SIGNALR_HUB_URL=https://your-backend-url/hubs/monsterdrop
   ```

4. **Rebuild Frontend**
   ```bash
   cd Frontend
   npm run build
   # Redeploy the updated dist/ folder
   ```

### **Backend CORS Configuration**

Update `Backend/appsettings.Production.json`:
```json
{
  "Cors": {
    "AllowedOrigins": [
      "https://your-frontend-domain.pages.dev",
      "https://your-custom-domain.com"
    ]
  }
}
```

---

## 🔧 **Quick Deploy Scripts**

### **Windows (deploy.cmd)**
```cmd
cd tools\MonsterDropWebApp
deploy.cmd
```

### **Linux/Mac (deploy.sh)**
```bash
cd tools/MonsterDropWebApp
chmod +x deploy.sh
./deploy.sh
```

Both scripts will:
- ✅ Build frontend and backend
- ✅ Create Docker setup
- ✅ Guide you through cloud deployment
- ✅ Provide deployment URLs

---

## 🎯 **Recommended Deployment Strategy**

### **For Production Use:**

1. **Backend**: Railway or Azure App Service
   - ✅ Automatic scaling
   - ✅ Easy environment management
   - ✅ Built-in monitoring
   - ✅ Database integration ready

2. **Frontend**: Cloudflare Pages or Netlify
   - ✅ Global CDN
   - ✅ Automatic SSL
   - ✅ Branch previews
   - ✅ Edge computing

### **For Development/Testing:**

1. **Docker Compose**: Quick local setup
2. **GitHub Codespaces**: Cloud development environment

---

## 🔐 **Security Considerations**

### **Production Checklist:**

- ✅ **HTTPS Only**: Always use SSL in production
- ✅ **Environment Variables**: Never commit secrets
- ✅ **CORS**: Configure allowed origins properly
- ✅ **Security Headers**: Already configured in `_headers`
- ✅ **Authentication**: Consider adding user auth for sensitive operations
- ✅ **Rate Limiting**: Implement API rate limiting if needed

### **Memory Access Requirements:**

- ⚠️ **Windows Server Required**: Backend needs Windows for memory operations
- ⚠️ **Administrator Rights**: Required for process memory access
- ⚠️ **Antivirus Exceptions**: May need to whitelist the application

---

## 📊 **Monitoring & Maintenance**

### **Health Checks:**

- **Backend**: `GET /api/system/health`
- **Frontend**: Loads with connection status indicator
- **Docker**: `docker-compose ps` to check service status

### **Logs:**

- **Railway**: Built-in log viewer
- **Cloudflare Pages**: Function logs in dashboard
- **Docker**: `docker-compose logs -f`

### **Updates:**

1. Push changes to GitHub
2. Automatic deployment via connected services
3. Test new features in staging environment

---

## 🆘 **Troubleshooting**

### **Common Issues:**

**"Can't connect to API"**
- ✅ Check CORS configuration
- ✅ Verify API URL in `_redirects`
- ✅ Ensure backend is running

**"Memory access denied"**
- ✅ Run backend as Administrator
- ✅ Use Windows server for hosting
- ✅ Check antivirus settings

**"Build fails"**
- ✅ Ensure Node.js 18+ and .NET 8.0
- ✅ Check build logs for specific errors
- ✅ Verify all dependencies are installed

### **Support:**

- 📚 Check application logs
- 🔍 Use browser developer tools
- 📧 Report issues in GitHub repository
- 💬 Community support available

---

## 🎉 **You're Ready to Deploy!**

Your Shaiya Monster Drop Web Application is production-ready with:

✅ **Professional architecture** with ASP.NET Core + React
✅ **Real-time capabilities** via SignalR
✅ **Multiple deployment options** for any hosting preference
✅ **Complete documentation** and deployment scripts
✅ **Security features** and production optimization

Choose your preferred deployment method above and launch your application to the world! 🌍

---

*Need help? The deployment scripts will guide you through the process step by step!*