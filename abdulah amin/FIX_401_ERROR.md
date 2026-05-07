# 🔧 401 ERROR TROUBLESHOOTING GUIDE

## ❌ Error: "Request failed with status 401"

**What it means:** The backend API rejected your request because it doesn't recognize your authentication token.

---

## 🎯 Quick Fix (Step by Step)

### **Step 1: Verify Backend is Running**

Open a PowerShell terminal and test the health endpoint:

```powershell
# Test health check (no auth needed)
$response = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing
$response.Content | ConvertFrom-Json | ConvertTo-Json
```

**Expected Output:**
```json
{
  "success": true,
  "status": "healthy",
  "mongodb": "✅ Connected",
  "port": 5000,
  "environment": "development"
}
```

❌ **If this fails:**
- Backend is not running
- MongoDB is not running
- Port 5000 is blocked
- See "Backend Issues" section below

---

### **Step 2: Test API Status Endpoint**

```powershell
$response = Invoke-WebRequest -Uri "http://localhost:5000/api/status" -UseBasicParsing
$response.Content | ConvertFrom-Json | ConvertTo-Json
```

**Expected Output:**
```json
{
  "success": true,
  "api": "Agentra Travel Management System",
  "status": "running",
  "database": "connected"
}
```

---

### **Step 3: Get Fresh Admin Token**

```powershell
$body = '{"email":"admin@agentra.com","password":"admin123"}'
$response = Invoke-WebRequest -Uri "http://localhost:5000/api/auth/owner/login" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body `
  -UseBasicParsing

$token = ($response.Content | ConvertFrom-Json).token
Write-Host "✅ Token received: $($token.substring(0, 30))..."
```

**Save the token** - you'll need it for the next step.

---

### **Step 4: Test Authenticated Request**

```powershell
# Replace TOKEN_HERE with the actual token from Step 3
$token = "YOUR_TOKEN_HERE"

$response = Invoke-WebRequest -Uri "http://localhost:5000/api/owner/dashboard" `
  -Method GET `
  -Headers @{
    "Content-Type" = "application/json"
    "x-auth-token" = $token
  } `
  -UseBasicParsing

$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3
```

✅ **If successful**, you'll get dashboard stats  
❌ **If 401**, the token is not valid

---

### **Step 5: Clear Frontend Token and Restart**

1. **Open Frontend**
   ```
   http://localhost:3001
   ```

2. **Open DevTools** (Press F12)

3. **Go to Console tab** and run:
   ```javascript
   localStorage.removeItem("ownerToken");
   location.reload();
   ```

4. **You should see Login page**

5. **Login with:**
   - Email: `admin@agentra.com`
   - Password: `admin123`

---

## 🐛 Root Cause Analysis

### **Cause 1: No Token in localStorage**
- **Symptom:** Frontend tries to load admin data without logging in first
- **Fix:** Ensure you login first before accessing admin dashboard

### **Cause 2: Token is Expired**
- **Symptom:** Token exists but is old (>7 days)
- **Fix:** Clear token and login again
  ```javascript
  localStorage.removeItem("ownerToken");
  ```

### **Cause 3: Token Format Wrong**
- **Symptom:** Token sent but doesn't match JWT format
- **Fix:** Ensure backend is sending proper JWT
  - Token should start with `eyJ...`
  - Should have 3 parts separated by dots: `header.payload.signature`

### **Cause 4: Backend Not Running or Not Connected**
- **Symptom:** API endpoints not responding
- **Fix:** Check backend terminal for errors

### **Cause 5: MongoDB Connection Failed**
- **Symptom:** Backend running but returns errors
- **Fix:** Ensure MongoDB is running

---

## 🔍 DETAILED DEBUGGING

### **Check Browser Console (F12 → Console)**

**Good Output:**
```
🌐 API Request: GET http://localhost:5000/api/owner/dashboard
🔑 Token Sent: ✅ Yes (eyJhbGciOiJIUzI1NiIsIn...)
📡 Response Status: 200
📦 Response Data: {success: true, stats: {...}}
```

**Bad Output:**
```
🌐 API Request: GET http://localhost:5000/api/owner/dashboard
🔑 Token Sent: ❌ No token found
📡 Response Status: 401
❌ API Error [401]: No token, authorization denied
```

