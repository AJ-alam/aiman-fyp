# 🧳 Travel Agent App — Complete QA & Fix Plan

## Overview
This document outlines all issues found in the Travel Agent web application and provides a systematic approach to fix them. The app has two sides: **Travel Agent (Admin)** and **User (Frontend)**.

---

## PART 1: TRAVEL AGENT SIDE (Admin Panel)

### ✅ Issue 1: Images Not Loading
**Problem:** Pictures/images are not rendering properly throughout the travel agent panel.

**Root Cause Analysis:**
- Backend has Cloudinary integration (`config/cloudinary.js`)
- Models have image fields: `profileImage` (User, Agent), `images[]` and `image` (Package)
- Upload routes exist at `/api/upload`

**Fix Required:**
1. Verify Cloudinary credentials in `.env` file
2. Check upload controller implementation
3. Ensure frontend is using correct image URLs from API responses
4. Add fallback images for missing/broken URLs

**Files to Check:**
- `agentra-backend/config/cloudinary.js`
- `agentra-backend/src/routes/upload.js`
- `agentra-backend/.env` (CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET)
- Frontend components displaying images

---

### ✅ Issue 2: Booking Tab — Multiple Issues

#### Issue 2A: Dummy Data Showing
**Problem:** The booking tab is displaying dummy/fake data instead of real bookings from the database.

**Root Cause:**
- Frontend might be using hardcoded data instead of API calls
- API endpoint: `GET /api/bookings/agent` (from `booking.controller.js`)

**Fix Required:**
1. Verify frontend is calling `/api/bookings/agent` with proper auth token
2. Remove any hardcoded dummy data from frontend components
3. Ensure backend `getAgentBookings()` is returning real data

**Files to Fix:**
- Frontend: Admin booking page component
- Backend: `src/controllers/booking.controller.js` (verify `getAgentBookings`)

#### Issue 2B: Real Bookings Not Visible
**Problem:** Actual bookings made by users are not appearing in the list.

**Root Cause:**
- Database query might be filtering incorrectly
- Auth token might not be passing correct agentId

**Fix Required:**
1. Add console logs to verify `req.user.id` in `getAgentBookings()`
2. Check if bookings exist in database with correct `agentId`
3. Verify JWT token is being decoded correctly

**Test Query:**
```javascript
// In MongoDB or via API test
Booking.find({ agentId: "AGENT_ID_HERE" }).populate('userId packageId')
```

#### Issue 2C: After-Trip Bookings Should Be Removed
**Problem:** Bookings that belong to trips that have already been completed should be removed from this view.

**Current Implementation:**
- Booking model has `status` field: CONFIRMED/CANCELLED/COMPLETED
- Booking model has `travelDate` field

**Fix Required:**
1. Update `getAgentBookings()` to filter out completed bookings:
```javascript
const bookings = await Booking.find({ 
  agentId: req.user.id,
  status: { $ne: 'COMPLETED' } // Exclude completed
}).populate('userId packageId');
```

2. OR filter by travel date:
```javascript
const bookings = await Booking.find({ 
  agentId: req.user.id,
  travelDate: { $gte: new Date() } // Only future/current trips
}).populate('userId packageId');
```

**Files to Fix:**
- `src/controllers/booking.controller.js` → `getAgentBookings()`

#### Issue 2D: Bookings Should Not Be Grouped by Package
**Problem:** Bookings should not be grouped or filtered by package. Show all bookings individually.

**Fix Required:**
1. Ensure backend returns flat list of bookings (already implemented correctly)
2. Check frontend rendering — remove any grouping logic
3. Display each booking as a separate row/card

**Files to Check:**
- Frontend: Admin booking page component (check for `.groupBy()` or similar logic)

---

### ✅ Issue 3: Refund Requests — Dummy Data Issue
**Problem:** The refund request section is showing dummy/placeholder data.

**Current Implementation:**
- Backend has full refund system: `src/controllers/refund.controller.js`
- API endpoint: `GET /api/refund/agent` (returns refund requests for agent)

**Fix Required:**
1. Verify frontend is calling `/api/refund/agent` instead of using dummy data
2. Remove hardcoded refund data from frontend
3. Ensure backend query is correct:
```javascript
const bookings = await Booking.find({ 
  agentId: req.user.id, 
  refundStatus: 'REQUESTED' 
}).populate('userId packageId');
```

