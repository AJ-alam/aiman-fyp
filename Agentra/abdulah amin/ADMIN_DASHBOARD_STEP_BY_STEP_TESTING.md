# Admin Dashboard - Step-by-Step Testing Instructions

## 🚀 COMPLETE TESTING GUIDE

This guide walks you through testing the entire admin dashboard fix step by step.

---

## ⏱️ Estimated Time: 15-20 minutes

---

## 📋 PRE-FLIGHT CHECKLIST

Before starting, verify:
- [ ] Node.js installed (`node --version`)
- [ ] MongoDB is running (or check connection string)
- [ ] Two terminal windows ready
- [ ] Text editor with browser access

---

## 🎯 STEP 1: Start Backend Server

### Terminal 1 - Backend

```bash
# Navigate to backend directory
cd agentra-backend

# Install dependencies (if first time)
npm install

# Start the server
npm start
```

**Expected Output:**
```
🚀 Server running on http://localhost:5000
📦 MongoDB connected successfully
✅ All routes registered
```

**What This Does:**
- Starts Express server on port 5000
- Connects to MongoDB
- Registers all API routes
- Ready to accept API requests

**⏱️ Expected Time:** 5-10 seconds

**If Issues:**
- Check MongoDB connection string in `.env`
- Verify MongoDB is running
- Check port 5000 is not in use

---

## 🎯 STEP 2: Start Frontend Server

### Terminal 2 - Frontend

```bash
# Navigate to frontend directory
cd agentra

# Install dependencies (if first time)
npm install

# Start development server
npm run dev
```

**Expected Output:**
```
▲ Next.js 14.x.x
  Local:        http://localhost:3000
  Environments: .env.local
```

**What This Does:**
- Starts Next.js development server
- Compiles TypeScript
- Sets up hot reload
- Ready to accept browser requests

**⏱️ Expected Time:** 10-15 seconds

**If Issues:**
- Check Node.js version (needs v18+)
- Delete `node_modules` and `npm install` again
- Check port 3000 is not in use

---

## 🎯 STEP 3: Open Browser

### In Your Browser

```
Open: http://localhost:3000
```

**You Should See:**
- Agentra splash screen
- "Access Admin Portal" button
- Loading spinner (2.5 seconds)
- Transition to onboarding or login

**What Happens:**
1. App loads from Next.js server
2. Frontend makes request to backend
3. Gets authenticated status
4. Shows appropriate screen

**⏱️ Expected Time:** 5 seconds

**If Issues:**
- Verify both servers are running
- Check browser console (F12)
- Try hard refresh (Ctrl+F5)

---

## 🎯 STEP 4: Test Login

### Login to Admin Dashboard

**Option A - If New Owner (Onboarding)**

1. Click "Create New Account"
2. Fill in the form:
   - Email: `admin@agentra.com`
   - Password: `password123`
   - Business Name: `Agentra Admin`
3. Click "Sign Up"
4. Verify success message

**Option B - If Existing Owner (Already Signed Up)**

1. Click "Access Admin Portal"
2. Enter credentials:
   - Email: `admin@agentra.com`
   - Password: `password123`
3. Click "Sign In As Owner"
4. Verify login success

**Expected Result:**
```
✅ Login successful
✅ Token saved to localStorage
✅ Redirected to /admin (dashboard)
```

**Check Console (F12):**
```
Login: User authenticated successfully
Navigation: Redirecting to /admin
API: Token stored in localStorage
```

**⏱️ Expected Time:** 5-10 seconds

**If Issues:**
- Wrong credentials: Check backend `.env`
- Can't create account: Check MongoDB write permissions
- Still on login page: Check localStorage for token

---

## 🎯 STEP 5: Dashboard Page Test

### Test Dashboard Page

**You Should See:**
1. **Sidebar Navigation:**
   - Logo at top
   - "Dashboard" button (highlighted in blue)
   - "Agents" button
   - "Complaints" button
   - "System Logs" button
   - "Analytics" button
   - "Log out" button at bottom

2. **Dashboard Content:**
   - "Admin Dashboard" title
   - 4 stat cards:
     - Total Users
     - Total Agents
     - Total Bookings
     - Total Complaints
   - "Pending Agents" section with table

3. **Console Logs (F12):**
   ```
   📊 Loading dashboard data...
   🌐 API Request: GET http://localhost:5000/api/auth/admin/agents/pending
   📡 Response Status: 200
   ✅ [ADMIN] Agents response: {success: true, agents: [...]}
   ```

**Test Cases:**

