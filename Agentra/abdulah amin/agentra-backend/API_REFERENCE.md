# 🔌 API REFERENCE - EXACT REQUEST/RESPONSE FORMAT

## ✅ What Status Values Are Used

The system uses these EXACT status strings in the database and API:
- `PENDING_APPROVAL` - Agent signed up, waiting for admin approval
- `APPROVED` - Admin approved the agent, can now login
- `REJECTED` - Admin rejected the agent, cannot login

---

## 📤 ENDPOINT 1: Agent Signup

### Request
```
POST /api/auth/agent/register
Content-Type: application/json

{
  "fullName": "John Doe",
  "email": "john@test.com",
  "businessName": "John's Tours",
  "phone": "+923001234567",
  "cnic": "12345-1234567-1",
  "password": "SecurePass123!"
}
```

### Response (201 CREATED)
```json
{
  "success": true,
  "message": "Your account request has been submitted. Please wait for admin approval. This may take up to 24 hours.",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYwZjdiM2M1YzVkOGUxYjhhNGM1ZDZlNyIsInJvbGUiOiJBR0VOVCIsImlhdCI6MTcxNDQ2NDY0NSwiZXhwIjoxNzE1MDY5NDQ1fQ.4Zo8sNl4Z0g...",
  "agent": {
    "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
    "fullName": "John Doe",
    "email": "john@test.com",
    "businessName": "John's Tours",
    "phone": "+923001234567",
    "status": "PENDING_APPROVAL",
    "isVerified": false,
    "role": "AGENT",
    "createdAt": "2024-04-30T10:30:45.123Z"
  },
  "status": "PENDING_APPROVAL"
}
```

✅ **Key Points:**
- Response includes `status: "PENDING_APPROVAL"`
- Response includes approval message
- Database now has this agent with `status: PENDING_APPROVAL`
- Token is returned (but agent can't use it yet)

---

## 🔐 ENDPOINT 2: Agent Login (When PENDING_APPROVAL)

### Request
```
POST /api/auth/agent/login
Content-Type: application/json

{
  "email": "john@test.com",
  "password": "SecurePass123!"
}
```

### Response (403 FORBIDDEN)
```json
{
  "success": false,
  "message": "Your account is not yet approved by admin."
}
```

❌ **Key Points:**
- Status code is 403 (Forbidden)
- No token returned
- Agent CANNOT login while pending
- Message tells agent to wait for approval

---

## 👤 ENDPOINT 3: Get Pending Agents (Admin Only)

### Request
```
GET /api/auth/admin/agents/pending
x-auth-token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response (200 OK)
```json
{
  "success": true,
  "count": 2,
  "agents": [
    {
      "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
      "fullName": "John Doe",
      "email": "john@test.com",
      "businessName": "John's Tours",
      "phone": "+923001234567",
      "status": "PENDING_APPROVAL",
      "isVerified": false,
      "createdAt": "2024-04-30T10:30:45.123Z"
    },
    {
      "_id": "60f7b3c5c5d8e1b8a4c5d6e8",
      "fullName": "Jane Smith",
      "email": "jane@test.com",
      "businessName": "Jane Travels",
      "phone": "+923001234568",
      "status": "PENDING_APPROVAL",
      "isVerified": false,
      "createdAt": "2024-04-30T10:31:00.456Z"
    }
  ]
}
```

✅ **Key Points:**
- Returns list of ALL agents with `status: PENDING_APPROVAL`
- Count shows total pending agents
- Admin sees email and business details
- Password is NOT returned (selected -password)

---

## ✅ ENDPOINT 4: Approve Agent (Admin Only)

### Request
```
PUT /api/auth/admin/agents/60f7b3c5c5d8e1b8a4c5d6e7/approve
x-auth-token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{}
```

### Response (200 OK)
```json
{
  "success": true,
  "message": "Agent approved successfully",
  "agent": {
    "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
    "fullName": "John Doe",
    "email": "john@test.com",
    "businessName": "John's Tours",
    "phone": "+923001234567",
    "status": "APPROVED",
    "isVerified": false,
    "createdAt": "2024-04-30T10:30:45.123Z",
    "updatedAt": "2024-04-30T10:32:00.789Z"
  }
}
```

✅ **Key Points:**
- Agent status changed from `PENDING_APPROVAL` to `APPROVED`
- `updatedAt` timestamp updated
- Agent can now login
- Database is actually updated

---

## ❌ ENDPOINT 5: Reject Agent (Admin Only)

### Request
```
PUT /api/auth/admin/agents/60f7b3c5c5d8e1b8a4c5d6e8/reject
x-auth-token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "reason": "Business verification failed"
}
```

### Response (200 OK)
```json
{
  "success": true,
  "message": "Agent rejected successfully",
  "agent": {
    "_id": "60f7b3c5c5d8e1b8a4c5d6e8",
    "fullName": "Jane Smith",
    "email": "jane@test.com",
    "businessName": "Jane Travels",
    "phone": "+923001234568",
    "status": "REJECTED",
    "rejectionReason": "Business verification failed",
    "isVerified": false,
    "createdAt": "2024-04-30T10:31:00.456Z",
    "updatedAt": "2024-04-30T10:33:15.234Z"
  }
}
```

✅ **Key Points:**
- Agent status changed from `PENDING_APPROVAL` to `REJECTED`
- `rejectionReason` field populated with admin's reason
- Agent cannot login anymore
- Database stores rejection reason

---

## 🔐 ENDPOINT 6: Approved Agent Login (SHOULD SUCCEED)

### Request
```
POST /api/auth/agent/login
Content-Type: application/json

