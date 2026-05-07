# API Endpoints Reference - Admin Dashboard

## 🔌 Backend API Documentation

All endpoints require the `x-auth-token` header with a valid JWT token.

Base URL: `http://localhost:5000/api`

---

## 📋 Authentication & Dashboard

### 1. Authenticate User
**Endpoint:** `POST /auth/signin`

**Request:**
```json
{
  "email": "admin@agentra.com",
  "password": "password123"
}
```

**Response (Success):**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "owner": {
    "_id": "507f1f77bcf86cd799439011",
    "email": "admin@agentra.com",
    "fullName": "Admin User",
    "role": "OWNER"
  }
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

---

## 👥 Agent Management Endpoints

### 2. Get Pending Agents
**Endpoint:** `GET /auth/admin/agents/pending`

**Headers:**
```
x-auth-token: <token>
```

**Response:**
```json
{
  "success": true,
  "count": 3,
  "agents": [
    {
      "_id": "507f1f77bcf86cd799439012",
      "fullName": "John Doe",
      "email": "john@example.com",
      "businessName": "Travel Co",
      "cnic": "12345-6789012-3",
      "phone": "+923001234567",
      "status": "PENDING_APPROVAL",
      "createdAt": "2024-01-15T10:00:00Z"
    }
  ]
}
```

---

### 3. Get All Agents
**Endpoint:** `GET /auth/admin/agents`

**Headers:**
```
x-auth-token: <token>
```

**Response:**
```json
{
  "success": true,
  "count": 25,
  "agents": [
    {
      "_id": "507f1f77bcf86cd799439012",
      "fullName": "John Doe",
      "email": "john@example.com",
      "businessName": "Travel Co",
      "cnic": "12345-6789012-3",
      "status": "APPROVED",
      "createdAt": "2024-01-01T00:00:00Z"
    },
    {
      "_id": "507f1f77bcf86cd799439013",
      "fullName": "Jane Smith",
      "email": "jane@example.com",
      "businessName": "Holiday Tours",
      "cnic": "98765-4321098-7",
      "status": "PENDING_APPROVAL",
      "createdAt": "2024-01-15T10:00:00Z"
    }
  ]
}
```

---

### 4. Approve Agent
**Endpoint:** `PUT /auth/admin/agents/:agentId/approve`

**Headers:**
```
x-auth-token: <token>
```

**Request Body:**
```json
{}
```

**Response:**
```json
{
  "success": true,
  "message": "Agent approved successfully",
  "agent": {
    "_id": "507f1f77bcf86cd799439012",
    "fullName": "John Doe",
    "email": "john@example.com",
    "status": "APPROVED"
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Agent not found or already approved"
}
```

---

### 5. Reject Agent
**Endpoint:** `PUT /auth/admin/agents/:agentId/reject`

**Headers:**
```
x-auth-token: <token>
```

**Request Body:**
```json
{
  "reason": "Business registration not verified"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Agent rejected successfully",
  "agent": {
    "_id": "507f1f77bcf86cd799439012",
    "fullName": "John Doe",
    "email": "john@example.com",
    "status": "REJECTED",
    "rejectionReason": "Business registration not verified"
  }
}
```

---

## 📞 Complaints Management Endpoints

### 6. Get All Complaints
**Endpoint:** `GET /api/complaints`

**Headers:**
```
x-auth-token: <token>
```

**Response:**
```json
{
  "success": true,
  "count": 5,
  "complaints": [
    {
      "_id": "507f1f77bcf86cd799439020",
      "subject": "Poor Service",
      "description": "Agent was unresponsive for 3 days",
      "status": "OPEN",
      "userId": {
        "_id": "507f1f77bcf86cd799439001",
        "fullName": "Customer Name",
        "email": "customer@example.com"
      },
      "agentId": {
        "_id": "507f1f77bcf86cd799439012",
        "fullName": "John Doe",
        "email": "john@example.com"
      },
      "createdAt": "2024-01-14T15:30:00Z",
      "updatedAt": "2024-01-14T15:30:00Z"
    }
  ]
}
```

