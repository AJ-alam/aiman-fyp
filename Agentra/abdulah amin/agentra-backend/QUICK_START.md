# ⚡ QUICK START - RUN THIS NOW

## 🎯 Get Proof That It Works (5 minutes)

### Step 1️⃣: Terminal 1 - Start Server
```bash
cd e:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah\ amin\agentra-backend
npm install
node server.js
```

**You should see:**
```
✅ MongoDB Connected
🚀 Server running on 5000
```

---

### Step 2️⃣: Terminal 2 - Create Admin (one-time only)
```bash
cd e:\khizar\pull\agentra\agentra-main\agentra-main\Agentra\abdulah\ amin\agentra-backend
node create_admin.js
```

**You should see:**
```
✅ Admin created successfully
```

If you see "Admin already exists" - that's fine, skip this step next time.

---

### Step 3️⃣: Terminal 2 - Run Verification Test
```bash
node RUNTIME_VERIFICATION_TEST.js
```

**Watch the output** - You will see:

✅ TEST 1: Admin login successful
✅ TEST 2: Agent signup with PENDING_APPROVAL status
✅ TEST 3: Pending agent login BLOCKED (403)
✅ TEST 4: Admin fetches pending agents
✅ TEST 5: Admin approves agent
✅ TEST 6: Agent 2 signs up
✅ TEST 7: Admin rejects agent 2
✅ TEST 8: Approved agent login SUCCEEDS
✅ TEST 9: Rejected agent login BLOCKED (403)

```
═════════════════════════════════════════════════════════════════
✓ ALL TESTS COMPLETED SUCCESSFULLY
═════════════════════════════════════════════════════════════════
```

---

### Step 4️⃣: Watch Terminal 1 Logs

While test is running, look at **Terminal 1** and verify you see:

```
📝 [SIGNUP] Agent registration attempt
✅ [SIGNUP] Agent created with status: PENDING_APPROVAL

🔐 [LOGIN] Agent login attempt
⏳ [LOGIN] Account pending approval

👤 [APPROVE] Approval attempt for agent
✅ [APPROVE] Agent approved successfully

🚫 [REJECT] Rejection attempt for agent
✅ [REJECT] Agent rejected successfully
```

---

### Step 5️⃣: Check Database (Optional)

In MongoDB, run:
```javascript
db.agents.find({}, {email: 1, status: 1, rejectionReason: 1}).pretty()
```

**You should see:**
- Some agents with `status: "APPROVED"`
- Some agents with `status: "REJECTED"` and reason

---

## ✅ SUCCESS = All 9 Tests Pass

If you see **9 green checkmarks (✅)** and **"ALL TESTS COMPLETED SUCCESSFULLY"**, then:

🎉 **THE SYSTEM IS WORKING**

✅ Agents can sign up
✅ Database stores status
✅ Pending agents cannot login
✅ Admin can approve agents
✅ Approved agents can login
✅ Admin can reject agents
✅ Rejected agents cannot login

---

## ❌ IF TESTS FAIL

### Error: Cannot connect to MongoDB
```bash
# Start MongoDB
mongod

# Or if using Docker
docker run -d -p 27017:27017 mongo
```

### Error: Admin not found
```bash
# Create admin
node create_admin.js
```

### Error: Test won't start
```bash
# Make sure backend server is running in Terminal 1
# Check: http://localhost:5000/health should return 200

# Check server terminal for errors
```

---

## 📊 WHAT YOU GET

After this 5-minute test, you have PROOF that:

| Feature | Proof |
|---------|-------|
| Agents can signup | ✅ TEST 2 response shows PENDING_APPROVAL |
| Status saved in DB | ✅ Server logs and database show status |
| Pending can't login | ✅ TEST 3 gets 403 error |
| Admin can fetch pending | ✅ TEST 4 returns list |
| Admin can approve | ✅ TEST 5 changes status to APPROVED |
| Approved can login | ✅ TEST 8 gets JWT token |
| Admin can reject | ✅ TEST 7 changes status to REJECTED |
| Rejected can't login | ✅ TEST 9 gets 403 error |
| Console logs work | ✅ Terminal 1 shows all logs |

---

## 📖 NEXT: Read Full Guides

After quick start works, read for deeper understanding:

1. **END_TO_END_VERIFICATION_GUIDE.md** - Detailed step-by-step with curl examples
2. **API_REFERENCE.md** - Exact request/response format
3. **CRITICAL_BUG_FIX.md** - What was broken and how it was fixed

---

## 🚀 THEN: Update Frontend

Once backend is verified:

### Flutter Agent App (agentra_travelagent)
Show message after signup:
```dart
if (response['status'] == 'PENDING_APPROVAL') {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Your account request has been submitted. '
        'Please wait for admin approval (within 24 hours).'
      ),
    ),
  );
  // Don't navigate to dashboard
}
```

### Frontend Admin (Next.js)
Add approval screen to view pending agents and approve/reject them.

---

## 🎯 COMPLETE FLOW

```
User Signs Up
    ↓
Backend creates agent with status: PENDING_APPROVAL
    ↓
Frontend shows "Waiting for approval" message
    ↓
User tries to login → BLOCKED (403)
    ↓
Admin views pending agents
    ↓
Admin approves OR rejects agent
    ↓
If approved:
    User can login → Gets JWT token ✅
If rejected:
    User cannot login → Gets error message ❌
```

---

## 📝 TEST DATA REFERENCE

The automated test creates:

**Admin:**
- Email: `admin@agentra.com`
- Password: `admin123`

**Test Agents:**
- Test 2: `agent1-[random]@test.com` → Status becomes APPROVED
- Test 6: `agent2-[random]@test.com` → Status becomes REJECTED

Each run creates NEW test data, so you can run multiple times.

---

## 🔐 AUTHENTICATION

Protected endpoints require:
```
Header: x-auth-token: [JWT_TOKEN]
```

Get token from:
1. Admin login → use for admin endpoints
2. Agent login (after approved) → use for agent endpoints

---

## 💡 TROUBLESHOOTING QUICK REFERENCE

| Problem | Solution |
|---------|----------|
| MongoDB error | `mongod` or check MONGO_URI in .env |
| Admin not found | `node create_admin.js` |
| Test hangs | Ctrl+C and restart server |
| Port 5000 in use | Kill other process or use different port |
| Console logs missing | Restart server with `node server.js` |
| Database not updating | Check MongoDB connection |

---

## ✨ THAT'S IT!

```
Step 1: node server.js
Step 2: node create_admin.js
Step 3: node RUNTIME_VERIFICATION_TEST.js
Step 4: Watch output
Step 5: Check database

DONE! ✅
```

**Expected time: 5 minutes**

Questions? Check the detailed guides:
- END_TO_END_VERIFICATION_GUIDE.md
- API_REFERENCE.md
- CRITICAL_BUG_FIX.md
