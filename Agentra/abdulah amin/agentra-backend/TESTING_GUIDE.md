# Agent Approval Workflow - Manual Testing Guide

## Prerequisites
- Backend running on http://localhost:5000
- Admin user created (run: `node create_admin.js`)
- MongoDB connected

## Step-by-Step Manual Testing

### Step 1: Start the Backend Server
```bash
cd agentra-backend
npm install
node server.js
```

Expected output:
```
✅ MongoDB Connected
🚀 Server running on 5000
📝 [SIGNUP] Agent registration attempt:
```

### Step 2: Test Admin Login
Get the admin token first (you'll need it for approval endpoints).

```bash
curl -X POST http://localhost:5000/api/auth/owner/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@agentra.com",
    "password": "admin123"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "owner": { ... }
}
```

**Save the token as ADMIN_TOKEN**

### Step 3: Agent Signup (Status = PENDING_APPROVAL)

```bash
curl -X POST http://localhost:5000/api/auth/agent/register \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "John Doe",
    "businessName": "Johns Travels",
    "email": "john@test.com",
    "phone": "923001234567",
    "cnic": "12345-1234567-1",
    "password": "SecurePass123!"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Your account request has been submitted. Please wait for admin approval. This may take up to 24 hours.",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "agent": {
    "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
    "fullName": "John Doe",
    "email": "john@test.com",
    "status": "PENDING_APPROVAL",
    "isVerified": false,
    ...
  },
  "status": "PENDING_APPROVAL"
}
```

**Save the agent._id as AGENT_ID**

**Check Server Logs:**
```
📝 [SIGNUP] Agent registration attempt: { email: 'john@test.com', businessName: 'Johns Travels' }
✅ [SIGNUP] Agent created with status: PENDING_APPROVAL
📊 [SIGNUP] Agent data: { id: '60f7b3c5c5d8e1b8a4c5d6e7', email: 'john@test.com', status: 'PENDING_APPROVAL', isVerified: false }
```

### Step 4: Agent Login with PENDING Status (Should FAIL)

```bash
curl -X POST http://localhost:5000/api/auth/agent/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@test.com",
    "password": "SecurePass123!"
  }'
```

**Expected Response (403 Forbidden):**
```json
{
  "success": false,
  "message": "Your account is not yet approved by admin."
}
```

**Check Server Logs:**
```
🔐 [LOGIN] Agent login attempt: { email: 'john@test.com' }
📊 [LOGIN] Agent found: { id: '60f7b3c5c5d8e1b8a4c5d6e7', email: 'john@test.com', status: 'PENDING_APPROVAL', isVerified: false }
⏳ [LOGIN] Account pending approval: john@test.com
```

### Step 5: Admin Views Pending Agents

```bash
curl -X GET http://localhost:5000/api/auth/admin/agents/pending \
  -H "Content-Type: application/json" \
  -H "x-auth-token: ADMIN_TOKEN"
```

Replace `ADMIN_TOKEN` with the token from Step 2.

**Expected Response (200):**
```json
{
  "success": true,
  "count": 1,
  "agents": [
    {
      "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
      "fullName": "John Doe",
      "email": "john@test.com",
      "businessName": "Johns Travels",
      "phone": "923001234567",
      "status": "PENDING_APPROVAL",
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ]
}
```

**Check Server Logs:**
```
📋 [PENDING] Fetching pending agents...
✅ [PENDING] Found pending agents: 1
📊 [PENDING] Agents: [ { id: '60f7b3c5c5d8e1b8a4c5d6e7', email: 'john@test.com', status: 'PENDING_APPROVAL' } ]
```

### Step 6: Admin Approves Agent

```bash
curl -X PUT http://localhost:5000/api/auth/admin/agents/AGENT_ID/approve \
  -H "Content-Type: application/json" \
  -H "x-auth-token: ADMIN_TOKEN" \
  -d '{}'
```

Replace:
- `AGENT_ID` with the ID from Step 3
- `ADMIN_TOKEN` with the token from Step 2

**Expected Response (200):**
```json
{
  "success": true,
  "message": "Agent approved successfully",
  "agent": {
    "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
    "fullName": "John Doe",
    "email": "john@test.com",
    "status": "APPROVED",
    ...
  }
}
```

**Check Server Logs:**
```
👤 [APPROVE] Approval attempt for agent: 60f7b3c5c5d8e1b8a4c5d6e7
📊 [APPROVE] Agent current status: { id: '60f7b3c5c5d8e1b8a4c5d6e7', email: 'john@test.com', status: 'PENDING_APPROVAL' }
✅ [APPROVE] Agent approved successfully: { id: '60f7b3c5c5d8e1b8a4c5d6e7', email: 'john@test.com', newStatus: 'APPROVED' }
```

### Step 7: Verify Status Changed to APPROVED

Check pending agents again:

```bash
curl -X GET http://localhost:5000/api/auth/admin/agents/pending \
  -H "Content-Type: application/json" \
  -H "x-auth-token: ADMIN_TOKEN"
```

**Expected Response (200):**
```json
{
  "success": true,
  "count": 0,
  "agents": []
}
```

The agent should no longer be in pending list.

### Step 8: Agent Login with APPROVED Status

```bash
curl -X POST http://localhost:5000/api/auth/agent/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@test.com",
    "password": "SecurePass123!"
  }'
```

**Expected Response:**

Option A (200 - Fully Approved):
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "agent": {
    "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
    "email": "john@test.com",
    "status": "APPROVED",
    ...
  }
}
```

Option B (403 - Blocked by Email Verification):
```json
{
  "success": false,
  "message": "Account not verified"
}
```

This is expected if the admin hasn't verified the email yet. Login flow:
1. ✅ Status check: APPROVED (passes)
2. ✅ Password check: matches (passes)
3. ❌ Email verification check: isVerified = false (fails)

**Check Server Logs:**
```
🔐 [LOGIN] Agent login attempt: { email: 'john@test.com' }
📊 [LOGIN] Agent found: { id: '60f7b3c5c5d8e1b8a4c5d6e7', email: 'john@test.com', status: 'APPROVED', isVerified: false }
✅ [LOGIN] Login successful for: john@test.com
```

### Step 9: Test Agent Rejection

Create a new test agent:

```bash
curl -X POST http://localhost:5000/api/auth/agent/register \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Jane Smith",
    "businessName": "Janes Tours",
    "email": "jane@test.com",
    "phone": "923009876543",
    "cnic": "98765-9876543-1",
    "password": "SecurePass123!"
  }'
