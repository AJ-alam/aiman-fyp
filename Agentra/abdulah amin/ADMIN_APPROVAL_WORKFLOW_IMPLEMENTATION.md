# Travel Agent Admin Approval Workflow Implementation

## Overview
This document outlines the implementation of the admin approval workflow for travel agents. The system now requires admin approval before agents can log in and access features.

## Database Changes

### Agent Model Updates
**File**: `agentra-backend/src/models/Agent.js`

Added two new fields to the Agent schema:

1. **status** (String, Enum)
   - Values: `PENDING_APPROVAL`, `APPROVED`, `REJECTED`
   - Default: `PENDING_APPROVAL`
   - Used to track the approval state of agent accounts

2. **rejectionReason** (String)
   - Default: empty string
   - Stores the reason when an admin rejects an agent

## Backend API Changes

### 1. Modified Authentication Flow

#### Registration (POST `/api/auth/agent/register`)
- **Before**: Agent was created with no approval status
- **After**: Agent is created with `status: PENDING_APPROVAL`
- **Response Message**: 
  ```
  "Your account request has been submitted. Please wait for admin approval. This may take up to 24 hours."
  ```
- **Response Format**:
  ```json
  {
    "success": true,
    "message": "Your account request has been submitted...",
    "token": "jwt_token",
    "agent": {...},
    "status": "PENDING_APPROVAL"
  }
  ```

#### Login (POST `/api/auth/agent/login`)
- **New Status Checks**:
  1. If `status === 'PENDING_APPROVAL'`: 
     - Return 403 with message: `"Your account is not yet approved by admin."`
  2. If `status === 'REJECTED'`: 
     - Return 403 with message: `"Your account has been rejected. Please contact admin."`
  3. If `isVerified === false`: 
     - Return 403 with message: `"Account not verified"`
  4. Otherwise: Allow login with token

### 2. New Admin Approval APIs

#### Get Pending Agents (GET `/api/auth/admin/agents/pending`)
- **Authentication**: Required (OWNER role)
- **Description**: Retrieves all agents with `status: PENDING_APPROVAL`
- **Response**:
  ```json
  {
    "success": true,
    "count": 5,
    "agents": [
      {
        "_id": "agent_id",
        "fullName": "John Doe",
        "email": "john@example.com",
        "businessName": "John's Travels",
        "phone": "1234567890",
        "status": "PENDING_APPROVAL",
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ]
  }
  ```

#### Approve Agent (PUT `/api/auth/admin/agents/:agentId/approve`)
- **Authentication**: Required (OWNER role)
- **Parameter**: `agentId` (Agent MongoDB ID)
- **Validation**: Agent must be in `PENDING_APPROVAL` status
- **Action**: Changes `status` from `PENDING_APPROVAL` to `APPROVED`
- **Response**:
  ```json
  {
    "success": true,
    "message": "Agent approved successfully",
    "agent": {
      "_id": "agent_id",
      "fullName": "John Doe",
      "status": "APPROVED",
      ...
    }
  }
  ```
- **Error Responses**:
  - 404: Agent not found
  - 400: Agent is not in pending approval status

#### Reject Agent (PUT `/api/auth/admin/agents/:agentId/reject`)
- **Authentication**: Required (OWNER role)
- **Parameter**: `agentId` (Agent MongoDB ID)
- **Body**:
  ```json
  {
    "reason": "Optional rejection reason"
  }
  ```
- **Validation**: Agent must be in `PENDING_APPROVAL` status
- **Action**: Changes `status` to `REJECTED` and stores rejection reason
- **Response**:
  ```json
  {
    "success": true,
    "message": "Agent rejected successfully",
    "agent": {
      "_id": "agent_id",
      "status": "REJECTED",
      "rejectionReason": "Does not meet requirements",
      ...
    }
  }
  ```

### 3. Updated Package Creation

**File**: `agentra-backend/src/controllers/agent.controller.js`

The `createPackage` endpoint now checks:
1. Agent status must be `APPROVED` (new requirement)
2. Agent must have `isVerified === true` (existing requirement)

**Error Messages**:
- If not approved: `"Your account must be approved by admin to create packages"`
- If email not verified: `"Agent email must be verified"`

### 4. Enhanced Owner Dashboard

