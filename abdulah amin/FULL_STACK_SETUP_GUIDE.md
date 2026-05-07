# 🚀 FULL-STACK PROJECT SETUP GUIDE

**Project Type:** Node.js Express Backend + Next.js Frontend + Flutter Mobile  
**Current Status:** Backend ready, Frontend ready, Mobile apps built  
**Setup Time:** ~15 minutes

---

## 📋 SYSTEM REQUIREMENTS

Before starting, ensure you have:
- ✅ Node.js v20+ installed (`node --version`)
- ✅ MongoDB running locally (`mongod` service)
- ✅ npm v10+ (`npm --version`)
- ✅ Git installed
- ✅ For Flutter: Flutter SDK installed (`flutter --version`)

---

## 🔧 STEP 1: START MONGODB

MongoDB must be running first. Choose your method:

### **Option A: Windows Service (If installed as service)**
```powershell
# Check if running
Get-Service MongoDB

# If not running, start it
Start-Service MongoDB

# Verify connection
mongo
# If connected, type: exit
```

### **Option B: Manual MongoDB Start**
```powershell
# From MongoDB installation folder
C:\Program Files\MongoDB\Server\X.X\bin\mongod.exe

# Or add to PATH and run:
mongod
```

### **Option C: Docker (If you have Docker)**
```powershell
docker run -d -p 27017:27017 --name mongodb mongo
```

### **Verify MongoDB is Running:**
```powershell
# Should connect without errors
mongo --eval "db.adminCommand('ping')"
```

✅ **You should see:** `{ ok: 1 }`

---

## 🔧 STEP 2: START BACKEND (Node.js Express)

**Location:** `agentra-backend` folder

### **Step 2.1: Open Terminal in Backend Folder**
```powershell
cd "E:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah amin\agentra-backend"
```

### **Step 2.2: Install Dependencies (if not installed)**
```powershell
npm install
```

### **Step 2.3: Check .env Configuration**
```powershell
# Verify .env file has correct values
cat .env

# Should show:
# MONGO_URI=mongodb://localhost:27017/agentra
# JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
# PORT=5000
# NODE_ENV=development
```

### **Step 2.4: Start Backend in Development Mode**
```powershell
npm run dev
```

### **Expected Output:**
```
[timestamp] Agentra Backend Server running on http://localhost:5000
✅ MongoDB Connected
```

✅ **Backend is ready when you see:** `MongoDB Connected` and server listening on port 5000

**Note:** Leave this terminal open and running

---

## 🔧 STEP 3: TEST BACKEND ENDPOINTS

### **Open NEW terminal** (keep backend running in previous terminal)

### **Test Admin Login**
```powershell
$response = Invoke-WebRequest -Uri "http://localhost:5000/api/auth/owner/login" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{"email":"admin@agentra.com","password":"admin123"}' `
  -UseBasicParsing

$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 5
```

**Expected Response:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "owner": {
    "email": "admin@agentra.com",
    "role": "OWNER"
  }
}
```

✅ **If you get token, backend is working!**

### **Test User Registration**
```powershell
$body = @{
    fullName = "Test User"
    email = "testuser@example.com"
    password = "Test@123"
    phone = "03001234567"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://localhost:5000/api/auth/user/register" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body `
  -UseBasicParsing