#### Test 5a: Stats Display
- [ ] Users count shows a number > 0
- [ ] Agents count shows a number > 0
- [ ] Bookings count shows a number > 0
- [ ] Complaints count shows a number

#### Test 5b: Pending Agents Table
- [ ] Table appears with columns: Name, Email, Business, CNIC, Status, Actions
- [ ] Shows at least one pending agent (or "No pending agents" if none)
- [ ] Each agent has "Approve" and "Reject" buttons

#### Test 5c: Loading State
- [ ] When page first loads, see spinner/loading message
- [ ] After API response, spinner disappears
- [ ] Data displays in table

#### Test 5d: Error Handling
- [ ] If backend down, see error message
- [ ] Error message is clear and helpful

**⏱️ Expected Time:** 5 seconds

**If Issues:**
- No data showing: Check backend `/api/dashboard/owner` endpoint
- Backend request failing: Check network tab (F12 → Network)
- Stats are 0: Check MongoDB has sample data

---

## 🎯 STEP 6: Test Navigation

### Navigate to Agents Page

**Click:** "Agents" button in sidebar

**Expected Results:**
1. **URL Changes:** `http://localhost:3000/admin/agents`
2. **Page Changes:** Dashboard replaced with Agents page
3. **Button Highlights:** "Agents" button turns blue in sidebar
4. **Console Logs:**
   ```
   📋 Loading agents data...
   🌐 API Request: GET http://localhost:5000/api/auth/admin/agents
   ✅ [ADMIN] All agents response: {success: true, agents: [...]}
   ```

**You Should See:**
- All agents from database in table
- Status breakdown cards (Total, Approved, Pending, Rejected)
- Agent columns: Name, Email, Business, Contact, Status, Joined Date

**Test Cases:**

#### Test 6a: Navigate to Agents
- [ ] Agents button highlighted blue
- [ ] URL changed to `/admin/agents`
- [ ] Agents table appears
- [ ] Data loads from API

#### Test 6b: Navigate to Complaints
- [ ] Click "Complaints" button
- [ ] URL changed to `/admin/complaints`
- [ ] "Complaints" button highlighted blue
- [ ] Complaints table appears

#### Test 6c: Navigate to Logs
- [ ] Click "System Logs" button
- [ ] URL changed to `/admin/logs`
- [ ] "System Logs" button highlighted blue
- [ ] Logs table appears

#### Test 6d: Navigate to Analytics
- [ ] Click "Analytics" button
- [ ] URL changed to `/admin/analytics`
- [ ] "Analytics" button highlighted blue
- [ ] Analytics page displays

#### Test 6e: Back Navigation
- [ ] Click browser back button
- [ ] Previous page loads
- [ ] URL changes accordingly
- [ ] Data still displays

**⏱️ Expected Time:** 10 seconds (all pages)

**If Issues:**
- Navigation doesn't work: Check file structure (all pages exist)
- URL doesn't change: Check `useRouter` hook
- Data not loading: Check endpoint URLs in console

---

## 🎯 STEP 7: Test Approve/Reject Buttons

### Go Back to Dashboard

**Click:** "Dashboard" button in sidebar

### Test Approve Button

**Prerequisites:**
- At least one pending agent in the table
- Check "Status" column shows "PENDING_APPROVAL"

**Steps:**
1. Find an agent with "PENDING_APPROVAL" status
2. Click "Approve" button for that agent
3. A confirmation dialog appears: "Approve agent 'John Doe'?"
4. Click "OK" in dialog
5. Agent disappears from the table
6. Pending count decreases

**Console Logs:**
```
✅ [ADMIN] Approving agent: 507f1f77bcf86cd799439012
🌐 API Request: PUT http://localhost:5000/api/auth/admin/agents/507f1f77bcf86cd799439012/approve
📡 Response Status: 200
✅ Agent approved successfully
```

**Test Cases:**

#### Test 7a: Approve Button Works
- [ ] Confirmation dialog appears
- [ ] Clicking OK calls API
- [ ] Agent status changes to APPROVED
- [ ] Agent removed from pending list
- [ ] Pending count decreases by 1

#### Test 7b: Reject Button Works
- [ ] Click "Reject" button on pending agent
- [ ] Prompt asks for rejection reason
- [ ] Enter reason: "Documentation not verified"
- [ ] Click "OK"
- [ ] Agent disappears from table
- [ ] List refreshes automatically

#### Test 7c: Cancel Approval
- [ ] Click "Approve" button
- [ ] Dialog appears
- [ ] Click "Cancel" instead of "OK"
- [ ] Dialog closes, no API call made
- [ ] Agent still in list