**Files to Fix:**
- Frontend: Admin refund page component
- Backend: `src/controllers/refund.controller.js` → `getRefundRequests()`

---

### ✅ Issue 4: Subscription — Payment Data Not Coming
**Problem:** The subscription section is not receiving or displaying payment data.

**Current Implementation:**
- Subscription model has: `paymentMethod`, `paymentId`, `amount`, `startDate`, `endDate`
- API endpoint: `GET /api/subscription/current` (from `subscription.controller.js`)

**Fix Required:**
1. Verify frontend is calling `/api/subscription/current` with agent auth token
2. Check if subscription data exists in database:
```javascript
Subscription.findOne({ agentId: "AGENT_ID_HERE" })
```
3. Ensure `getCurrentSubscription()` is populating all payment fields
4. Add error handling for missing subscriptions

**Files to Fix:**
- Frontend: Admin subscription page component
- Backend: `src/controllers/subscription.controller.js` → `getCurrentSubscription()`

**Database Check:**
```bash
# Connect to MongoDB and run:
db.subscriptions.find({ agentId: ObjectId("AGENT_ID") })
```

---

## PART 2: USER SIDE (Frontend)

### ✅ Issue 5: Payment Methods — Remove Card & EasyPaisa
**Problem:** Currently, Card and EasyPaisa are shown as payment options. Only JazzCash should remain.

**Current Implementation:**
- Backend supports: CARD, JAZZCASH, EASYPAISA, BANK
- Defined in models: `Booking.js`, `Transaction.js`, `Subscription.js`
- Payment controller: `src/controllers/payment.controller.js`

**Fix Required:**

**Option A: Backend Change (Recommended)**
1. Update all models to remove CARD and EASYPAISA:
```javascript
// In Booking.js, Transaction.js, Subscription.js
paymentMethod: {
  type: String,
  enum: ['JAZZCASH', 'BANK'], // Remove CARD, EASYPAISA
  default: 'JAZZCASH'
}
```

2. Update `getPaymentMethods()` in `payment.controller.js`:
```javascript
const paymentMethods = [
  {
    id: 'jazzcash',
    name: 'JazzCash',
    icon: 'mobile',
    supported: true
  },
  {
    id: 'bank',
    name: 'Bank Transfer',
    icon: 'bank',
    supported: true
  }
];
```

**Option B: Frontend Only**
1. Filter payment methods in frontend to show only JazzCash
2. Set default payment method to 'JAZZCASH'

**Files to Fix:**
- `src/models/Booking.js`
- `src/models/Transaction.js`
- `src/models/Subscription.js`
- `src/controllers/payment.controller.js` → `getPaymentMethods()`
- Frontend: Payment selection component

---

### ✅ Issue 6: Travel Agent Packages — Real-Time Sync on User Screen
**Problem:** When a travel agent creates or deletes a package, those changes should immediately reflect on the user-facing screen.

**Current Implementation:**
- Backend: `POST /api/packages` (create), `DELETE /api/packages/:id` (delete)
- User side: `GET /api/packages` (get public packages)

**Fix Required:**
1. **Frontend polling:** Refresh packages every 30 seconds
```javascript
useEffect(() => {
  const interval = setInterval(() => {
    fetchPackages();
  }, 30000); // 30 seconds
  return () => clearInterval(interval);
}, []);
```

2. **OR implement WebSocket/Server-Sent Events** for real-time updates (advanced)

3. **OR add cache-busting:** Ensure no stale data is cached
```javascript
fetch('/api/packages', {
  headers: { 'Cache-Control': 'no-cache' }
})
```

**Files to Fix:**
- Frontend: User packages list component
- Add polling or real-time update mechanism

---

### ✅ Issue 7: Save Package — Persistence After Logout
**Problem:** When a user saves a package, it is currently not persisting after logout.

**Current Implementation:**
- Backend has full SavedPackage system: `src/models/SavedPackage.js`
- API endpoints:
  - `POST /api/saved/:packageId` (save)
  - `GET /api/saved` (get all saved)
  - `DELETE /api/saved/:packageId` (unsave)

**Root Cause:**
- Frontend might be storing saved packages in localStorage instead of database
- OR frontend is not calling the save API

