# Quick Reference: Admin Approval Workflow

## Quick Start

### Backend Endpoints

#### 1. Register New Agent (Public)
```bash
POST /api/auth/agent/register
Content-Type: application/json

{
  "fullName": "John Doe",
  "businessName": "John's Travels",
  "email": "john@example.com",
  "phone": "1234567890",
  "cnic": "12345-1234567-1",
  "password": "securePassword123"
}

RESPONSE (201):
{
  "success": true,
  "message": "Your account request has been submitted. Please wait for admin approval. This may take up to 24 hours.",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "agent": { ... },
  "status": "PENDING_APPROVAL"
}
```

#### 2. Agent Login (with Status Check)
```bash
POST /api/auth/agent/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "securePassword123"
}

RESPONSE if PENDING_APPROVAL (403):
{
  "success": false,
  "message": "Your account is not yet approved by admin."
}

RESPONSE if REJECTED (403):
{
  "success": false,
  "message": "Your account has been rejected. Please contact admin."
}

RESPONSE if APPROVED (200):
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "agent": { ... }
}
```

#### 3. Admin: Get Pending Agents
```bash
GET /api/auth/admin/agents/pending
Authorization: Bearer {OWNER_TOKEN}
x-auth-token: {OWNER_TOKEN}

RESPONSE (200):
{
  "success": true,
  "count": 3,
  "agents": [
    {
      "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
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

#### 4. Admin: Approve Agent
```bash
PUT /api/auth/admin/agents/{agentId}/approve
Authorization: Bearer {OWNER_TOKEN}
x-auth-token: {OWNER_TOKEN}
Content-Type: application/json

RESPONSE (200):
{
  "success": true,
  "message": "Agent approved successfully",
  "agent": {
    "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
    "fullName": "John Doe",
    "email": "john@example.com",
    "status": "APPROVED",
    ...
  }
}

RESPONSE if not PENDING_APPROVAL (400):
{
  "success": false,
  "message": "Agent is not in pending approval status"
}
```

#### 5. Admin: Reject Agent
```bash
PUT /api/auth/admin/agents/{agentId}/reject
Authorization: Bearer {OWNER_TOKEN}
x-auth-token: {OWNER_TOKEN}
Content-Type: application/json

{
  "reason": "Does not meet business requirements"
}

RESPONSE (200):
{
  "success": true,
  "message": "Agent rejected successfully",
  "agent": {
    "_id": "60f7b3c5c5d8e1b8a4c5d6e7",
    "fullName": "John Doe",
    "status": "REJECTED",
    "rejectionReason": "Does not meet business requirements",
    ...
  }
}
```

## Status Values

| Status | Meaning | Can Login? | Can Create Packages? |
|--------|---------|-----------|----------------------|
| PENDING_APPROVAL | Awaiting admin review | ❌ No | ❌ No |
| APPROVED | Approved by admin | ✅ Yes | ✅ Yes (if verified) |
| REJECTED | Rejected by admin | ❌ No | ❌ No |

## Agent Status Lifecycle

```
Sign Up → PENDING_APPROVAL → (Admin Decision)
                              ├→ APPROVED → Can Login/Create Packages
                              └→ REJECTED → Cannot Login
```

## Key Implementation Details

1. **Default Status**: All new agents default to `PENDING_APPROVAL`
2. **Token Generation**: Even pending agents get a token, but login will fail
3. **Package Creation**: Requires both `status: APPROVED` AND `isVerified: true`
4. **Email Verification**: Still separate from approval status
5. **Rejection Reason**: Optional when rejecting agents

## Flutter Integration Example

```dart
// Get pending agents
final agents = await AdminService.getPendingAgents();

// Approve an agent
final success = await AdminService.approveAgent(agentId);

// Reject an agent with reason
final rejected = await AdminService.rejectAgentApproval(
  agentId,
  reason: 'Does not meet requirements'
);
```

## Error Codes

| Code | Scenario | Message |
|------|----------|---------|
| 201 | Agent registered (pending) | "Your account request has been submitted..." |
| 200 | Login successful | "Login successful" |
| 403 | Pending approval | "Your account is not yet approved by admin." |
| 403 | Rejected | "Your account has been rejected. Please contact admin." |
| 403 | Email not verified | "Account not verified" |
| 404 | Agent not found | "Agent not found" |
| 400 | Wrong status | "Agent is not in pending approval status" |

## Testing Checklist

- [ ] Agent can signup and get PENDING_APPROVAL status
- [ ] Agent cannot login while PENDING_APPROVAL
- [ ] Admin can retrieve list of pending agents
- [ ] Admin can approve agent
- [ ] Agent can login after approval
- [ ] Agent can create packages after approval and email verification
- [ ] Admin can reject agent
- [ ] Rejected agent cannot login
- [ ] Dashboard shows correct counts
- [ ] Rejection reason is stored

## Common Workflows

### Workflow 1: Quick Approval
1. Agent signs up → status: PENDING_APPROVAL
2. Admin reviews agent details
3. Admin clicks "Approve" → status: APPROVED
4. Agent logs in successfully
5. Agent creates packages

### Workflow 2: Rejection
1. Agent signs up → status: PENDING_APPROVAL
2. Admin reviews and finds issues
3. Admin clicks "Reject" with reason → status: REJECTED
4. Agent tries to login → "Your account has been rejected"
5. Agent contacts admin for more information

### Workflow 3: Admin Dashboard
1. Admin logs in
2. Dashboard shows: 5 pending, 35 approved, 3 rejected agents
3. Admin clicks "Manage Pending Agents"
4. System shows all PENDING_APPROVAL agents
5. Admin can approve/reject each one

## Important Notes

- **No Breaking Changes**: Existing functionality remains intact
- **Two-Step Verification**: Status (approval) + isVerified (email) both required
- **Audit Trail**: Rejection reasons are stored for reference
- **Immediate Effect**: Status changes take effect immediately (no caching)
- **Token Issued**: Even pending agents get a token (prevents frontend confusion)