**Solution:** You're not logged in. Click login button.

---

### **Check Backend Console Output**

**Good:**
```
[timestamp] GET /api/owner/dashboard
✅ MongoDB Connected
📡 Response Status: 200
```

**Bad:**
```
[timestamp] GET /api/owner/dashboard
❌ MongoDB Error: connect ECONNREFUSED 127.0.0.1:27017
📡 Response Status: 401
```

**Solution:** Start MongoDB first.

---

## ✅ VERIFICATION CHECKLIST

Before testing, ensure:

```
[ ] MongoDB running
    - Command: mongod
    - Or: Start-Service MongoDB

[ ] Backend running
    - Command: npm run dev
    - Location: agentra-backend folder
    - Should show: ✅ MongoDB Connected

[ ] Frontend running
    - Command: npm run dev
    - Location: agentra folder
    - Should show: http://localhost:3001

[ ] Can reach health endpoint
    - http://localhost:5000/health
    - Returns: {status: "healthy", mongodb: "✅ Connected"}

[ ] Can get admin token
    - POST /api/auth/owner/login
    - Returns: {token: "eyJ..."}

[ ] Can call authenticated endpoint
    - GET /api/owner/dashboard
    - With x-auth-token header
    - Returns: {success: true, stats: {...}}
```

---

## 🚀 POSTMAN TESTING

### **Import This Collection:**

**1. Admin Login Request**
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

**2. Get Dashboard (Authenticated)**
```
Method: GET
URL: http://localhost:5000/api/owner/dashboard
Headers:
  x-auth-token: <copy_token_from_login_response>
  Content-Type: application/json
```

**3. Get Agents List**
```
Method: GET
URL: http://localhost:5000/api/owner/agents
Headers:
  x-auth-token: <token>
  Content-Type: application/json
```

**4. Health Check**
```
Method: GET
URL: http://localhost:5000/health
```

---

## 💾 ENVIRONMENT VARIABLES

### **Backend (.env)**
Verify these exist:
```
MONGO_URI=mongodb://localhost:27017/agentra
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
PORT=5000
NODE_ENV=development
```

### **Frontend (.env.local)**
Verify these exist:
```
NEXT_PUBLIC_API_URL=http://localhost:5000/api
```

---

## 🔴 IF STILL GETTING 401

### **Check 1: Is MongoDB Connected?**
```powershell
# In backend terminal, you should see:
✅ MongoDB Connected
```

If not:
```powershell
# Start MongoDB
mongod
# Or
Start-Service MongoDB
```

### **Check 2: Is Backend Restarted?**
```powershell
# Restart backend
npm run dev
```

### **Check 3: Is Endpoint Protected?**
Some endpoints don't need auth. Try:
```powershell
# Public endpoint (no auth)
$response = Invoke-WebRequest -Uri "http://localhost:5000/api/packages/public" -UseBasicParsing
```

### **Check 4: Is Token Valid?**
```javascript
// In browser console
localStorage.getItem("ownerToken")
// Copy and check: Should start with "eyJ" and have 3 parts separated by dots
```

### **Check 5: Browser Cache Issue**
```powershell
# Clear cache
Ctrl + Shift + Delete

# Or in console:
localStorage.clear()
location.reload()
```

---

## 📊 COMMON 401 SCENARIOS

| Scenario | Cause | Fix |
|----------|-------|-----|
| Fresh page load | No token yet | Login first |
| After login still 401 | Token not saved | Check localStorage |
| Token exists but 401 | Token expired | Login again |
| All endpoints 401 | Backend issue | Restart backend |
| One endpoint 401 | Endpoint protected | Add token to request |

---

## 🎯 NEXT STEPS

1. **Verify with Health Check**
   ```powershell
   curl http://localhost:5000/health
   ```

2. **Get Valid Token**
   ```powershell
   # See Step 3 above
   ```

3. **Test Protected Endpoint**
   ```powershell
   # See Step 4 above
   ```

4. **Clear Frontend Token**
   ```javascript
   localStorage.removeItem("ownerToken")
   ```

5. **Login Again**
   - Open http://localhost:3001
   - Enter credentials
   - Should redirect to dashboard

---

**If all checks pass but still getting 401, check backend logs for detailed error messages.**