{
  "email": "john@test.com",
  "password": "SecurePass123!"
}
```

### Response (200 OK)
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYwZjdiM2M1YzVkOGUxYjhhNGM1ZDZlNyIsInJvbGUiOiJBR0VOVCIsImlhdCI6MTcxNDQ2NDY0NSwiZXhwIjoxNzE1MDY5NDQ1fQ.4Zo8sNl4Z0g...",
  "agent": {
    "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
    "fullName": "John Doe",
    "email": "john@test.com",
    "businessName": "John's Tours",
    "phone": "+923001234567",
    "status": "APPROVED",
    "isVerified": false,
    "role": "AGENT",
    "createdAt": "2024-04-30T10:30:45.123Z"
  }
}
```

✅ **Key Points:**
- Status code is 200 (OK)
- JWT token is returned
- Agent can now access protected endpoints
- Status is `APPROVED`

---

## ❌ ENDPOINT 7: Rejected Agent Login (SHOULD FAIL)

### Request
```
POST /api/auth/agent/login
Content-Type: application/json

{
  "email": "jane@test.com",
  "password": "SecurePass123!"
}
```

### Response (403 FORBIDDEN)
```json
{
  "success": false,
  "message": "Your account has been rejected. Please contact admin."
}
```

❌ **Key Points:**
- Status code is 403 (Forbidden)
- No token returned
- Agent CANNOT login
- Message tells agent to contact admin

---

## 📊 DATABASE RECORDS AFTER OPERATIONS

### Record 1: Approved Agent (after approval)
```json
{
  "_id": ObjectId("60f7b3c5c5d8e1b8a4c5d6e7"),
  "fullName": "John Doe",
  "email": "john@test.com",
  "businessName": "John's Tours",
  "phone": "+923001234567",
  "cnic": "12345-1234567-1",
  "status": "APPROVED",
  "rejectionReason": "",
  "isVerified": false,
  "role": "AGENT",
  "password": "$2a$10$...",
  "createdAt": ISODate("2024-04-30T10:30:45.123Z"),
  "updatedAt": ISODate("2024-04-30T10:32:00.789Z")
}
```

### Record 2: Rejected Agent (after rejection)
```json
{
  "_id": ObjectId("60f7b3c5c5d8e1b8a4c5d6e8"),
  "fullName": "Jane Smith",
  "email": "jane@test.com",
  "businessName": "Jane Travels",
  "phone": "+923001234568",
  "cnic": "98765-9876543-9",
  "status": "REJECTED",
  "rejectionReason": "Business verification failed",
  "isVerified": false,
  "role": "AGENT",
  "password": "$2a$10$...",
  "createdAt": ISODate("2024-04-30T10:31:00.456Z"),
  "updatedAt": ISODate("2024-04-30T10:33:15.234Z")
}
```

---

## 🔍 ERROR RESPONSES

### Error: Agent Not Found
```json
{
  "success": false,
  "message": "Agent not found"
}
```

### Error: Invalid Credentials
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

### Error: Not in Pending Status (can't approve already approved agent)
```json
{
  "success": false,
  "message": "Agent is not in pending approval status"
}
```

### Error: Unauthorized (admin tries to access without token)
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

---

## 📋 SUMMARY TABLE

| Operation | Endpoint | Method | Status | Can Login? |
|-----------|----------|--------|--------|-----------|
| Signup | `/auth/agent/register` | POST | `PENDING_APPROVAL` | ❌ No (403) |
| Approve | `/auth/admin/agents/:id/approve` | PUT | `APPROVED` | ✅ Yes (200) |
| Reject | `/auth/admin/agents/:id/reject` | PUT | `REJECTED` | ❌ No (403) |
| Login (Pending) | `/auth/agent/login` | POST | - | ❌ 403 Error |
| Login (Approved) | `/auth/agent/login` | POST | - | ✅ 200 + Token |
| Login (Rejected) | `/auth/agent/login` | POST | - | ❌ 403 Error |

---

## ✅ RUNTIME VALIDATION CHECKLIST

Use these exact checks to validate:

### After Signup
```bash
curl -s http://localhost:5000/api/auth/agent/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com",...}' | jq '.agent.status'
# Should output: "PENDING_APPROVAL"
```

### After Pending Login Attempt
```bash
curl -s -w "\nStatus: %{http_code}\n" http://localhost:5000/api/auth/agent/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"..."}' | jq '.message'
# Should output: "Your account is not yet approved by admin."
# Status: 403
```

### After Approval
```bash
curl -s http://localhost:5000/api/auth/admin/agents/ID/approve \
  -X PUT -H "x-auth-token: TOKEN" | jq '.agent.status'
# Should output: "APPROVED"
```

### After Approved Login
```bash
curl -s http://localhost:5000/api/auth/agent/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"..."}' | jq '.token'
# Should output: JWT token (not null, not empty)
```

---

## 🎯 WHAT PROVES IT WORKS

✅ Signup response includes `status: "PENDING_APPROVAL"`
✅ Pending agent login returns 403 error
✅ Database record has `status: "PENDING_APPROVAL"`
✅ Admin can fetch pending agents list
✅ Admin approval changes status to `APPROVED` in database
✅ Approved agent can login and get JWT token
✅ Admin rejection changes status to `REJECTED` with reason
✅ Rejected agent login returns 403 error with rejection message
✅ Server console logs show flow at each step
