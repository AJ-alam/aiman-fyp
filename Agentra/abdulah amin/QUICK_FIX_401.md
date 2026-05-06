# ⚡ FIX 401 ERROR - QUICK COMMANDS

## 🚀 DO THIS NOW (5 MINUTES)

### **Terminal 1: Verify Backend Health**

```powershell
# Test if backend is running
curl http://localhost:5000/health

# Expected response:
# {"success":true,"status":"healthy","mongodb":"✅ Connected","port":5000}
```

If that fails:
```powershell
# Start MongoDB
mongod

# In new terminal, start backend
cd "E:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah amin\agentra-backend"
npm run dev

# Wait for: ✅ MongoDB Connected
```

---

### **Terminal 2: Get Fresh Admin Token**

```powershell
# Login to get token
$body = '{"email":"admin@agentra.com","password":"admin123"}'
$response = Invoke-WebRequest -Uri "http://localhost:5000/api/auth/owner/login" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body `
  -UseBasicParsing

# Extract token
$token = ($response.Content | ConvertFrom-Json).token
Write-Host "✅ Your token: $token"
```

Copy the token from output.

---

### **Terminal 3: Test With Token**

```powershell
# Paste the token you just got
$token = "PASTE_TOKEN_HERE"

# Test getting admin dashboard
$response = Invoke-WebRequest -Uri "http://localhost:5000/api/owner/dashboard" `
  -Method GET `
  -Headers @{
    "Content-Type" = "application/json"
    "x-auth-token" = $token
  } `
  -UseBasicParsing

$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 2
```

✅ **If you get data, backend is working!**

---

### **Terminal 4: Fix Frontend**

```powershell
# Open browser
Start-Process "http://localhost:3001"

# OR manually open:
# http://localhost:3001
```

Then in browser console (F12):

```javascript
// Clear any bad tokens
localStorage.removeItem("ownerToken");
console.log("✅ Token cleared");

// Reload page
location.reload();
```

**You should see login form now.**

---

## 🔐 Login in Frontend

1. Go to `http://localhost:3001`
2. Click "Admin Login"
3. Enter:
   - Email: `admin@agentra.com`
   - Password: `admin123`
4. Click Login
5. Wait for dashboard to load

---

## ✅ VERIFICATION

After login, open browser console (F12) and check:

```
✅ Should see: 🌐 API Request: GET http://localhost:5000/api/owner/dashboard
✅ Should see: 🔑 Token Sent: ✅ Yes (eyJ...)
✅ Should see: 📦 Response Data: {success: true, stats: {...}}
✅ Should NOT see: ❌ API Error: 401
```

---

## 🔴 Still Getting 401?

### **Check 1: Backend Running?**
```powershell
curl http://localhost:5000/api/status
# Should return: {"success":true,"api":"Agentra...","status":"running"}
```

### **Check 2: MongoDB Connected?**
```powershell
curl http://localhost:5000/health
# Should show: "mongodb":"✅ Connected"
```

### **Check 3: Frontend Token?**
```javascript
// In browser console
localStorage.getItem("ownerToken")
// Should return: "eyJhbGciOiJIUzI1NiIs..." (not empty)
```

### **Check 4: Token Valid?**
In PowerShell:
```powershell
# Replace TOKEN with actual token from localStorage
$token = "TOKEN_HERE"
$response = Invoke-WebRequest -Uri "http://localhost:5000/api/owner/agents" `
  -Method GET `
  -Headers @{"x-auth-token"=$token} `
  -UseBasicParsing
$response.Content
```

---

## 🐛 DEBUGGING FLOW

```
1. Is backend running?
   └─ NO  → Start: npm run dev
   └─ YES → Continue

2. Is MongoDB connected?
   └─ NO  → Start: mongod
   └─ YES → Continue

3. Can you get token?
   └─ NO  → Run login test from Terminal 2
   └─ YES → Continue

4. Can you use token?
   └─ NO  → Token is invalid, get new one
   └─ YES → Continue

5. Does frontend show login form?
   └─ NO  → Clear localStorage and reload
   └─ YES → Continue

6. After login, no 401?
   └─ YES ✅ SUCCESS!
   └─ NO  → Check all steps above again
```

---

## 📋 COMMANDS SUMMARY

```powershell
# Check health
curl http://localhost:5000/health

# Get token
$body = '{"email":"admin@agentra.com","password":"admin123"}'
$r = Invoke-WebRequest -Uri "http://localhost:5000/api/auth/owner/login" -Method POST -Headers @{"Content-Type"="application/json"} -Body $body -UseBasicParsing; ($r.Content | ConvertFrom-Json).token

# Use token
$t = "YOUR_TOKEN"; Invoke-WebRequest -Uri "http://localhost:5000/api/owner/dashboard" -Method GET -Headers @{"x-auth-token"=$t} -UseBasicParsing | % Content | ConvertFrom-Json

# Clear frontend
# http://localhost:3001 → F12 → Console → localStorage.removeItem("ownerToken"); location.reload();
```

---

**Expected Timeline: 5-10 minutes**

Follow each step in order. If you get stuck at any step, check the [FIX_401_ERROR.md](FIX_401_ERROR.md) for detailed explanations.