#### Test 7d: List Refreshes
- [ ] After approve/reject, table updates immediately
- [ ] No manual refresh needed
- [ ] Counts update in real-time

**⏱️ Expected Time:** 5 seconds

**If Issues:**
- No confirmation dialog: Check approval handler
- API call fails: Check backend endpoint
- List doesn't update: Check auto-refresh logic
- Agent status doesn't change: Check MongoDB update

---

## 🎯 STEP 8: Test Data on All Pages

### Verify Each Page Loads Data

**Navigate to and verify each page:**

#### Agents Page (`/admin/agents`)
```
Expected:
✓ Title shows "Agents Directory"
✓ Stat cards show:
  - Total Agents: X
  - Approved: Y
  - Pending: Z
  - Rejected: W
✓ Table with agent data
✓ Color-coded status badges
✓ Date formatted nicely
```

#### Complaints Page (`/admin/complaints`)
```
Expected:
✓ Title shows "Complaints Management"
✓ Stat cards show:
  - Total Complaints: X
  - Open: Y
  - In Progress: Z
  - Resolved: W
✓ Table with complaint data
✓ Subject, Status, Date columns
✓ Status badges with colors
```

#### System Logs Page (`/admin/logs`)
```
Expected:
✓ Title shows "System Activity Logs"
✓ Stat cards show:
  - Total Logs: X
  - Errors: Y (red badge)
  - Warnings: Z (yellow badge)
  - Info: W (blue badge)
✓ Table with log data
✓ Timestamp, Level, Event, Details columns
✓ Level badges with colors
```

#### Analytics Page (`/admin/analytics`)
```
Expected:
✓ Title shows "Platform Analytics"
✓ Main stat cards:
  - Total Users: X
  - Total Agents: Y
  - Total Bookings: Z
  - Total Complaints: W
✓ Agent distribution card showing breakdown
✓ Platform health metrics card
✓ Recent activity summary section
```

**Test Case:**
- [ ] All 5 pages load without errors
- [ ] Each page displays correct data
- [ ] Tables are properly formatted
- [ ] Status badges have correct colors
- [ ] Numbers match backend data

**⏱️ Expected Time:** 5 seconds

**If Issues:**
- Data empty: Check backend has sample data
- Wrong data: Check API endpoint URLs
- Page crashes: Check browser console for errors

---

## 🎯 STEP 9: Test Logout

### Logout from Dashboard

**Click:** "Log out" button in sidebar (red button at bottom)

**Expected Results:**
1. Dialog appears: "Are you sure you want to logout?"
2. Click "OK"
3. Redirected to login page
4. URL changes to `http://localhost:3000`
5. localStorage token is cleared

**Check localStorage was cleared:**
1. Open DevTools (F12)
2. Go to Application tab
3. Check LocalStorage
4. Verify `ownerToken` is gone

**Test Cases:**

#### Test 9a: Logout Button Works
- [ ] Confirmation dialog appears
- [ ] Clicking OK logs out
- [ ] Redirected to login page
- [ ] URL changed to `/`

#### Test 9b: Token Cleared
- [ ] DevTools → Application → LocalStorage
- [ ] `ownerToken` key is gone
- [ ] Cannot access `/admin` after logout (401 error)

#### Test 9c: Login Again Works
- [ ] After logout, can login again
- [ ] New token generated
- [ ] Dashboard loads successfully

**⏱️ Expected Time:** 5 seconds

**If Issues:**
- Not redirected: Check redirect logic
- Token still in localStorage: Check logout handler
- Can still access /admin: Check authentication middleware

---

## 🎯 STEP 10: Console Debugging Check

### Open Browser DevTools

**Press:** F12 to open Developer Tools

**Go to:** Console tab

**Look for logs like:**
```
📊 Loading dashboard data...
🌐 API Request: GET http://localhost:5000/api/auth/admin/agents/pending
📡 Response Status: 200
✅ [ADMIN] Agents response: {success: true, count: 3, agents: [...]}
📋 Loading agents data...
🌐 API Request: GET http://localhost:5000/api/auth/admin/agents
✅ [ADMIN] All agents response: {success: true, count: 25, agents: [...]}
```

**No error messages should appear like:**
```
❌ Error loading data
❌ API request failed
❌ 404 Not Found
❌ 401 Unauthorized
```

**Test Cases:**

#### Test 10a: Logs Present
- [ ] Console shows API request logs
- [ ] Console shows response logs
- [ ] No error logs

#### Test 10b: Request Format
- [ ] API requests show correct URLs
- [ ] Status codes are 200 (success)
- [ ] Response format is correct

