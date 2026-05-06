# 🚀 QUICK REFERENCE - NEXT.JS & NODE.JS API INTEGRATION

## What Was Fixed

### 1. ✅ API URL Configuration
**Before**: `http://localhost:5000/api` + endpoint = possible `/api/api/...`  
**After**: Correct URL formation with proper base URL

```javascript
// lib/api.ts
export const API_BASE = "http://localhost:5000/api";

export async function apiRequest(endpoint: string, ...) {
  const url = `${API_BASE}${endpoint}`; // ✓ Correct!
  // ... rest of code
}
```

### 2. ✅ Admin Service Endpoints
**Before**: Wrong endpoint paths  
**After**: Correct API routes

```javascript
// lib/api.ts - adminService
export const adminService = {
    login: (credentials) => apiRequest("/auth/owner/login", {
        method: "POST",
        body: JSON.stringify(credentials),
    }),
    
    getAgents: () => apiRequest("/admin/agents", {
        method: "GET",
    }),
    
    approveAgent: (id) => apiRequest(`/admin/approve-agent/${id}`, {
        method: "PATCH",
        body: JSON.stringify({}),
    }),
};
```

### 3. ✅ Backend Routes Created
**File**: `src/routes/admin.routes.js`

```javascript
// GET /api/admin/agents - Fetch all agents
router.get("/agents", protect, role("OWNER"), async (req, res) => {
  const agents = await Agent.find().select("-password");
  res.json({ success: true, agents, message: "..." });
});

// PATCH /api/admin/approve-agent/:id - Approve agent
router.patch("/approve-agent/:id", protect, role("OWNER"), async (req, res) => {
  const agent = await Agent.findById(req.params.id);
  agent.status = "APPROVED";
  await agent.save();
  res.json({ success: true, message: "Agent approved", agent });
});
```

### 4. ✅ Token Handling
**Header**: `x-auth-token` (standard)  
**Storage**: `localStorage.ownerToken`

```javascript
// lib/api.ts - Authentication
const token = localStorage.getItem("ownerToken");
const headers = {
    "Content-Type": "application/json",
    ...(token ? { "x-auth-token": token } : {}),
};
```

### 5. ✅ Frontend Page Updated
**File**: `app/page.tsx`

```javascript
// Updated login handler with logging
const handleOwnerLogin = async () => {
    console.log("🔐 [ADMIN LOGIN] Attempting owner login...");
    const data = await adminService.login({ email, password });
    localStorage.setItem("ownerToken", data.token);
    setView("admin-dashboard");
};

// Updated approval handler
const handleApproveAgent = async (id, name) => {
    const result = await adminService.approveAgent(id);
    alert(`${name}'s application has been approved.`);
    await loadAdminData(); // Refresh
};
```

---

## 🎯 ENDPOINT MAP

### Frontend Calls
```
Frontend (Next.js)
    ↓
lib/api.ts::adminService
    ├── login(email, pwd) → POST /api/auth/owner/login
    ├── getAgents() → GET /api/admin/agents  
    └── approveAgent(id) → PATCH /api/admin/approve-agent/:id
    ↓
Backend (Node.js)
    ├── src/routes/auth.routes.js
    │   └── POST /api/auth/owner/login
    ├── src/routes/admin.routes.js
    │   ├── GET /api/admin/agents
    │   └── PATCH /api/admin/approve-agent/:id
    ↓
MongoDB
    └── Update agent.status = "APPROVED"
```

---

## 🧪 Testing the Integration

### Step 1: Start Backend
```bash
cd "e:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah amin\agentra-backend"
npm start

# Expected:
# 🚀 Server running on 5000
# ✅ MongoDB Connected
```

### Step 2: Start Frontend
```bash
cd "e:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah amin\agentra"
npm run dev

# Open: http://localhost:3000
```

### Step 3: Test Owner Login
1. Click "Access Admin Portal"
2. Enter owner email (check your .env for credentials)
3. Enter password
4. Should see admin dashboard with agents list

### Step 4: Test Agent Approval
1. Look for agents with status "PENDING_APPROVAL"
2. Click "Approve" button
3. Confirm dialog
4. Status should change to "APPROVED"
5. Agent can now login

---

## 🔍 Debugging

### Check Backend Logs
```
📋 [ADMIN] Fetching all agents...
✅ [ADMIN] Found 5 agents
🔄 [ADMIN] Approving agent: 507f1f77bcf86cd799439011
✅ [ADMIN] Agent approved successfully: 507f1f77bcf86cd799439011
```

### Check Frontend Logs
Open browser console (F12) and look for:
```
🔐 [ADMIN LOGIN] Attempting owner login...
🔐 [ADMIN LOGIN] Email: admin@agentra.com
📊 Loading admin data...
📋 [ADMIN] Fetching all agents...
✅ [ADMIN] Agent approved successfully
```

### Check API Requests
Use browser Network tab:
- Look for `POST /api/auth/owner/login`
- Look for `GET /api/admin/agents`
- Look for `PATCH /api/admin/approve-agent/:id`
- Each should have `x-auth-token` header

---

## 📊 Database Changes

### Agent Model
```javascript
agent = {
  _id: ObjectId,
  fullName: String,
  email: String,
  status: "PENDING_APPROVAL" | "APPROVED" | "REJECTED",
  // ... other fields
}
```

### Status Workflow
```
1. Agent registers → status = "PENDING_APPROVAL"
2. Admin approves → status = "APPROVED" (via PATCH endpoint)
3. Agent can create packages (only if status === "APPROVED")
```

---

## ❌ Common Issues & Solutions

### Issue: "Cannot GET /api/admin/agents"
**Cause**: Admin routes not registered  
**Solution**: Check `register-routes.js` has `app.use('/api/admin', adminRoutes)`

### Issue: "Invalid token" or 401
**Cause**: Token not sent or invalid  
**Solution**: 
- Check localStorage has "ownerToken"
- Check header includes "x-auth-token"
- Try logging out and in again

### Issue: Agent status not updating
**Cause**: Database not saving  
**Solution**:
- Check MongoDB connection is active
- Check agent ID is valid ObjectId
- Check PATCH request returns success

### Issue: Frontend shows empty agents list
**Cause**: No agents in database or auth failed  
**Solution**:
- Check backend logs for database query
- Verify token is being sent
- Check agent count in MongoDB directly

---

## 🎉 Verification Checklist

- [x] Backend routes: `POST /api/auth/owner/login`
- [x] Backend routes: `GET /api/admin/agents`
- [x] Backend routes: `PATCH /api/admin/approve-agent/:id`
- [x] Frontend API base: `http://localhost:5000/api`
- [x] Frontend adminService methods working
- [x] Token stored as "ownerToken"
- [x] Token sent as "x-auth-token" header
- [x] Error handling shows user messages
- [x] Logging shows in console
- [x] Database updates on approval

---

## 📞 Support

If you encounter issues:
1. Check backend logs in terminal
2. Check frontend logs in browser console (F12)
3. Check Network tab for API requests
4. Verify MongoDB connection: `MongoDB Connected ✅`
5. Test with: `node test-final-integration.js`
