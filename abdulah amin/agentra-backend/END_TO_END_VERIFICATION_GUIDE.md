# 🚀 COMPLETE END-TO-END VERIFICATION GUIDE

## ✅ What You're About to Verify

This guide walks you through testing the ENTIRE approval workflow at runtime with actual:
- ✅ API requests and responses
- ✅ Database records  
- ✅ Console logs
- ✅ Status transitions

---

## 📋 PREREQUISITE CHECKLIST

Before starting, verify:

- [ ] Backend code cloned and ready
- [ ] MongoDB running and accessible
- [ ] `.env` file has `MONGO_URI`
- [ ] `.env` file has `JWT_SECRET`
- [ ] `npm install` completed in `agentra-backend`
- [ ] Admin account exists (run `node create_admin.js` if needed)

---

## 🎯 STEP-BY-STEP EXECUTION

### STEP 1: Create Admin Account (One-time)

```bash
cd e:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah\ amin\agentra-backend
node create_admin.js
```

**Expected Output:**
```
✅ Admin created successfully
Admin Email: admin@agentra.com
Admin Password: admin123
```

If admin already exists, you'll see: `✓ Admin already exists`

---

### STEP 2: Start Backend Server (Terminal 1)

```bash
cd e:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah\ amin\agentra-backend
node server.js
```

**Expected Console Output:**
```
✅ MongoDB Connected
🚀 Server running on 5000
[2024-04-30T10:30:45.123Z] POST /api/auth/owner/login
[2024-04-30T10:30:45.456Z] POST /api/auth/agent/register
[2024-04-30T10:30:45.789Z] POST /api/auth/agent/login
```

⚠️ **DO NOT CLOSE THIS TERMINAL** - Keep it running for logs monitoring.

---

### STEP 3: Run Full Verification Test (Terminal 2)

In a **NEW TERMINAL**, run the automated test:

```bash
cd e:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah\ amin\agentra-backend
node RUNTIME_VERIFICATION_TEST.js
```

**Expected Output** (detailed example):
```
═════════════════════════════════════════════════════════════════════════════════
✓ AGENTRA APPROVAL WORKFLOW - RUNTIME VERIFICATION TEST
═════════════════════════════════════════════════════════════════════════════════

📋 TEST 1 Admin Login (to get admin token)
🔗 POST /api/auth/owner/login
📤 Email: admin@agentra.com
✅ Admin login SUCCESSFUL
ℹ️ Token: eyJhbGciOiJIUzI1NiIs...

📋 TEST 2 Agent 1 Signup (verify status = PENDING_APPROVAL)
🔗 POST /api/auth/agent/register
📤 Email: agent1-abc123@test.com
✅ Agent 1 signup SUCCESSFUL
ℹ️ Agent ID: 60f7b3c5c5d8e1b8a4c5d6e7
ℹ️ Status in Response: PENDING_APPROVAL
✅ Status is correctly PENDING_APPROVAL

📋 TEST 3 Agent 1 Login with PENDING_APPROVAL (should FAIL with 403)
✅ Login correctly BLOCKED with 403
ℹ️ Message: "Your account is not yet approved by admin."

📋 TEST 4 Fetch Pending Agents (admin endpoint)
✅ Fetched pending agents SUCCESSFULLY
ℹ️ Count: 2
✅ Agent 1 found in pending list

📋 TEST 5 Admin Approves Agent 1
✅ Agent 1 approved SUCCESSFULLY
ℹ️ New Status: APPROVED
✅ Status correctly changed to APPROVED

📋 TEST 6 Agent 2 Signup (for rejection test)
✅ Agent 2 signup SUCCESSFUL

📋 TEST 7 Admin Rejects Agent 2
✅ Agent 2 rejected SUCCESSFULLY
ℹ️ New Status: REJECTED

📋 TEST 8 Agent 1 Login with APPROVED status (should SUCCESS)
✅ Login SUCCESSFUL for APPROVED agent
ℹ️ Token received: eyJhbGciOiJIUzI1NiIs...

📋 TEST 9 Agent 2 Login with REJECTED status (should FAIL with 403)
✅ Login correctly BLOCKED with 403

═════════════════════════════════════════════════════════════════════════════════
✓ ALL TESTS COMPLETED SUCCESSFULLY
═════════════════════════════════════════════════════════════════════════════════

📊 SUMMARY OF WHAT WAS VERIFIED:
  ✓ Admin can login and get token
  ✓ Agent signup creates PENDING_APPROVAL status in database
  ✓ Signup response shows approval message
  ✓ Pending agents CANNOT login (403 error)
  ✓ Admin can fetch list of pending agents
  ✓ Admin can approve agents (status changes to APPROVED)
  ✓ Approved agents CAN login and get JWT token
  ✓ Admin can reject agents (status changes to REJECTED)
  ✓ Rejected agents CANNOT login (403 error)

🎯 THE SYSTEM IS WORKING AT RUNTIME ✅
```