**Fix Required:**
1. Verify frontend calls `POST /api/saved/:packageId` when user clicks save
2. Ensure auth token is included in request
3. On page load, fetch saved packages from `GET /api/saved`
4. Remove any localStorage-based save logic

**Test:**
```bash
# After user saves a package, check database:
db.savedpackages.find({ userId: ObjectId("USER_ID") })
```

**Files to Fix:**
- Frontend: Save button component
- Frontend: Saved packages page
- Ensure API calls are made instead of localStorage

---

### ✅ Issue 8: UI Bug — Blue Button with Blue Text
**Problem:** There is a blue button that has blue text on it, making it unreadable.

**Fix Required:**
1. Search for button components with blue background
2. Change text color to white:
```css
.blue-button {
  background-color: blue;
  color: white; /* Change from blue to white */
}
```

**Files to Search:**
- Frontend: All component files
- `app/globals.css`
- Tailwind classes: Look for `bg-blue-*` with `text-blue-*`

**Search Command:**
```bash
# Search for blue button with blue text
grep -r "bg-blue" agentra/app/
grep -r "text-blue" agentra/app/
```

---

### ✅ Issue 9: Search Feature
**Problem:** The search functionality needs to be verified.

**Current Implementation:**
- Backend has full search system: `src/controllers/search.controller.js`
- API endpoints:
  - `GET /api/search?q=...` (search by keyword)
  - `POST /api/search/filter` (advanced filter)

**Fix Required:**
1. Verify frontend search input calls `/api/search?q=USER_INPUT`
2. Test search with various queries:
   - Location: "Lahore", "Islamabad"
   - Keywords: "mountain", "beach", "adventure"
3. Ensure results are displayed correctly
4. Add loading state and error handling

**Test Cases:**
```javascript
// Test 1: Search by location
GET /api/search?q=Lahore

// Test 2: Search by keyword
GET /api/search?q=adventure

// Test 3: Filter by price
POST /api/search/filter
Body: { "priceRange": "5000-15000" }
```

**Files to Check:**
- Frontend: Search bar component
- Frontend: Search results page
- Backend: `src/controllers/search.controller.js`

---

### ✅ Issue 10: Profile Page — Missing Sections
**Problem:** The user profile page is incomplete. It must show:
1. Reward Points
2. Saved Packages
3. Completed Trips

**Current Implementation:**
- User model has: `totalBookings`, `travelHistory[]`
- SavedPackage model exists
- Booking model has `status: 'COMPLETED'`

**Fix Required:**

#### 10A: Reward Points
**Problem:** User model doesn't have `rewardPoints` field.

**Fix:**
1. Add `rewardPoints` field to User model:
```javascript
// In src/models/User.js
rewardPoints: {
  type: Number,
  default: 0
}
```

2. Implement reward logic (e.g., 10 points per booking):
```javascript
// In booking.controller.js → createBooking()
await User.findByIdAndUpdate(req.user.id, { 
  $inc: { totalBookings: 1, rewardPoints: 10 } 
});
```

3. Create API endpoint:
```javascript
// GET /api/users/rewards
exports.getRewardPoints = async (req, res) => {
  const user = await User.findById(req.user.id).select('rewardPoints');
  res.json({ success: true, rewardPoints: user.rewardPoints });
};
```

#### 10B: Saved Packages
**Already Implemented!**
- API: `GET /api/saved`
- Just need to display on profile page

#### 10C: Completed Trips
**Fix:**
1. Create API endpoint:
```javascript
// GET /api/users/completed-trips
exports.getCompletedTrips = async (req, res) => {
  const bookings = await Booking.find({ 
    userId: req.user.id,
    status: 'COMPLETED'
  }).populate('packageId');
  res.json({ success: true, completedTrips: bookings });
};
```

2. OR filter by past travel dates:
```javascript
const bookings = await Booking.find({ 
  userId: req.user.id,
  travelDate: { $lt: new Date() } // Past trips
}).populate('packageId');
```

**Files to Fix:**
- `src/models/User.js` (add rewardPoints)
- `src/controllers/user.controller.js` (add getRewardPoints, getCompletedTrips)
- `src/routes/user.routes.js` (add routes)
- Frontend: Profile page component

---

### ✅ Issue 11: Edit Profile — Add "Bio" Field
**Problem:** The edit profile form is missing a Bio field.