$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3
```

✅ **If successful, you get user data and token**

### **Test Chatbot Endpoint**
```powershell
$body = @{
    message = "What are popular travel packages?"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://localhost:5000/api/chatbot/query" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body `
  -UseBasicParsing

$response.Content | ConvertFrom-Json
```

---

## 🔧 STEP 4: START FRONTEND (Next.js)

**Location:** `agentra` folder (frontend)

### **Step 4.1: Open NEW Terminal**

### **Step 4.2: Navigate to Frontend**
```powershell
cd "E:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah amin\agentra"
```

### **Step 4.3: Check Environment Configuration**
```powershell
# Verify .env.local
cat .env.local

# Should show:
# NEXT_PUBLIC_API_URL=http://localhost:5000/api
```

### **Step 4.4: Install Dependencies (if needed)**
```powershell
npm install
```

### **Step 4.5: Start Frontend**
```powershell
npm run dev
```

### **Expected Output:**
```
  ▲ Next.js 16.2.4
  - Local:        http://localhost:3001
  - Turbopack:    enabled
```

✅ **Frontend ready when you see:** `http://localhost:3001`

---

## 🔧 STEP 5: TEST FRONTEND-BACKEND CONNECTION

### **Open Browser and Navigate to:**
```
http://localhost:3001
```

### **You Should See:**
- ✅ Admin Dashboard
- ✅ Agent Verification section
- ✅ Dashboard Statistics

### **Test Frontend Features:**

**1. Admin Login Test**
- URL: `http://localhost:3001`
- Try logging in with: `admin@agentra.com` / `admin123`
- Should see dashboard with stats

**2. Open Browser DevTools**
- Press `F12` → Go to Network tab
- Perform any action
- You should see API calls to `http://localhost:5000/api/...`
- Check if calls have token in headers

**3. Test Admin Features**
- Look for "Verify Agent" section
- Check if it loads agent requests from backend
- Try to verify or reject an agent

---

## 🔧 STEP 6: USING POSTMAN (RECOMMENDED FOR TESTING)

### **Step 6.1: Download Postman**
- Download from: https://www.postman.com/downloads/
- Install and open

### **Step 6.2: Create New Collection**
- Click "New" → "Collection"
- Name it: `Agentra API Tests`

### **Step 6.3: Create Test Requests**

#### **Request 1: Admin Login**
```
Method: POST
URL: http://localhost:5000/api/auth/owner/login
Headers:
  Content-Type: application/json
Body (raw JSON):
{
  "email": "admin@agentra.com",
  "password": "admin123"
}
```

**Send** → Copy the token from response

#### **Request 2: User Registration**
```
Method: POST
URL: http://localhost:5000/api/auth/user/register
Headers:
  Content-Type: application/json
Body:
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "password": "Secure@123",
  "phone": "03001234567"
}
```

#### **Request 3: Get Public Packages**
```
Method: GET
URL: http://localhost:5000/api/packages/public
```

#### **Request 4: Get All Agents (Admin Only)**
```
Method: GET
URL: http://localhost:5000/api/agents
Headers:
  x-auth-token: <paste_token_from_admin_login>
  Content-Type: application/json
```

#### **Request 5: Chatbot Query**
```
Method: POST
URL: http://localhost:5000/api/chatbot/query
Headers:
  Content-Type: application/json
Body:
{
  "message": "Show me mountain adventure packages"
}
```

---

## 🔧 STEP 7: START FLUTTER APP

### **For Flutter Web (Easiest)**

**Step 7.1: Open Terminal in Flutter Project**
```powershell
cd "E:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah amin\agentra_travelagent"
```

**Step 7.2: Run Flutter App for Web**
```powershell
flutter pub get
flutter run -d web
```

### **For Flutter Android Emulator**
```powershell
# Check available emulators
flutter emulators

# Start emulator
flutter emulators --launch <emulator_name>

# Run app
flutter run
```

### **For Flutter iOS Simulator (Mac only)**
```powershell
open -a Simulator
flutter run
```

### **For Real Device**
```powershell
flutter run
# Connect your device via USB
```

---

## ✅ VERIFICATION CHECKLIST

```
BACKEND:
[ ] MongoDB is running
[ ] Backend server started on port 5000
[ ] Admin login works (returns token)
[ ] User registration works
[ ] Endpoints respond correctly

FRONTEND:
[ ] Frontend running on port 3001
[ ] Dashboard loads
[ ] API calls visible in DevTools Network tab
[ ] Buttons trigger backend calls
[ ] Admin login works from UI

API CONNECTIVITY:
[ ] Backend responds to requests
[ ] Frontend sends tokens in headers
[ ] Error handling works
[ ] CORS not blocking requests

POSTMAN:
[ ] All collection requests work
[ ] Tokens are properly stored and used
[ ] Status codes are correct (200, 201, 400, 401, etc)
```

---

## 🐛 TROUBLESHOOTING

### **Problem: MongoDB Connection Failed**
```
Error: connect ECONNREFUSED 127.0.0.1:27017
```
**Solution:**
- Start MongoDB service: `Start-Service MongoDB`
- Or run: `mongod` in a separate terminal
- Check if running: `mongo --eval "db.adminCommand('ping')"`

### **Problem: Backend Won't Start**
```
Error: listen EADDRINUSE :::5000
```
**Solution:**
```powershell
# Find process using port 5000
netstat -ano | findstr :5000

# Kill process
taskkill /PID <PID> /F

# Or change PORT in .env
```

### **Problem: Frontend API Calls Fail (401)**
```
Network Error: 401 Unauthorized
```
**Solution:**
1. Check `.env.local` has correct `NEXT_PUBLIC_API_URL`
2. Verify backend token is being sent in headers
3. Check token expiry (tokens expire in 7 days)
4. Clear browser cache: `Ctrl+Shift+Delete`

### **Problem: CORS Error**
```
Access to XMLHttpRequest blocked by CORS
```
**Solution:**
- CORS is enabled in backend
- Restart backend if just added it
- Check Origin header matches

### **Problem: Port Already in Use**

**For Port 3001 (Frontend):**
```powershell
# Find process
netstat -ano | findstr :3001
# Kill it
taskkill /PID <PID> /F
```

**For Port 5000 (Backend):**
```powershell
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

---

## 📊 API ENDPOINTS OVERVIEW

### **Authentication**
```
POST   /api/auth/user/register      - Register user
POST   /api/auth/user/login         - User login
POST   /api/auth/user/logout        - User logout
POST   /api/auth/agent/register     - Register agent
POST   /api/auth/agent/login        - Agent login
POST   /api/auth/owner/login        - Admin login
```

### **Packages**
```
GET    /api/packages/public         - Get all packages
GET    /api/packages/agent/:id      - Get agent packages
POST   /api/packages                - Create package (agent)
PUT    /api/packages/:id            - Update package
DELETE /api/packages/:id            - Delete package
```

### **Chatbot**
```
POST   /api/chatbot/query           - Send message
GET    /api/chatbot/history         - Get chat history
```

### **Admin**
```
GET    /api/dashboard               - Dashboard stats
GET    /api/agents                  - All agents
PUT    /api/agents/:id/verify       - Verify agent
PUT    /api/agents/:id/reject       - Reject agent
```

---

## 🎯 NEXT STEPS

1. **Get all APIs working** ✅ (This guide)
2. **Test all CRUD operations** (Use Postman)
3. **Build missing UI pages** (Agent dashboard, User app)
4. **Connect all buttons** (Every button should call an API)
5. **Implement real payment processing**
6. **Deploy to production**

---

## 📱 QUICK COMMAND REFERENCE

```powershell
# Backend
cd agentra-backend && npm run dev

# Frontend
cd agentra && npm run dev

# Flutter Web
cd agentra_travelagent && flutter run -d web

# Test APIs
Invoke-WebRequest -Uri "http://localhost:5000/api/auth/owner/login" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"email":"admin@agentra.com","password":"admin123"}' -UseBasicParsing

# Check port usage
netstat -ano | findstr :<port>

# Kill process
taskkill /PID <PID> /F
```

---

## 💡 IMPORTANT NOTES

1. **Keep 3 Terminals Open:**
   - Terminal 1: MongoDB (`mongod`)
   - Terminal 2: Backend (`npm run dev`)
   - Terminal 3: Frontend (`npm run dev`)

2. **Token Management:**
   - Tokens expire in 7 days
   - Always include token in `x-auth-token` header
   - Postman can save tokens for reuse

3. **Port Mapping:**
   - Backend: `5000`
   - Frontend: `3001` (auto-switches if 3000 taken)
   - MongoDB: `27017`

4. **Environment Variables:**
   - Backend: `.env` file
   - Frontend: `.env.local` file
   - Never commit these files!

5. **Development vs Production:**
   - Currently: Development mode
   - For production: Use `NODE_ENV=production` and deploy to Vercel/Railway

---

**Setup Complete! Your full-stack app is ready for development.** 🎉