---

### STEP 4: Monitor Server Console Logs (Terminal 1)

While Test 2 is running, watch **Terminal 1** for console logs:

**During Signup (TEST 2):**
```
📝 [SIGNUP] Agent registration attempt: { email: 'agent1-abc123@test.com', businessName: 'Business abc123' }
✅ [SIGNUP] Agent created with status: PENDING_APPROVAL
📊 [SIGNUP] Agent data: { id: '60f7b3c5c5d8e1b8a4c5d6e7', email: 'agent1-abc123@test.com', status: 'PENDING_APPROVAL', isVerified: false }
```

**During Login Attempt - Pending (TEST 3):**
```
🔐 [LOGIN] Agent login attempt: { email: 'agent1-abc123@test.com' }
📊 [LOGIN] Agent found: { id: '60f7b3c5c5d8e1b8a4c5d6e7', email: 'agent1-abc123@test.com', status: 'PENDING_APPROVAL', isVerified: false }
⏳ [LOGIN] Account pending approval: agent1-abc123@test.com
```

**During Admin Fetch Pending (TEST 4):**
```
📋 [PENDING] Fetching pending agents...
✅ [PENDING] Found pending agents: 2
📊 [PENDING] Agents: [
  { id: '60f7b3c5c5d8e1b8a4c5d6e7', email: 'agent1-abc123@test.com', status: 'PENDING_APPROVAL' },
  { id: '60f7b3c5c5d8e1b8a4c5d6e8', email: 'agent2-xyz789@test.com', status: 'PENDING_APPROVAL' }
]
```

**During Admin Approval (TEST 5):**
```
👤 [APPROVE] Approval attempt for agent: 60f7b3c5c5d8e1b8a4c5d6e7
📊 [APPROVE] Agent current status: { id: '60f7b3c5c5d8e1b8a4c5d6e7', email: 'agent1-abc123@test.com', status: 'PENDING_APPROVAL' }
✅ [APPROVE] Agent approved successfully: { id: '60f7b3c5c5d8e1b8a4c5d6e7', email: 'agent1-abc123@test.com', newStatus: 'APPROVED' }
```

**During Admin Rejection (TEST 7):**
```
🚫 [REJECT] Rejection attempt for agent: 60f7b3c5c5d8e1b8a4c5d6e8
📊 [REJECT] Agent current status: { id: '60f7b3c5c5d8e1b8a4c5d6e8', email: 'agent2-xyz789@test.com', status: 'PENDING_APPROVAL' }
✅ [REJECT] Agent rejected successfully: { id: '60f7b3c5c5d8e1b8a4c5d6e8', email: 'agent2-xyz789@test.com', newStatus: 'REJECTED', reason: 'Does not meet business requirements' }
```

