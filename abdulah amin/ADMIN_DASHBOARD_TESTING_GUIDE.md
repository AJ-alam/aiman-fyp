# Admin Dashboard Fix - Testing & Deployment Guide

## 🚀 Quick Start

### 1. Backend Setup
```bash
cd agentra-backend

# Ensure .env has:
# - MONGO_URI=your_mongodb_connection
# - JWT_SECRET=your_secret
# - PORT=5000

# Install dependencies (if not done)
npm install

# Start the server
npm start

# Expected output:
# 🚀 Server running on http://localhost:5000
# ✅ Connected to MongoDB
```

### 2. Frontend Setup
```bash
cd agentra

# Install dependencies (if not done)
npm install

# Start development server
npm run dev

# Expected output:
# ▲ Next.js X.X.X - Local
# ➜ Local: http://localhost:3000
```

### 3. Test Admin Routes
```bash
cd agentra-backend

# Run the verification script
node test-admin-routes.js

# Expected output shows all tests passing
```

---

## 📋 What Was Fixed

### The Problem
Admin dashboard displayed "Route not found" because the approval endpoints were:
- ✅ Implemented in the controller (`auth.controller.js`)
- ✅ Defined in the models
- ❌ **NOT registered in the routes file** ← ROOT CAUSE

### The Solution
Added three new routes to `src/routes/auth.routes.js`:
```javascript
router.get('/admin/agents/pending', protect, role('OWNER'), getPendingAgents);
router.put('/admin/agents/:agentId/approve', protect, role('OWNER'), approveAgent);
router.put('/admin/agents/:agentId/reject', protect, role('OWNER'), rejectAgent);
```

Plus minor frontend fixes to properly handle the API response format.

---

## ✅ Verification Checklist

### Backend Routes Registered
- [ ] Check `agentra-backend/src/routes/auth.routes.js` includes imports:
  - `getPendingAgents`
  - `approveAgent`
  - `rejectAgent`
- [ ] Check all three routes are defined
- [ ] Verify routes use `protect` and `role('OWNER')` middleware

### Frontend API Configuration
- [ ] Check `agentra/lib/api.ts` correctly extracts `response.agents`
- [ ] Check `agentra/app/page.tsx` `loadAdminData()` properly handles array response
- [ ] Verify token is stored in localStorage as "ownerToken"

### Database
- [ ] MongoDB is running and accessible
- [ ] Owner/Admin account exists with `role: 'OWNER'`
- [ ] At least one Agent record with `status: 'PENDING_APPROVAL'` exists (for testing)

---

## 🧪 Manual Testing Steps

### Step 1: Verify Backend is Running
```bash
# In a terminal, check the API is accessible
curl http://localhost:5000/api/auth/test
# Should return: {"success":true,"message":"Auth routes working 🚀"}
```

### Step 2: Create Test Data (if needed)
```bash
# Create a test agent with PENDING_APPROVAL status
# Run this in a MongoDB client or via a script

db.agents.insertOne({
  fullName: "Test Agent",
  email: "testagt@agentra.com",
  businessName: "Test Travel",
  cnic: "12345-6789012-3",
  phone: "+923001234567",
  status: "PENDING_APPROVAL",
  createdAt: new Date(),
  password: "hashed_password"
})
```

### Step 3: Access Admin Dashboard
1. Open http://localhost:3000 in your browser
2. Wait for splash screen (2.5 seconds)
3. Click "Access Admin Portal"
4. Enter admin email and password
5. **Expected:** Dashboard loads with pending agents table

### Step 4: Test Fetch Agents
1. After login, check browser DevTools → Console
2. **Expected logs:**
   ```
   📊 Loading admin data...
   🌐 API Request: GET http://localhost:5000/api/auth/admin/agents/pending
   📡 Response Status: 200
   ✅ [ADMIN] Agents response: {success: true, count: 1, agents: [{...}]}
   ✅ Admin data loaded successfully. Total agents: 1
   ```
3. **Expected UI:** Pending agents displayed in table

### Step 5: Test Approve Button
1. Locate a pending agent in the table
2. Click "Approve" button
3. Confirm in dialog
4. **Expected logs:**
   ```
   ✅ [ADMIN] Approving agent: {id}
   🌐 API Request: PUT http://localhost:5000/api/auth/admin/agents/{id}/approve
   📡 Response Status: 200
   ✅ Approve result: {success: true, agent: {...}}
   ✅ Admin data loaded successfully. Total agents: 0
   ```
5. **Expected UI:** Agent disappears from table, count updates

### Step 6: Test Reject Button
1. Create another pending agent (in MongoDB)
2. Click "Reject" button
3. Enter rejection reason in prompt
4. **Expected logs:**
   ```
   ❌ [ADMIN] Rejecting agent: {id}, {reason: "..."}
   🌐 API Request: PUT http://localhost:5000/api/auth/admin/agents/{id}/reject
   📡 Response Status: 200
   ✅ Reject result: {success: true, agent: {...}}
   ```
5. **Expected UI:** Agent disappears from table, status count updates