**File**: `agentra-backend/src/controllers/dashboard.controller.js`

The owner dashboard now returns additional metrics:
```json
{
  "success": true,
  "totalUsers": 100,
  "totalAgents": 45,
  "pendingAgents": 5,      // NEW: Agents pending approval
  "approvedAgents": 35,    // NEW: Approved agents
  "rejectedAgents": 5,     // NEW: Rejected agents
  "totalBookings": 200,
  "totalComplaints": 3
}
```

## Frontend Changes

### Flutter Admin Service Updates
**File**: `agentra_travelagent/lib/services/admin_service.dart`

Added three new methods:

1. **getPendingAgents()**
   - Fetches agents with pending approval status
   - Returns: `List<dynamic>` of agents

2. **approveAgent(String agentId)**
   - Approves an agent
   - Returns: `bool` (success status)

3. **rejectAgentApproval(String agentId, {String? reason})**
   - Rejects an agent with optional reason
   - Returns: `bool` (success status)

## User Experience Flow

### For Travel Agents

1. **Signup**
   - Agent registers with required information
   - System displays: "Your account request has been submitted. Please wait for admin approval. This may take up to 24 hours."
   - Agent can see their profile but cannot create packages yet

2. **Login (Before Approval)**
   - Attempt to login shows: "Your account is not yet approved by admin."
   - Login fails with 403 Forbidden

3. **After Approval**
   - Admin approves the agent (status changes to APPROVED)
   - Agent can now login normally
   - After login, agent can create packages and access all features

4. **If Rejected**
   - Agent sees: "Your account has been rejected. Please contact admin."
   - Agent cannot login or create packages

### For Admin/Owner

1. **Monitor Pending Agents**
   - View list of pending agents via: GET `/api/auth/admin/agents/pending`
   - Dashboard shows count of pending agents

2. **Review Requests**
   - Admin reviews agent details
   - Can approve or reject each request

3. **Approve Agent**
   - Click approve button (calls: PUT `/api/auth/admin/agents/:agentId/approve`)
   - Agent status changes to APPROVED
   - Agent can now login and create packages

4. **Reject Agent**
   - Click reject button (calls: PUT `/api/auth/admin/agents/:agentId/reject`)
   - Agent status changes to REJECTED
   - Optional rejection reason can be provided
   - Agent sees rejection message on next login attempt

## API Summary

| Method | Endpoint | Role | Purpose |
|--------|----------|------|---------|
| POST | `/api/auth/agent/register` | Public | Register new agent (status: PENDING_APPROVAL) |
| POST | `/api/auth/agent/login` | Public | Login agent (checks approval status) |
| GET | `/api/auth/admin/agents/pending` | OWNER | Get all pending agents |
| PUT | `/api/auth/admin/agents/:agentId/approve` | OWNER | Approve pending agent |
| PUT | `/api/auth/admin/agents/:agentId/reject` | OWNER | Reject pending agent |

## Backward Compatibility

- Existing authentication methods remain unchanged
- `isVerified` field still works for email verification
- Existing verify/block agent endpoints remain functional
- New `status` field is independent of `isVerified`
- Agents must be both APPROVED (status) and verified (isVerified) to create packages

## Database Migration Note

No migration script is needed. The `status` field defaults to `PENDING_APPROVAL` for new agents, and defaults to `PENDING_APPROVAL` for existing agents when they're first queried (MongoDB schema-less behavior).

However, if you want to set existing agents to `APPROVED` automatically, you can run:
```javascript
db.agents.updateMany(
  { status: { $exists: false } }, 
  { $set: { status: "APPROVED" } }
)
```

## Testing Recommendations

1. **Agent Signup**: Verify agent is created with PENDING_APPROVAL status
2. **Agent Login Before Approval**: Verify login fails with proper message
3. **Admin Approval**: Verify agent can login after approval
4. **Package Creation**: Verify agent can create packages only if APPROVED and isVerified
5. **Dashboard**: Verify admin sees correct counts of pending/approved/rejected agents
6. **Agent Rejection**: Verify agent sees rejection message and cannot login

## Security Notes

- All admin endpoints require OWNER role authentication
- JWT tokens are validated before granting access
- Rejection reasons are logged in database
- Status changes are immediate (no caching issues)
