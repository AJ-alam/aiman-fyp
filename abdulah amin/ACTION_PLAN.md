# 🎯 ACTION PLAN: Fix 401 Error & Get Backend/Frontend Working

**Status:** You're getting a 401 error when the frontend tries to connect to the backend.  
**Root Cause:** Missing or invalid authentication token when calling protected API endpoints.  
**Solution:** Follow the steps below to get everything running.

---

## ✅ CHECKLIST: What You've Done vs What's Needed

```
DONE:
[✅] Backend: Express.js running (port 5000)
[✅] Frontend: Next.js running (port 3001)
[✅] Database: MongoDB connection configured
[✅] Authentication: JWT system implemented
[✅] Admin account: Created (admin@agentra.com / admin123)

ISSUE:
[❌] Frontend getting 401 when loading admin data
[❌] Token not being sent or recognized
[❌] Dashboard not displaying

FIXED BY US:
[✅] Added health check endpoints (/health, /api/status)
[✅] Improved API error handling (detects 401 and clears token)
[✅] Better logging in frontend and backend
[✅] Auto-logout on invalid token
```

---

## 🚀 DO THIS NOW (RIGHT NOW!)

### **Phase 1: Verify Everything is Running (5 minutes)**

**Terminal 1: Check if MongoDB is Running**
```powershell
# Test MongoDB connection
mongo --eval "db.adminCommand('ping')"

# If FAILED:
mongod
# Let it run in background
```

**Terminal 2: Check if Backend is Running**
```powershell
# Navigate to backend
cd "E:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah amin\agentra-backend"

# Start backend
npm run dev

# Wait for this message:
# ✅ MongoDB Connected
# 🚀 Server running on 5000
```

**Terminal 3: Check if Frontend is Running**
```powershell
# Navigate to frontend
cd "E:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah amin\agentra"

# Start frontend
npm run dev

# Wait for:
# - Local: http://localhost:3001
```

---

### **Phase 2: Test Backend Works (3 minutes)**

**Terminal 4: Test Health Endpoint**
```powershell
# This endpoint doesn't need auth
curl http://localhost:5000/health

# Expected response:
# {"success":true,"status":"healthy","mongodb":"✅ Connected","port":5000}
```

✅ **If you see this, backend is working!**

---

### **Phase 3: Get Admin Token (2 minutes)**

**Terminal 4: Login to Get Token**
```powershell
$body = '{"email":"admin@agentra.com","password":"admin123"}'

$response = Invoke-WebRequest `
  -Uri "http://localhost:5000/api/auth/owner/login" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body `
  -UseBasicParsing

# Print the response
$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 5
```

**Look for the response like:**
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

✅ **Copy the token value - you'll need it next!**

---

### **Phase 4: Test Protected Endpoint (2 minutes)**

**Terminal 4: Use Token to Call Protected API**
```powershell
# Replace TOKEN_HERE with the token from Phase 3
$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

$response = Invoke-WebRequest `
  -Uri "http://localhost:5000/api/owner/dashboard" `
  -Method GET `
  -Headers @{
    "x-auth-token" = $token
    "Content-Type" = "application/json"
  } `
  -UseBasicParsing

$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3
```

✅ **If you see dashboard stats, backend API is working!**

---

### **Phase 5: Fix Frontend (3 minutes)**

**Step 1: Open Browser**
```
http://localhost:3001
```

**Step 2: Open Browser Console (F12)**
- Press `F12`
- Go to `Console` tab

**Step 3: Clear Old Token**
```javascript
localStorage.removeItem("ownerToken");
console.log("✅ Token cleared");
location.reload();
```

**Step 4: Wait for Login Form**
You should now see the login form.

**Step 5: Login**
- Email: `admin@agentra.com`
- Password: `admin123`
- Click "Login"

**Step 6: Watch Console**
You should see messages like:
```
🌐 API Request: POST http://localhost:5000/api/auth/owner/login
📡 Response Status: 200
✅ Token saved to localStorage
```

**Step 7: Dashboard Should Load**
After login, you should see the admin dashboard without 401 errors.

---

## 🎯 EXPECTED RESULTS

### **What You Should See After Following Steps Above:**

**Console Logs (F12 → Console):**
```
✅ Login successful
✅ Admin data loaded successfully
🌐 API Request: GET http://localhost:5000/api/owner/dashboard
📡 Response Status: 200
📦 Response Data: {agents: [...], stats: {...}}
```

**Browser:**
```
Admin Dashboard
├─ Agents Section
├─ Statistics
└─ Verify/Reject Buttons
```

**No 401 Errors!** ✅

---

## 📋 WHAT YOU GET BY FOLLOWING THIS

