# 🚂 **Railway Deployment - Step-by-Step Guide**

Your Monster Drop Web Application is ready for Railway deployment! Follow these steps to deploy your backend API.

---

## 📋 **Prerequisites**

✅ **Railway CLI installed** (already done)
✅ **Backend Docker configuration ready** 
✅ **Railway.json configuration file ready**
✅ **All code committed to GitHub repository**

---

## 🚀 **Step 1: Railway Authentication**

### **Method A: Using Railway CLI (Recommended)**

1. **Open terminal/command prompt** in your project directory:
   ```bash
   cd tools/MonsterDropWebApp
   ```

2. **Login to Railway:**
   ```bash
   railway login
   ```
   - This will open a browser window
   - Login with your GitHub account or Railway account
   - Authorize the CLI access

3. **Verify login:**
   ```bash
   railway whoami
   ```

### **Method B: Using Railway Dashboard**

Alternatively, you can deploy directly from the Railway web dashboard (instructions below).

---

## 🚀 **Step 2A: CLI Deployment (Automatic)**

### **Use the Automated Script**

**Linux/Mac:**
```bash
./railway-deploy.sh
```

**Windows:**
```cmd
railway-deploy.cmd
```

The script will:
- ✅ Create a new Railway project
- ✅ Configure environment variables
- ✅ Deploy your backend using Docker
- ✅ Provide you with the deployment URL

---

## 🚀 **Step 2B: Manual CLI Deployment**

### **Create and Link Project**

1. **Create new Railway project:**
   ```bash
   railway project:create "shaiya-monster-drop-api"
   ```

2. **Link current directory to project:**
   ```bash
   railway link
   ```

### **Configure Environment Variables**

```bash
railway variables:set ASPNETCORE_ENVIRONMENT=Production
railway variables:set ASPNETCORE_URLS=http://0.0.0.0:$PORT
railway variables:set PORT=8080
```

### **Deploy Application**

```bash
railway up
```

This will:
- Build your Docker container
- Deploy to Railway
- Provide a deployment URL

### **Get Your Application URL**

```bash
railway domain
```

---

## 🚀 **Step 3: Web Dashboard Deployment (Alternative)**

If CLI doesn't work, use the Railway dashboard:

### **1. Go to Railway Dashboard**
- Visit: https://railway.app/dashboard
- Login with your account

### **2. Create New Project**
- Click "New Project"
- Select "Deploy from GitHub repo"
- Choose: `nonigagalac/shaiya-episode-6`
- Branch: `genspark_ai_developer` (or `main` after PR merge)

### **3. Configure Service**
```
Service Name: shaiya-monster-drop-api
Root Directory: tools/MonsterDropWebApp/Backend
Build Command: (leave empty - uses Dockerfile)
Start Command: (leave empty - uses Dockerfile)
```

### **4. Environment Variables**
Add these in Railway dashboard:
```
ASPNETCORE_ENVIRONMENT = Production
ASPNETCORE_URLS = http://0.0.0.0:$PORT
```

### **5. Deploy**
- Railway will automatically build and deploy
- You'll get a deployment URL like: `https://shaiya-monster-drop-api-production-xxxx.up.railway.app`

---

## 📋 **Step 4: Get Your Backend URL**

After successful deployment, you'll receive a URL like:
```
https://shaiya-monster-drop-api-production-abc123.up.railway.app
```

### **Test Your Deployed API**

1. **Health Check:**
   ```
   https://your-app.up.railway.app/api/system/health
   ```

2. **API Documentation:**
   ```
   https://your-app.up.railway.app/swagger
   ```

3. **Test Endpoint:**
   ```
   https://your-app.up.railway.app/api/system/status
   ```

---

## 🔄 **Step 5: Update Frontend Configuration**

### **Environment Variables for Frontend**

Use your Railway URL to update frontend configuration:

```bash
# For Cloudflare Pages environment variables:
VITE_API_BASE_URL=https://your-app.up.railway.app
VITE_SIGNALR_HUB_URL=https://your-app.up.railway.app/hubs/monsterdrop
```

### **Update _redirects File**

Edit `Frontend/_redirects`:
```
/api/* https://your-app.up.railway.app/api/:splat 200
/hubs/* https://your-app.up.railway.app/hubs/:splat 200
/*      /index.html   200
```

---

## 🎯 **Step 6: Deploy Frontend to Cloudflare Pages**

### **Method A: Connect GitHub Repository**

1. **Go to Cloudflare Pages:** https://dash.cloudflare.com/pages
2. **Create project → Connect to Git**
3. **Select repository:** `nonigagalac/shaiya-episode-6`
4. **Configure build:**
   ```
   Framework: None
   Build command: cd tools/MonsterDropWebApp/Frontend && npm install && npm run build
   Build output: tools/MonsterDropWebApp/Frontend/dist
   ```
5. **Environment variables:** (Use your Railway URL)
   ```
   VITE_API_BASE_URL=https://your-railway-url.up.railway.app
   VITE_SIGNALR_HUB_URL=https://your-railway-url.up.railway.app/hubs/monsterdrop
   ```

### **Method B: Upload dist Folder**

1. **Go to Cloudflare Pages:** https://dash.cloudflare.com/pages
2. **Create project → Upload assets**
3. **Upload the entire `Frontend/dist/` folder**

---

## 🐛 **Troubleshooting**

### **Common Issues:**

**1. "railway command not found"**
```bash
npm install -g @railway/cli
```

**2. "Not logged in to Railway"**
```bash
railway login
```

**3. "Permission denied"**
```bash
sudo npm install -g @railway/cli
```

**4. "Build failed"**
- Check Railway logs: `railway logs`
- Ensure Docker configuration is correct
- Verify environment variables

**5. "API not accessible"**
- Check Railway dashboard for deployment status
- Verify environment variables are set
- Test health endpoint

---

## 📊 **Monitoring Your Deployment**

### **Railway Dashboard**
- **View logs:** Railway dashboard → Your project → Logs
- **Monitor metrics:** CPU, Memory, Network usage
- **Environment variables:** Can be updated in dashboard

### **CLI Commands**
```bash
railway logs          # View application logs
railway status        # Check deployment status  
railway open          # Open deployed app in browser
railway domain        # Get deployment URL
```

---

## 🎉 **Success Checklist**

After deployment, verify:

- [ ] ✅ **Backend deployed** to Railway with public URL
- [ ] ✅ **API health check** responds successfully
- [ ] ✅ **Swagger documentation** accessible
- [ ] ✅ **Frontend updated** with Railway backend URL
- [ ] ✅ **Frontend deployed** to Cloudflare Pages
- [ ] ✅ **Full application** works end-to-end
- [ ] ✅ **Memory operations** functional (on Windows server)

---

## 🔗 **Useful Links**

| Resource | URL |
|----------|-----|
| **Railway Dashboard** | https://railway.app/dashboard |
| **Railway Documentation** | https://docs.railway.app |
| **Cloudflare Pages** | https://dash.cloudflare.com/pages |
| **Your Repository** | https://github.com/nonigagalac/shaiya-episode-6 |

---

## 🎊 **Ready to Deploy!**

Choose your preferred method above and deploy your Monster Drop Web Application to Railway. The automated scripts will handle most of the process for you!

**Need help?** All configuration files are ready and tested. Just follow the steps above!