**Current Implementation:**
- User model already has `bio` field? **NO, it doesn't!**
- Agent model has `bio` field

**Fix Required:**
1. Add `bio` field to User model:
```javascript
// In src/models/User.js
bio: {
  type: String,
  default: ''
}
```

2. Update `updateProfile()` to allow bio updates:
```javascript
// In user.controller.js → updateProfile()
const allowed = ['fullName', 'phone', 'profileImage', 'bio'];
const updateData = {};
allowed.forEach(key => {
  if (req.body[key] !== undefined) {
    updateData[key] = req.body[key];
  }
});
```

3. Add bio input field to frontend edit profile form

**Files to Fix:**
- `src/models/User.js` (add bio field)
- `src/controllers/user.controller.js` (allow bio in updateProfile)
- Frontend: Edit profile form component

---

### ✅ Issue 12: Subscription Flow
**Problem:** The subscription section on the user side needs to be verified end-to-end.

**Current Implementation:**
- Subscription is for AGENTS, not regular users
- User model doesn't have subscription fields

**Clarification Needed:**
- Is this subscription for users or agents?
- If for users: Need to create user subscription system
- If for agents: Already implemented in `subscription.controller.js`

**Assuming it's for AGENTS:**
1. Test subscription flow:
   - `POST /api/subscription/subscribe` (create subscription)
   - `GET /api/subscription/current` (get current subscription)
   - `PUT /api/subscription/cancel` (cancel subscription)

2. Verify payment processing
3. Check subscription expiry logic

**Files to Check:**
- `src/controllers/subscription.controller.js`
- Frontend: Subscription page

---

### ✅ Issue 13: Payment History — Dates & Data Not Showing
**Problem:** In the payment history section, payment records and dates are not being displayed.

**Current Implementation:**
- Transaction model has: `createdAt`, `amount`, `type`, `paymentMethod`
- API endpoint: `GET /api/payments/history` (from `payment.controller.js`)

**Fix Required:**
1. Verify frontend is calling `/api/payments/history` with user auth token
2. Ensure backend is returning transactions:
```javascript
// In payment.controller.js → getTransactionHistory()
const transactions = await Transaction.find({ userId: req.user.id })
  .populate('packageId', 'title location price')
  .populate('bookingId', 'status travelDate')
  .sort({ createdAt: -1 });
```

3. Frontend should display:
   - `createdAt` (payment date)
   - `amount` (payment amount)
   - `paymentMethod` (JAZZCASH, BANK, etc.)
   - `type` (EARNING, REFUND, etc.)

**Test:**
```bash
# Check if transactions exist in database
db.transactions.find({ userId: ObjectId("USER_ID") })
```

**Files to Fix:**
- Frontend: Payment history page component
- Backend: `src/controllers/payment.controller.js` → `getTransactionHistory()`

---

### ✅ Issue 14: Refund Section — Wrong Bookings Showing + Wrong Destination

#### Issue 14A: Only Show Cancelled Bookings
**Problem:** The refund section is showing all bookings, but it should only show bookings that have been cancelled.

**Current Implementation:**
- API endpoint: `GET /api/refund/my` (from `refund.controller.js`)
- Already filters by `refundStatus: { $ne: 'NONE' }`

**Fix Required:**
1. Update query to only show cancelled bookings:
```javascript
// In refund.controller.js → getMyRefundRequests()
const bookings = await Booking.find({ 
  userId: req.user.id,
  status: 'CANCELLED', // Only cancelled
  refundStatus: { $ne: 'NONE' }
}).populate('packageId agentId');
```

**Files to Fix:**
- `src/controllers/refund.controller.js` → `getMyRefundRequests()`

#### Issue 14B: Send Refund to Correct Travel Agent
**Problem:** The refund request should be sent to the travel agent who owns the package that was booked.

**Current Implementation:**
- Booking model has `agentId` field
- Refund request already creates complaint with correct `agentId`:
```javascript
await Complaint.create({
  userId,
  agentId: booking.agentId, // ✅ Correct agent
  bookingId: booking._id,
  subject: 'Refund Request',
  description: `Refund request for booking: ${reason}`
});
```

**Verification:**
- This is already implemented correctly!
- Just need to verify frontend is displaying the correct agent info

**Files to Check:**
- `src/controllers/refund.controller.js` → `requestRefund()` (already correct)
- Frontend: Refund page (verify agent info is displayed)