| Step | What Happens | Result |
|------|--------------|--------|
| 1 | Check all services | Verify everything is running ✅ |
| 2 | Test health endpoint | Backend responds to requests ✅ |
| 3 | Get auth token | You have proof authentication works ✅ |
| 4 | Use token on protected API | You can call restricted endpoints ✅ |
| 5 | Clear frontend token | Frontend is clean ✅ |
| 6 | Login in frontend | Fresh token saved ✅ |
| 7 | View dashboard | 401 error is gone ✅ |

---

## 🔴 IF SOMETHING FAILS

**At Phase 1 (Services not running):**
```powershell
# Start MongoDB
mongod

# Start backend (new terminal)
cd agentra-backend
npm run dev

# Start frontend (new terminal)
cd agentra
npm run dev
```

**At Phase 2 (Health endpoint fails):**
```powershell
# Check if backend is still running
# Look at backend terminal for errors
# MongoDB might have crashed - restart it
mongod
```

**At Phase 3 (Can't get token):**
```powershell
# Admin account might not exist - create it
cd agentra-backend
node create_admin.js

# Then try login again
```

**At Phase 4 (Protected endpoint returns 401):**
```powershell
# Token might be invalid - get a fresh one from Phase 3
# Make sure you copied the full token value
# Double check: token should start with "eyJ"
```

**At Phase 5 (Frontend still shows 401):**
```javascript
// In browser console, check:
localStorage.getItem("ownerToken")
// Should return: "eyJhbGciOiJIUzI1NiI..." (not empty, not null)

// If empty, clear and try login again:
localStorage.clear()
location.reload()
```

---

## 🎓 UNDERSTANDING THE 401 ERROR

**Flow that causes 401:**

```
1. Frontend loads
2. Checks localStorage for "ownerToken"
3. Token exists (but might be invalid or expired)
4. Frontend calls API with that token
5. Backend receives request
6. Backend checks x-auth-token header
7. Backend finds invalid/expired token
8. Backend returns 401 Unauthorized
9. Frontend sees error in console
```

**How we fixed it:**

```
✅ Added error handling for 401
✅ Clear invalid token from localStorage
✅ Redirect user to login form
✅ User logs in fresh
✅ New valid token saved
✅ Next API calls succeed
```

---

## 📱 TESTING WITH POSTMAN (Optional but Recommended)

If you want to test without using browser:

**1. Download Postman:** https://www.postman.com/downloads/

**2. Create New Request:**
```
Method: POST
URL: http://localhost:5000/api/auth/owner/login
Headers:
  Content-Type: application/json
Body (raw):
{
  "email": "admin@agentra.com",
  "password": "admin123"
}
```

**3. Send → Copy token from response**

**4. Create Second Request:**
```
Method: GET
URL: http://localhost:5000/api/owner/dashboard
Headers:
  x-auth-token: <paste token here>
  Content-Type: application/json
```

**5. Send → Should return dashboard data**

---

## 🏁 FINAL CHECKLIST

```
After following all steps above:

[ ] MongoDB is running
[ ] Backend is running on port 5000
[ ] Frontend is running on port 3001
[ ] Health endpoint works (curl http://localhost:5000/health)
[ ] Can get admin token (valid JWT)
[ ] Can call protected endpoint with token
[ ] Frontend shows login form
[ ] Can login in frontend
[ ] Dashboard loads after login
[ ] No 401 errors in console
[ ] Network tab shows successful API calls
```

---

## 💡 IMPORTANT NOTES

1. **Three Terminals Required:**
   - Terminal 1: MongoDB (`mongod`)
   - Terminal 2: Backend (`npm run dev`)
   - Terminal 3: Frontend (`npm run dev`)
   - Keep all 3 running while developing

2. **Token Expiry:**
   - Tokens expire after 7 days
   - If old token fails, login again to get fresh one

3. **Port Conflicts:**
   - Backend: 5000
   - Frontend: 3001 (auto-switches if 3000 taken)
   - MongoDB: 27017

4. **Environment Files:**
   - Backend: `.env` (check MONGO_URI, JWT_SECRET)
   - Frontend: `.env.local` (check NEXT_PUBLIC_API_URL)

---

## 🎯 NEXT STEPS AFTER THIS WORKS

Once you have the 401 error fixed and dashboard showing:

1. **Test all CRUD operations:**
   - Verify agents
   - Create packages
   - Update bookings
   - etc.

2. **Build missing UI pages:**
   - Agent dashboard
   - User registration/login
   - Package browsing
   - Booking creation
   - Payment processing

3. **Test API endpoints:**
   - Use Postman to test each endpoint
   - Verify error handling
   - Check data validation

4. **Deploy to production:**
   - Set up environment variables
   - Configure database
   - Deploy to Vercel/Railway/Render

---

**Total Time to Complete This: ~15-20 minutes**

**Follow each phase in order. Don't skip steps!**

Once this is working, you have a solid foundation to build the rest of your app. 🚀