---

### 7. Update Complaint Status
**Endpoint:** `PUT /api/complaints/:complaintId`

**Headers:**
```
x-auth-token: <token>
```

**Request Body:**
```json
{
  "status": "IN_PROGRESS",
  "ownerResponse": "We are investigating this issue"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Complaint updated successfully",
  "complaint": {
    "_id": "507f1f77bcf86cd799439020",
    "subject": "Poor Service",
    "status": "IN_PROGRESS",
    "ownerResponse": "We are investigating this issue",
    "updatedAt": "2024-01-15T10:00:00Z"
  }
}
```

---

## 📝 System Logs Endpoints

### 8. Get System Logs
**Endpoint:** `GET /api/logs`

**Headers:**
```
x-auth-token: <token>
```

**Response:**
```json
{
  "success": true,
  "count": 50,
  "logs": [
    {
      "timestamp": "2024-01-15T14:30:00Z",
      "level": "INFO",
      "event": "User Login",
      "details": "Admin logged into dashboard"
    },
    {
      "timestamp": "2024-01-15T14:25:00Z",
      "level": "WARN",
      "event": "Failed Login Attempt",
      "details": "Invalid password for admin@agentra.com"
    },
    {
      "timestamp": "2024-01-15T14:20:00Z",
      "level": "ERROR",
      "event": "Database Connection Error",
      "details": "Connection timeout - retrying..."
    }
  ]
}
```

---

## 📊 Analytics/Dashboard Endpoints

### 9. Get Dashboard Statistics
**Endpoint:** `GET /api/dashboard/owner`

**Headers:**
```
x-auth-token: <token>
```

**Response:**
```json
{
  "success": true,
  "statistics": {
    "totalUsers": 150,
    "totalAgents": 25,
    "totalBookings": 320,
    "totalComplaints": 12,
    "agents": {
      "approved": 20,
      "pending": 3,
      "rejected": 2
    },
    "complaints": {
      "open": 5,
      "inProgress": 3,
      "resolved": 4
    }
  }
}
```

---

## 🧪 Testing Commands

### Using cURL

#### Test 1: Signin
```bash
curl -X POST http://localhost:5000/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@agentra.com",
    "password": "password123"
  }'
```

#### Test 2: Get Pending Agents
```bash
curl -X GET http://localhost:5000/api/auth/admin/agents/pending \
  -H "x-auth-token: YOUR_TOKEN_HERE"
```

#### Test 3: Approve Agent
```bash
curl -X PUT http://localhost:5000/api/auth/admin/agents/AGENT_ID/approve \
  -H "x-auth-token: YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{}'
```

#### Test 4: Reject Agent
```bash
curl -X PUT http://localhost:5000/api/auth/admin/agents/AGENT_ID/reject \
  -H "x-auth-token: YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Documentation not verified"
  }'
```

#### Test 5: Get Complaints
```bash
curl -X GET http://localhost:5000/api/complaints \
  -H "x-auth-token: YOUR_TOKEN_HERE"
```

#### Test 6: Get System Logs
```bash
curl -X GET http://localhost:5000/api/logs \
  -H "x-auth-token: YOUR_TOKEN_HERE"
```

#### Test 7: Get Analytics
```bash
curl -X GET http://localhost:5000/api/dashboard/owner \
  -H "x-auth-token: YOUR_TOKEN_HERE"
```

---

### Using Postman

1. **Create Collection:** "Agentra Admin"
2. **Create Variable:** 
   - Variable: `BASE_URL` = `http://localhost:5000/api`
   - Variable: `TOKEN` = (set after signin)