### Step 7: Test Token Expiration
1. In DevTools → Application → Storage → Cookies/LocalStorage
2. Delete the "ownerToken" entry
3. Reload the page
4. **Expected:** Redirected to login screen with error message

### Step 8: Test Invalid Token
1. Modify the token in localStorage (change a few characters)
2. Try to refresh the agents list
3. **Expected error:** "Token is not valid" or similar 401 error

---

## 🔍 Debugging Tips

### API Calls Not Reaching Backend
1. Check backend logs for incoming requests
2. Verify firewall isn't blocking port 5000
3. Check CORS is enabled in `agentra-backend/src/server.js`
4. Check API_BASE in `agentra/lib/api.ts` is correct

### Token Not Being Sent
1. Check browser DevTools → Network → Headers
2. Verify `x-auth-token` header is present
3. Check token format in localStorage (should be JWT string)
4. Verify token isn't null/undefined

### Agents Not Loading
1. Check MongoDB connection is active
2. Verify agents collection has documents
3. Check agent documents have `status: 'PENDING_APPROVAL'`
4. Check backend logs for controller errors

### Button Clicks Not Working
1. Check JavaScript errors in browser console
2. Verify onClick handlers are wired correctly
3. Check network tab for API request being sent
4. Verify response status code (should be 200)

### "Route not found" Error
- Routes were not registered in auth.routes.js
- **FIX:** Lines added to auth.routes.js (already done)
- Restart backend after making route changes

---

## 📊 Expected Response Formats

### Fetch Pending Agents
```javascript
{
  success: true,
  count: 2,
  agents: [
    {
      _id: "mongo_id_1",
      fullName: "Agent Name",
      email: "agent@example.com",
      businessName: "Travel Company",
      cnic: "12345-6789012-3",
      status: "PENDING_APPROVAL",
      phone: "+923001234567",
      // ... other fields
    }
  ]
}
```

### Approve/Reject Response
```javascript
{
  success: true,
  message: "Agent approved",
  agent: {
    _id: "mongo_id_1",
    status: "APPROVED",
    // ... other agent fields
  }
}
```

### Error Response
```javascript
{
  success: false,
  message: "Agent not found" // or other error message
}
// With HTTP status code: 404, 401, 403, 500, etc.
```

---

## 🚨 Common Issues & Solutions

### Issue: 401 Unauthorized
**Cause:** Token missing or invalid
**Solution:**
```bash
# Check in browser console:
localStorage.getItem('ownerToken')
# Should return a JWT string, not null

# Verify the token in auth header:
# Check DevTools → Network tab → Headers
# Should see: x-auth-token: eyJhb...
```

### Issue: 403 Forbidden
**Cause:** User role is not 'OWNER'
**Solution:**
```javascript
// In MongoDB, verify owner record has:
db.owners.findOne({email: "admin@agentra.com"})
// Should show: role: "OWNER"
```

### Issue: 500 Server Error
**Cause:** Unhandled exception in controller
**Solution:**
```bash
# Check backend terminal for error logs
# Look for stack trace in: agentra-backend console
# Common causes:
# - MongoDB connection lost
# - Missing required fields in request
# - Database schema mismatch
```

### Issue: Empty Agents Table
**Cause:** No pending agents in database
**Solution:**
```javascript
// Create test data:
db.agents.insertOne({
  fullName: "Test Agent",
  email: "test@example.com",
  status: "PENDING_APPROVAL",
  businessName: "Test Co",
  cnic: "12345-6789012-3"
})
```

### Issue: "Cannot read property 'agents' of undefined"
**Cause:** API response format mishandled
**Solution:**
- Verify `agentra/lib/api.ts` line 58 returns `response?.agents || []`
- Check backend sends response in correct format

---

## 📈 Performance Optimization (Optional)

### Add Loading State
Currently working ✅

### Add Error Retry
```typescript
// In loadAdminData, add retry logic for failed requests
const maxRetries = 3;
for (let i = 0; i < maxRetries; i++) {
  try {
    // fetch...
    break;
  } catch (err) {
    if (i === maxRetries - 1) throw err;
    await new Promise(r => setTimeout(r, 1000));
  }
}
```

### Add Request Debouncing
```typescript
// Prevent multiple simultaneous requests
let loadingPromise: Promise<void> | null = null;

const loadAdminData = async () => {
  if (loadingPromise) return loadingPromise;
  loadingPromise = /* ... fetch logic ... */;
  loadingPromise.finally(() => { loadingPromise = null; });
  return loadingPromise;
};
```

---

## ✨ Summary

| Component | Status | Notes |
|-----------|--------|-------|
| Backend Routes | ✅ Fixed | Added to auth.routes.js |
| Frontend API | ✅ Fixed | Response handling corrected |
| Authentication | ✅ Working | Token flow verified |
| Database | ✅ Ready | Use existing schema |
| UI Components | ✅ Working | Already implemented |
| Admin Dashboard | ✅ Complete | Fully functional |

---

## 📞 Support

If you encounter issues:
1. Check browser DevTools → Console for errors
2. Check backend terminal for logs
3. Verify all services are running
4. Test API manually using `curl` or Postman
5. Check MongoDB records directly

All the fix code is already in place! The dashboard should now be fully functional. 🎉