---

## SUMMARY CHECKLIST

| # | Section | Issue | Status | Priority |
|---|---------|-------|--------|----------|
| 1 | Travel Agent | Images not loading | 🔧 Fix | HIGH |
| 2A | Travel Agent | Booking tab — dummy data | 🔧 Fix | HIGH |
| 2B | Travel Agent | Real bookings missing | 🔧 Fix | HIGH |
| 2C | Travel Agent | After-trip bookings showing | 🔧 Fix | MEDIUM |
| 2D | Travel Agent | Bookings grouped by package | 🔧 Fix | LOW |
| 3 | Travel Agent | Refund requests showing dummy data | 🔧 Fix | HIGH |
| 4 | Travel Agent | Subscription — payment data not coming | 🔧 Fix | HIGH |
| 5 | User Frontend | Remove Card & EasyPaisa payment methods | 🔧 Fix | HIGH |
| 6 | User Frontend | Packages not syncing in real time | 🔧 Fix | MEDIUM |
| 7 | User Frontend | Saved packages not persisting after logout | 🔧 Fix | HIGH |
| 8 | User Frontend | Blue button — blue text (unreadable) | 🔧 Fix | LOW |
| 9 | User Frontend | Search feature broken | 🔧 Fix | HIGH |
| 10A | User Frontend | Profile missing reward points | 🔧 Fix | MEDIUM |
| 10B | User Frontend | Profile missing saved packages | 🔧 Fix | MEDIUM |
| 10C | User Frontend | Profile missing completed trips | 🔧 Fix | MEDIUM |
| 11 | User Frontend | Edit profile missing Bio field | 🔧 Fix | LOW |
| 12 | User Frontend | Subscription flow — verify end to end | ✅ Verify | MEDIUM |
| 13 | User Frontend | Payment history — dates and data not showing | 🔧 Fix | HIGH |
| 14A | User Frontend | Refund section — only cancelled bookings | 🔧 Fix | MEDIUM |
| 14B | User Frontend | Refund section — send to correct agent | ✅ Already Fixed | LOW |

---

## NEXT STEPS

### Phase 1: Critical Backend Fixes (HIGH Priority)
1. Fix image loading (Cloudinary config)
2. Fix booking tab dummy data
3. Fix refund requests dummy data
4. Fix subscription payment data
5. Remove Card & EasyPaisa payment methods
6. Fix saved packages persistence
7. Fix search feature
8. Fix payment history display

### Phase 2: Database Schema Updates (MEDIUM Priority)
1. Add `rewardPoints` to User model
2. Add `bio` to User model
3. Update payment method enums

### Phase 3: Frontend Fixes (MEDIUM/LOW Priority)
1. Fix blue button text color
2. Add real-time package sync
3. Add profile sections (rewards, saved, completed trips)
4. Add bio field to edit profile
5. Filter refund section to show only cancelled bookings

### Phase 4: Testing & Verification
1. Test all API endpoints
2. Test frontend-backend integration
3. Test authentication flows
4. Test payment flows
5. Test refund flows
6. Test search functionality
7. Test profile updates

---

## TESTING COMMANDS

### Backend Testing
```bash
# Start backend
cd "Agentra1/Agentra/abdulah amin/agentra-backend"
npm start

# Test API endpoints
curl -X GET http://localhost:5000/api/packages
curl -X GET http://localhost:5000/api/bookings/agent -H "Authorization: Bearer TOKEN"
```

### Frontend Testing
```bash
# Start frontend
cd "Agentra1/Agentra/abdulah amin/agentra"
npm run dev

# Open browser
http://localhost:3000
```

### Database Testing
```bash
# Connect to MongoDB
mongosh

# Check collections
use agentra_db
db.bookings.find()
db.packages.find()
db.savedpackages.find()
db.transactions.find()
```

---

## CONCLUSION

This document provides a complete roadmap to fix all 14 issues in the Travel Agent web application. Follow the phases in order, starting with critical backend fixes, then database updates, and finally frontend improvements.

**Estimated Time:**
- Phase 1: 4-6 hours
- Phase 2: 2-3 hours
- Phase 3: 3-4 hours
- Phase 4: 2-3 hours
- **Total: 11-16 hours**

Good luck! 🚀