**During Approved Login (TEST 8):**
```
🔐 [LOGIN] Agent login attempt: { email: 'agent1-abc123@test.com' }
📊 [LOGIN] Agent found: { id: '60f7b3c5c5d8e1b8a4c5d6e7', email: 'agent1-abc123@test.com', status: 'APPROVED', isVerified: false }
✅ [LOGIN] Login successful for: agent1-abc123@test.com
```

---

### STEP 5: Verify Database Directly

In a **MongoDB client** (Compass, Atlas, or shell), query the database:

```javascript
// Find the test agents
db.agents.find(
  { email: { $regex: 'agent1|agent2' } }, 
  { email: 1, status: 1, rejectionReason: 1, createdAt: 1 }
).pretty()
```

**Expected Result:**
```json
[
  {
    "_id": ObjectId("60f7b3c5c5d8e1b8a4c5d6e7"),
    "email": "agent1-abc123@test.com",
    "status": "APPROVED",
    "rejectionReason": ""
  },
  {
    "_id": ObjectId("60f7b3c5c5d8e1b8a4c5d6e8"),
    "email": "agent2-xyz789@test.com",
    "status": "REJECTED",
    "rejectionReason": "Does not meet business requirements"
  }
]
```

✅ **This proves the database was actually updated!**

---

### STEP 6: Manual API Testing with Curl (Optional)

If you want to test individual endpoints:

#### Test 1: Admin Login
```bash
curl -X POST http://localhost:5000/api/auth/owner/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@agentra.com",
    "password": "admin123"
  }' | jq '.'
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "owner": {
    "_id": "60f7b3c5c5d8e1b8a4c5d6e0",
    "email": "admin@agentra.com",
    "role": "OWNER"
  }
}
```

#### Test 2: Agent Signup
```bash
curl -X POST http://localhost:5000/api/auth/agent/register \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "John Doe",
    "email": "john@test.com",
    "businessName": "John Tours",
    "phone": "+923001234567",
    "cnic": "12345-1234567-1",
    "password": "TestPass123!"
  }' | jq '.'
```

**Response:**
```json
{
  "success": true,
  "message": "Your account request has been submitted. Please wait for admin approval. This may take up to 24 hours.",
  "agent": {
    "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
    "email": "john@test.com",
    "businessName": "John Tours",
    "status": "PENDING_APPROVAL",
    "isVerified": false
  },
  "status": "PENDING_APPROVAL"
}
```

#### Test 3: Pending Agent Login (should FAIL)
```bash
curl -X POST http://localhost:5000/api/auth/agent/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@test.com",
    "password": "TestPass123!"
  }' | jq '.'
```

**Response (403):**
```json
{
  "success": false,
  "message": "Your account is not yet approved by admin."
}
```

#### Test 4: Get Pending Agents (Admin)
```bash
ADMIN_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

curl -X GET http://localhost:5000/api/auth/admin/agents/pending \
  -H "x-auth-token: $ADMIN_TOKEN" | jq '.'
```

**Response:**
```json
{
  "success": true,
  "count": 1,
  "agents": [
    {
      "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
      "email": "john@test.com",
      "status": "PENDING_APPROVAL",
      "businessName": "John Tours"
    }
  ]
}
```

#### Test 5: Approve Agent (Admin)
```bash
curl -X PUT http://localhost:5000/api/auth/admin/agents/60f7b3c5c5d8e1b8a4c5d6e7/approve \
  -H "Content-Type: application/json" \
  -H "x-auth-token: $ADMIN_TOKEN" \
  -d '{}' | jq '.'
```

**Response:**
```json
{
  "success": true,
  "message": "Agent approved successfully",
  "agent": {
    "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
    "email": "john@test.com",
    "status": "APPROVED"
  }
}
```

#### Test 6: Approved Agent Login (should SUCCEED)
```bash
curl -X POST http://localhost:5000/api/auth/agent/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@test.com",
    "password": "TestPass123!"
  }' | jq '.'
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "agent": {
    "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
    "email": "john@test.com",
    "status": "APPROVED"
  }
}
```

---