```

Save the returned `agent._id` as `AGENT_ID_2`

Now reject this agent:

```bash
curl -X PUT http://localhost:5000/api/auth/admin/agents/AGENT_ID_2/reject \
  -H "Content-Type: application/json" \
  -H "x-auth-token: ADMIN_TOKEN" \
  -d '{
    "reason": "Business documents not valid"
  }'
```

**Expected Response (200):**
```json
{
  "success": true,
  "message": "Agent rejected successfully",
  "agent": {
    "_id": "60f7b3c5c5d8e1b8a4c5d6e8",
    "fullName": "Jane Smith",
    "email": "jane@test.com",
    "status": "REJECTED",
    "rejectionReason": "Business documents not valid",
    ...
  }
}
```

**Check Server Logs:**
```
🚫 [REJECT] Rejection attempt for agent: 60f7b3c5c5d8e1b8a4c5d6e8
📊 [REJECT] Agent current status: { id: '60f7b3c5c5d8e1b8a4c5d6e8', email: 'jane@test.com', status: 'PENDING_APPROVAL' }
✅ [REJECT] Agent rejected successfully: { id: '60f7b3c5c5d8e1b8a4c5d6e8', email: 'jane@test.com', newStatus: 'REJECTED', reason: 'Business documents not valid' }
```

### Step 10: Rejected Agent Login (Should FAIL)

```bash
curl -X POST http://localhost:5000/api/auth/agent/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jane@test.com",
    "password": "SecurePass123!"
  }'
```

**Expected Response (403 Forbidden):**
```json
{
  "success": false,
  "message": "Your account has been rejected. Please contact admin."
}
```

**Check Server Logs:**
```
🔐 [LOGIN] Agent login attempt: { email: 'jane@test.com' }
📊 [LOGIN] Agent found: { id: '60f7b3c5c5d8e1b8a4c5d6e8', email: 'jane@test.com', status: 'REJECTED', isVerified: false }
❌ [LOGIN] Account rejected: jane@test.com
```

## Automated Testing

Run the automated test script:

```bash
cd agentra-backend
node TEST_APPROVAL_WORKFLOW.js
```

This will run all tests automatically and show results.

## Database Check (Optional)

If you have MongoDB Compass installed, verify the data:

1. Connect to your MongoDB database
2. Go to `agentra` database
3. Open `agents` collection
4. Look for agents with:
   - `status: "PENDING_APPROVAL"` - Not yet approved
   - `status: "APPROVED"` - Approved by admin
   - `status: "REJECTED"` - Rejected by admin
   - `rejectionReason` - Contains rejection reason (if rejected)

## Troubleshooting

### Issue: All agents stuck in PENDING_APPROVAL
- Check that your MongoDB is connected: `console.log(mongoose.connection.readyState)`
- Verify the approval endpoint is being called
- Check server logs for errors

### Issue: Agent can login despite PENDING_APPROVAL status
- Verify the loginAgent middleware is checking `agent.status === 'PENDING_APPROVAL'`
- Check that Agent model has the `status` field
- Restart the server after any model changes

### Issue: Admin token not working
- Verify admin user exists: `db.owners.find({email: "admin@agentra.com"})`
- Create admin if missing: `node create_admin.js`
- Check that admin has `role: "OWNER"`

### Issue: Endpoints returning 404
- Verify routes are registered in `src/routes/auth.routes.js`
- Check that `register-routes.js` is mounting auth routes at `/api/auth`
- Ensure Express app is calling `registerRoutes(app)`