#### Test 10c: No Errors
- [ ] No red error messages
- [ ] No uncaught promise rejections
- [ ] No type errors in console

**⏱️ Expected Time:** 2 seconds

**If Issues:**
- No logs: Check console.log statements exist in code
- 404 errors: Check API URL paths
- 401 errors: Check token is being sent

---

## 🎯 STEP 11: Network Tab Check

### Check API Calls

**In DevTools:**
1. Go to "Network" tab
2. Clear network log
3. Navigate between admin pages
4. Watch network requests appear

**For each page, you should see requests like:**

**Dashboard Page:**
```
GET /api/auth/admin/agents/pending     200 OK
GET /api/dashboard/owner               200 OK
```

**Agents Page:**
```
GET /api/auth/admin/agents             200 OK
```

**Complaints Page:**
```
GET /api/complaints                    200 OK
```

**System Logs Page:**
```
GET /api/logs                          200 OK
```

**Analytics Page:**
```
GET /api/dashboard/owner               200 OK
```

**Test Cases:**

#### Test 11a: Request Methods
- [ ] GET requests for fetching data
- [ ] PUT requests for approve/reject
- [ ] Correct HTTP methods used

#### Test 11b: Response Status
- [ ] All requests return 200 (success)
- [ ] No 404 or 401 errors
- [ ] No 500 server errors

#### Test 11c: Response Headers
- [ ] Check Headers tab
- [ ] x-auth-token header present
- [ ] Content-Type: application/json

#### Test 11d: Response Data
- [ ] Click on request
- [ ] Go to "Response" tab
- [ ] See JSON data
- [ ] Data format is correct

**⏱️ Expected Time:** 2 seconds

**If Issues:**
- 404 errors: Check backend endpoint URLs
- 401 errors: Check token is in header
- 500 errors: Check backend logs for errors

---

## ✅ FINAL CHECKLIST

Mark off as you complete each test:

**Navigation:**
- [ ] Dashboard page loads
- [ ] Agents page loads
- [ ] Complaints page loads
- [ ] System Logs page loads
- [ ] Analytics page loads
- [ ] Browser back button works
- [ ] Sidebar buttons highlight correctly

**Data Loading:**
- [ ] Dashboard shows pending agents
- [ ] Agents shows all agents
- [ ] Complaints shows complaint list
- [ ] System Logs shows activity logs
- [ ] Analytics shows statistics
- [ ] Loading spinners appear
- [ ] Error handling works

**Functionality:**
- [ ] Approve button works
- [ ] Reject button works
- [ ] List updates after actions
- [ ] Logout button works
- [ ] Login works again

**Console & Network:**
- [ ] API requests logged
- [ ] Response data logged
- [ ] No JavaScript errors
- [ ] All HTTP requests successful
- [ ] Network requests show correct endpoints

**Security:**
- [ ] Token stored in localStorage
- [ ] Token sent in API requests
- [ ] Logout clears token
- [ ] Can't access /admin without token

---

## 🎉 SUCCESS CRITERIA

If you can mark ALL items in the final checklist ✅, then:

```
✅ Admin Dashboard is FULLY OPERATIONAL
✅ All fixes have been verified
✅ Ready for production use
```

---

## 🆘 TROUBLESHOOTING QUICK LINKS

| Issue | Solution |
|-------|----------|
| Backend not starting | Check MongoDB connection in .env |
| Frontend not starting | Delete node_modules, npm install, npm run dev |
| Can't login | Check credentials in database |
| Data not loading | Check backend is running, check network tab |
| Buttons don't work | Check browser console for errors |
| Approved agents still showing | Refresh page, check backend database |
| API 404 errors | Check endpoint URLs are correct |
| API 401 errors | Check token in localStorage |
| Page crashes | Check browser console for type errors |

---

## 📞 Need Help?

1. **Check Console:** F12 → Console tab for error messages
2. **Check Network:** F12 → Network tab for API responses
3. **Check Backend Logs:** Look at terminal running `npm start`
4. **Review Guides:** See other documentation files for detailed info
5. **Run Tests:** Use `node test-admin-complete.js` in backend

---

## ⏱️ TOTAL ESTIMATED TIME

- Setup: 15-20 minutes
- Testing: 20-30 minutes
- **Total: 35-50 minutes**

After this time, you'll have fully verified the admin dashboard fix! ✨

---

## 🚀 NEXT STEPS

After successful testing:

1. ✅ Note any issues found in testing
2. ✅ Provide feedback on functionality
3. ✅ Ready for production deployment
4. ✅ Monitor performance in production
5. ✅ Plan future enhancements

---

**Happy Testing! 🎊**
