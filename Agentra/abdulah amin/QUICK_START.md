# ⚡ QUICK START - COPY & PASTE COMMANDS

## 📍 IMPORTANT: You Need 3 Open Terminals

---

## ✅ TERMINAL 1: MongoDB (Keep Running)

**If MongoDB is already running, skip this.**

```powershell
# Start MongoDB
mongod

# Or if installed as service:
Start-Service MongoDB
```

**Wait for:** `Waiting for connections on port 27017`

---

## ✅ TERMINAL 2: Backend API (Port 5000)

```powershell
# Navigate to backend
cd "E:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah amin\agentra-backend"

# Install dependencies (if first time)
npm install

# Start backend
npm run dev
```

**Wait for:** 
```
✅ MongoDB Connected
Agentra Backend Server running on http://localhost:5000
```

---

## ✅ TERMINAL 3: Frontend (Port 3001)

**Open a NEW terminal**

```powershell
# Navigate to frontend
cd "E:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah amin\agentra"

# Install dependencies (if first time)
npm install

# Start frontend
npm run dev
```

**Wait for:**
```
- Local: http://localhost:3001
- Turbopack: enabled
```

---

## 🧪 TERMINAL 4: Testing (NEW - Use for testing)

**Open a NEW terminal for testing**

### Test 1: Check Backend is Running
```powershell
curl -X GET http://localhost:5000/api/health
```

### Test 2: Admin Login
```powershell
$body = '{"email":"admin@agentra.com","password":"admin123"}'
$response = Invoke-WebRequest -Uri "http://localhost:5000/api/auth/owner/login" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body `
  -UseBasicParsing

$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 5
```

### Test 3: User Registration
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

### Test 4: Get Public Packages
```powershell
$response = Invoke-WebRequest -Uri "http://localhost:5000/api/packages/public" `
  -Method GET `
  -UseBasicParsing

$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3
```

---

## 🌐 Browser Tests

**Once frontend is running:**

### 1. Open Admin Dashboard
```
http://localhost:3001
```

### 2. Login with Admin Credentials
- Email: `admin@agentra.com`
- Password: `admin123`

### 3. Check Browser DevTools (F12)
- Go to **Network** tab
- Perform any action
- You should see API calls to `http://localhost:5000/api/...`
- Check **Headers** → Look for `x-auth-token`

### 4. Check Console for Errors
- Go to **Console** tab
- Look for errors (should be none)
- Look for logs showing successful API calls

---

## 🔴 TROUBLESHOOTING QUICK FIXES

### MongoDB Not Starting?
```powershell
# Verify MongoDB path exists
Test-Path "C:\Program Files\MongoDB\Server\X.X\bin\mongod.exe"

# Try manual start
& "C:\Program Files\MongoDB\Server\7.0\bin\mongod.exe"

# Or use Windows Service
Start-Service MongoDB
Get-Service MongoDB
```

### Backend Won't Start?
```powershell
# Check if port 5000 is taken
netstat -ano | findstr :5000

# If taken, kill it
taskkill /PID <PID> /F

# Then retry
npm run dev
```

### Frontend Won't Start?
```powershell
# Check port 3001
netstat -ano | findstr :3001

# If taken, kill it
taskkill /PID <PID> /F

# Try again
npm run dev
```

### API Returns 401 Errors?
```powershell
# Clear browser cache
# Ctrl + Shift + Delete

# Restart both backend and frontend
# Kill terminals and start fresh

# Check .env.local
cat .env.local
# Should show: NEXT_PUBLIC_API_URL=http://localhost:5000/api
```

---

## 📋 SUCCESS CHECKLIST

```
✅ MongoDB running (port 27017)
✅ Backend running (port 5000)
✅ Frontend running (port 3001)
✅ Admin login works
✅ API calls visible in Network tab
✅ No 401 or CORS errors
✅ Dashboard loads successfully
```

---

## 🚀 NEXT: POSTMAN TESTING

1. Download Postman: https://www.postman.com/downloads/
2. Create collection: `Agentra API`
3. Add requests (see FULL_STACK_SETUP_GUIDE.md for templates)
4. Test all endpoints systematically

---

## 📞 IF SOMETHING FAILS

Check this order:
1. Is MongoDB running? → `mongod` or `Start-Service MongoDB`
2. Is backend started? → See TERMINAL 2 output
3. Is frontend started? → See TERMINAL 3 output
4. Are all on correct ports? → Backend 5000, Frontend 3001
5. Any errors in console? → Check TERMINAL 2 & 3 output

**If stuck:** Review FULL_STACK_SETUP_GUIDE.md troubleshooting section