3. **Create Requests:**

   **Signin (Get Token)**
   ```
   Method: POST
   URL: {{BASE_URL}}/auth/signin
   Body (raw JSON):
   {
     "email": "admin@agentra.com",
     "password": "password123"
   }
   ```
   *Copy token from response and set as TOKEN variable*

   **Get Pending Agents**
   ```
   Method: GET
   URL: {{BASE_URL}}/auth/admin/agents/pending
   Headers: x-auth-token = {{TOKEN}}
   ```

   **Approve Agent**
   ```
   Method: PUT
   URL: {{BASE_URL}}/auth/admin/agents/AGENT_ID/approve
   Headers: x-auth-token = {{TOKEN}}
   Body: {}
   ```

   **Get Complaints**
   ```
   Method: GET
   URL: {{BASE_URL}}/complaints
   Headers: x-auth-token = {{TOKEN}}
   ```

---

## 📊 Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | Success | Agent retrieved, data returned |
| 201 | Created | New resource created |
| 400 | Bad Request | Invalid JSON or missing fields |
| 401 | Unauthorized | Missing or invalid token |
| 403 | Forbidden | User doesn't have permission |
| 404 | Not Found | Agent/Complaint not found |
| 500 | Server Error | Database error, server issue |

---

## 🔐 Authentication Error Responses

### Missing Token
```json
{
  "success": false,
  "message": "No token, authorization denied"
}
```

### Invalid Token
```json
{
  "success": false,
  "message": "Token is not valid"
}
```

### Expired Token
```json
{
  "success": false,
  "message": "Token is expired"
}
```

### Insufficient Permissions
```json
{
  "success": false,
  "message": "Not authorized to access this resource"
}
```

---

## 🐛 Common Issues & Solutions

### Issue: 401 Unauthorized
**Possible Causes:**
- Token not sent in header
- Token is expired
- Token is malformed

**Solution:**
1. Include `x-auth-token` header
2. Make sure token is valid JWT
3. Login again if token expired

---

### Issue: 404 Not Found
**Possible Causes:**
- Agent/Complaint ID doesn't exist
- Endpoint URL is wrong
- Resource was deleted

**Solution:**
1. Verify ID is correct and exists in database
2. Check URL spelling
3. Get list of valid IDs first

---

### Issue: 500 Server Error
**Possible Causes:**
- Database connection failed
- Backend crashed
- Invalid data sent

**Solution:**
1. Check backend is running
2. Check MongoDB is connected
3. Check request format is correct
4. Look at backend console for error details

---

## 🚀 Quick Testing Script

```bash
# Save as test-api.sh

TOKEN=""

# 1. Get Token
echo "Getting token..."
RESPONSE=$(curl -s -X POST http://localhost:5000/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@agentra.com","password":"password123"}')

TOKEN=$(echo $RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo "Token: $TOKEN"

# 2. Get Pending Agents
echo "Getting pending agents..."
curl -s -X GET http://localhost:5000/api/auth/admin/agents/pending \
  -H "x-auth-token: $TOKEN" | json_pp

# 3. Get All Agents
echo "Getting all agents..."
curl -s -X GET http://localhost:5000/api/auth/admin/agents \
  -H "x-auth-token: $TOKEN" | json_pp

# 4. Get Complaints
echo "Getting complaints..."
curl -s -X GET http://localhost:5000/api/complaints \
  -H "x-auth-token: $TOKEN" | json_pp

# 5. Get Logs
echo "Getting logs..."
curl -s -X GET http://localhost:5000/api/logs \
  -H "x-auth-token: $TOKEN" | json_pp

# 6. Get Analytics
echo "Getting analytics..."
curl -s -X GET http://localhost:5000/api/dashboard/owner \
  -H "x-auth-token: $TOKEN" | json_pp
```

Run with: `bash test-api.sh`

---

## 📚 Additional Resources

- **Backend Code:** `agentra-backend/src/`
- **Frontend Code:** `agentra/app/admin/`
- **API Service:** `agentra/lib/api.ts`
- **Tests:** `agentra-backend/test-*.js`

---

## ✅ API Endpoint Status

All endpoints are:
- ✅ Implemented
- ✅ Connected to MongoDB
- ✅ Protected with JWT authentication
- ✅ Tested and working
- ✅ Connected to frontend

Ready for production use! 🚀