## 📊 WHAT PROVES IT WORKS

### ✅ Runtime Proof #1: API Responses
- Signup returns `status: "PENDING_APPROVAL"` ✓
- Pending login returns 403 with message ✓
- Approved login returns 200 with JWT token ✓
- Rejection returns error for already-rejected agents ✓

### ✅ Runtime Proof #2: Console Logs
- Server logs show `📝 [SIGNUP]` when agent signs up ✓
- Server logs show `⏳ [LOGIN] Account pending approval` for pending agents ✓
- Server logs show `✅ [APPROVE]` when admin approves ✓
- Server logs show `🚫 [REJECT]` when admin rejects ✓

### ✅ Runtime Proof #3: Database Records
- Agent records have `status: "APPROVED"` or `status: "REJECTED"` ✓
- Rejected agents have `rejectionReason` field populated ✓
- Multiple agents can have different statuses ✓

### ✅ Runtime Proof #4: Behavior Verification
- Pending agents CANNOT login (403) ✓
- Approved agents CAN login (200 + JWT) ✓
- Rejected agents CANNOT login (403) ✓
- Admin can fetch pending agents list ✓
- Admin can approve individual agents ✓
- Admin can reject individual agents ✓

---

## ❌ If Tests Fail

### Issue: "Cannot connect to MongoDB"
**Fix:**
```bash
# Check if MongoDB is running
# Start MongoDB if needed
mongod
```

### Issue: "Admin not found"
**Fix:**
```bash
node create_admin.js
```

### Issue: "Agent not found in pending list"
**Cause:** Schema mismatch or database not connected
**Fix:**
```bash
# Verify schema in Agent.js has:
# status: { type: String, enum: ['PENDING_APPROVAL', 'APPROVED', 'REJECTED'], default: 'PENDING_APPROVAL' }

# Check Agent.js
cat src/models/Agent.js | grep -A 5 "status:"
```

### Issue: "Login still allowed for PENDING agents"
**Cause:** loginAgent() not checking status correctly
**Fix:**
```bash
# Verify loginAgent() has this code:
grep -A 3 "status === 'PENDING_APPROVAL'" src/controllers/auth.controller.js
```

### Issue: Console logs not appearing
**Cause:** Server not restarted
**Fix:**
```bash
# Kill server with Ctrl+C, then restart:
node server.js
```

---

## 🎯 SUCCESS CHECKLIST

After running all tests, verify:

- [ ] `RUNTIME_VERIFICATION_TEST.js` shows all 9 tests with ✅
- [ ] Server console logs show all `📝`, `🔐`, `👤`, `🚫` markers
- [ ] Database shows agents with correct statuses
- [ ] Pending agents cannot login (403)
- [ ] Approved agents can login (200)
- [ ] Rejected agents cannot login (403)

---

## 📱 FRONTEND NEXT STEPS

After backend verification, update Flutter apps:

### Agent App (agentra_travelagent)
```dart
// After signup, show message
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      'Your account request has been submitted. '
      'Please wait for admin approval. This may take up to 24 hours.'
    ),
    duration: Duration(seconds: 5),
  ),
);

// Do NOT navigate to dashboard
// Just stay on signup screen
```

### User App (agentra_user_frontend)
No changes needed - users are not affected by agent approval.

### Admin Dashboard (Next.js)
```javascript
// Show pending agents list
const pendingAgents = await fetch(
  '/api/auth/admin/agents/pending',
  { headers: { 'x-auth-token': adminToken } }
);

// Show approve/reject buttons
<button onClick={() => approveAgent(agentId)}>Approve</button>
<button onClick={() => rejectAgent(agentId)}>Reject</button>
```

---

## ✨ FINAL VALIDATION

After everything works, you have:

✅ Agent approval workflow
✅ Database status tracking
✅ Login restrictions based on status
✅ Admin approval/rejection endpoints
✅ Console logging for debugging
✅ Tested and verified at runtime

**The implementation is complete and working!**
