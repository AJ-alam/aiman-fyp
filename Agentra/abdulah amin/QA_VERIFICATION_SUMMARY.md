# 🧳 Travel Agent App — QA Verification Summary

## Project Structure

This is a **full-stack travel agent platform** with 4 separate applications:

### 1. **Admin Panel** (Next.js)
- **Location:** `agentra/`
- **Purpose:** Owner/Admin dashboard for agent verification, complaints, analytics
- **Tech:** Next.js 16, React 19, TypeScript, Tailwind CSS
- **URL:** http://localhost:3000/admin

### 2. **Travel Agent App** (Flutter)
- **Location:** `agentra_travelagent/`
- **Purpose:** Mobile app for travel agents to manage packages, bookings, refunds
- **Tech:** Flutter/Dart
- **Screens:** Dashboard, Bookings, Refund Requests, Subscription, Payment History, etc.

### 3. **User App** (Flutter)
- **Location:** `agentra_user_frontend/`
- **Purpose:** Mobile app for users to browse packages, book trips, make payments
- **Tech:** Flutter/Dart
- **Screens:** Home, Search, Package Details, Bookings, Profile, Payments, Refunds, etc.

### 4. **Backend API** (Node.js/Express)
- **Location:** `agentra-backend/`
- **Purpose:** REST API serving all 3 frontends
- **Tech:** Express 5, MongoDB (Mongoose), JWT auth, Cloudinary
- **URL:** http://localhost:5000/api

---

## Issues Breakdown by Application

### TRAVEL AGENT APP (Flutter) — 4 Issues

| # | Issue | File(s) to Fix | Priority |
|---|-------|----------------|----------|
| 1 | Images not loading | `bookings_screen.dart`, `dashboard_screen.dart`, backend Cloudinary config | HIGH |
| 2A-2D | Booking tab issues (dummy data, real bookings missing, after-trip bookings, grouping) | `bookings_screen.dart`, `booking.controller.js` | HIGH |
| 3 | Refund requests showing dummy data | `refund_requests_screen.dart`, `refund.controller.js` | HIGH |
| 4 | Subscription payment data not coming | `subscription_screen.dart`, `subscription.controller.js` | HIGH |

### USER APP (Flutter) — 10 Issues

| # | Issue | File(s) to Fix | Priority |
|---|-------|----------------|----------|
| 5 | Remove Card & EasyPaisa payment methods | `payment_screen.dart`, `payment_service.dart`, backend models | HIGH |
| 6 | Packages not syncing in real-time | `home_screen.dart`, `package_list_screen.dart` | MEDIUM |
| 7 | Saved packages not persisting after logout | `saved_packages_screen.dart`, `saved_packages_service.dart` | HIGH |
| 8 | Blue button with blue text (unreadable) | Search all `.dart` files for blue button | LOW |
| 9 | Search feature broken | `search_screen.dart`, `search_results_screen.dart` | HIGH |
| 10A | Profile missing reward points | `profile_screen.dart`, `User.js` model, `user.controller.js` | MEDIUM |
| 10B | Profile missing saved packages | `profile_screen.dart` | MEDIUM |
| 10C | Profile missing completed trips | `profile_screen.dart`, `user.controller.js` | MEDIUM |
| 11 | Edit profile missing Bio field | `edit_profile_screen.dart`, `User.js` model | LOW |
| 12 | Subscription flow verification | `subscription_screen.dart` (if exists in user app) | MEDIUM |
| 13 | Payment history dates/data not showing | `payment_history_screen.dart`, `payment.controller.js` | HIGH |
| 14A | Refund section showing all bookings (should only show cancelled) | `refund_request_screen.dart`, `refund.controller.js` | MEDIUM |
| 14B | Refund sent to wrong agent | `refund.controller.js` (already correct) | ✅ FIXED |

---

## Backend Fixes Required

### Critical Database Schema Updates

#### 1. Add `rewardPoints` to User Model
```javascript
// In src/models/User.js
rewardPoints: {
  type: Number,
  default: 0
}
```

#### 2. Add `bio` to User Model
```javascript
// In src/models/User.js
bio: {
  type: String,
  default: ''
}
```

#### 3. Update Payment Method Enums (Remove CARD, EASYPAISA)
```javascript
// In src/models/Booking.js, Transaction.js, Subscription.js
paymentMethod: {
  type: String,
  enum: ['JAZZCASH', 'BANK'], // Remove CARD, EASYPAISA
  default: 'JAZZCASH'
}
```

### Controller Updates

#### 1. Fix Booking Controller — Filter Out Completed Trips
```javascript
// In src/controllers/booking.controller.js → getAgentBookings()
const bookings = await Booking.find({ 
  agentId: req.user.id,
  status: { $ne: 'COMPLETED' }, // Exclude completed
  travelDate: { $gte: new Date() } // Only future/current trips
}).populate('userId packageId');
```

#### 2. Add Reward Points Logic
```javascript
// In src/controllers/booking.controller.js → createBooking()
await User.findByIdAndUpdate(req.user.id, { 
  $inc: { totalBookings: 1, rewardPoints: 10 } // Add 10 points per booking
});
```

#### 3. Add User Endpoints
```javascript
// In src/controllers/user.controller.js

// GET /api/users/rewards
exports.getRewardPoints = async (req, res) => {
  const user = await User.findById(req.user.id).select('rewardPoints');
  res.json({ success: true, rewardPoints: user.rewardPoints || 0 });
};

// GET /api/users/completed-trips
exports.getCompletedTrips = async (req, res) => {
  const bookings = await Booking.find({ 
    userId: req.user.id,
    $or: [
      { status: 'COMPLETED' },
      { travelDate: { $lt: new Date() } } // Past trips
    ]
  }).populate('packageId agentId');
  res.json({ success: true, completedTrips: bookings });
};
```

#### 4. Update Payment Methods Endpoint
```javascript
// In src/controllers/payment.controller.js → getPaymentMethods()
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

#### 5. Fix Refund Query — Only Cancelled Bookings
```javascript
// In src/controllers/refund.controller.js → getMyRefundRequests()
const bookings = await Booking.find({ 
  userId: req.user.id,
  status: 'CANCELLED', // Only cancelled
  refundStatus: { $ne: 'NONE' }
}).populate('packageId agentId');
```

### Route Updates
```javascript
// In src/routes/user.routes.js
router.get('/rewards', protect, role('USER'), userController.getRewardPoints);
router.get('/completed-trips', protect, role('USER'), userController.getCompletedTrips);
```

---

## Flutter App Fixes Required

### Travel Agent App

#### 1. Fix Bookings Screen
**File:** `lib/screens/bookings_screen.dart`

**Issues:**
- Remove dummy data
- Ensure API call to `/api/bookings/agent`
- Filter out completed bookings
- Display each booking individually (no grouping)

**Fix:**
```dart
// Remove hardcoded dummy data
// Replace with:
final response = await http.get(
  Uri.parse('${ApiConfig.baseUrl}/bookings/agent'),
  headers: {'Authorization': 'Bearer $token'},
);
final bookings = jsonDecode(response.body)['bookings'];
```

#### 2. Fix Refund Requests Screen
**File:** `lib/screens/refund_requests_screen.dart`

**Issues:**
- Remove dummy data
- Ensure API call to `/api/refund/agent`

**Fix:**
```dart
final response = await http.get(
  Uri.parse('${ApiConfig.baseUrl}/refund/agent'),
  headers: {'Authorization': 'Bearer $token'},
);
final refundRequests = jsonDecode(response.body)['refundRequests'];
```

#### 3. Fix Subscription Screen
**File:** `lib/screens/subscription_screen.dart`

**Issues:**
- Ensure API call to `/api/subscription/current`
- Display payment data: amount, paymentMethod, startDate, endDate

**Fix:**
```dart
final response = await http.get(
  Uri.parse('${ApiConfig.baseUrl}/subscription/current'),
  headers: {'Authorization': 'Bearer $token'},
);
final subscription = jsonDecode(response.body)['subscription'];
// Display: subscription['amount'], subscription['paymentMethod'], etc.
```

### User App

#### 1. Fix Payment Screen — Remove Card & EasyPaisa
**File:** `lib/screens/payments/payment_screen.dart`

**Fix:**
```dart
// Remove payment method options for 'CARD' and 'EASYPAISA'
// Only show:
final paymentMethods = [
  {'id': 'JAZZCASH', 'name': 'JazzCash', 'icon': Icons.phone_android},
  {'id': 'BANK', 'name': 'Bank Transfer', 'icon': Icons.account_balance},
];
```

#### 2. Fix Saved Packages Persistence
**File:** `lib/screens/packages/saved_packages_screen.dart`

**Issues:**
- Remove localStorage/SharedPreferences logic
- Use API: `POST /api/saved/:packageId` (save), `GET /api/saved` (fetch)

**Fix:**
```dart
// On save button click:
await http.post(
  Uri.parse('${ApiConfig.baseUrl}/saved/$packageId'),
  headers: {'Authorization': 'Bearer $token'},
);

// On screen load:
final response = await http.get(
  Uri.parse('${ApiConfig.baseUrl}/saved'),
  headers: {'Authorization': 'Bearer $token'},
);
final savedPackages = jsonDecode(response.body)['savedPackages'];
```

#### 3. Fix Search Screen
**File:** `lib/screens/search/search_screen.dart`, `search_results_screen.dart`

**Fix:**
```dart
// On search submit:
final response = await http.get(
  Uri.parse('${ApiConfig.baseUrl}/search?q=$searchQuery'),
);
final packages = jsonDecode(response.body)['packages'];
```

#### 4. Fix Profile Screen — Add Missing Sections
**File:** `lib/screens/profile/profile_screen.dart`

**Add:**
```dart
// 1. Reward Points Section
final rewardsResponse = await http.get(
  Uri.parse('${ApiConfig.baseUrl}/users/rewards'),
  headers: {'Authorization': 'Bearer $token'},
);
final rewardPoints = jsonDecode(rewardsResponse.body)['rewardPoints'];

// 2. Saved Packages Section
final savedResponse = await http.get(
  Uri.parse('${ApiConfig.baseUrl}/saved'),
  headers: {'Authorization': 'Bearer $token'},
);
final savedPackages = jsonDecode(savedResponse.body)['savedPackages'];

// 3. Completed Trips Section
final tripsResponse = await http.get(
  Uri.parse('${ApiConfig.baseUrl}/users/completed-trips'),
  headers: {'Authorization': 'Bearer $token'},
);
final completedTrips = jsonDecode(tripsResponse.body)['completedTrips'];
```

#### 5. Fix Edit Profile — Add Bio Field
**File:** `lib/screens/profile/edit_profile_screen.dart`

**Add:**
```dart
TextFormField(
  controller: bioController,
  decoration: InputDecoration(labelText: 'Bio'),
  maxLines: 3,
),
```

#### 6. Fix Payment History Screen
**File:** `lib/screens/payments/payment_history_screen.dart`

**Fix:**
```dart
final response = await http.get(
  Uri.parse('${ApiConfig.baseUrl}/payments/history'),
  headers: {'Authorization': 'Bearer $token'},
);
final transactions = jsonDecode(response.body)['transactions'];

// Display for each transaction:
// - createdAt (payment date)
// - amount
// - paymentMethod
// - type (EARNING, REFUND, etc.)
```

#### 7. Fix Refund Screen — Only Show Cancelled Bookings
**File:** `lib/screens/refunds/refund_request_screen.dart`

**Fix:**
```dart
final response = await http.get(
  Uri.parse('${ApiConfig.baseUrl}/refund/my'),
  headers: {'Authorization': 'Bearer $token'},
);
final refundRequests = jsonDecode(response.body)['refundRequests'];
// Backend already filters by status: 'CANCELLED'
```

#### 8. Fix Blue Button Text Color
**Search all `.dart` files:**
```bash
grep -r "color: Colors.blue" lib/
grep -r "backgroundColor: Colors.blue" lib/
```

**Fix:**
```dart
// Change from:
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.blue, // ❌ WRONG
  ),
)

// To:
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white, // ✅ CORRECT
  ),
)
```

#### 9. Fix Real-Time Package Sync
**File:** `lib/screens/home/home_screen.dart`, `package_list_screen.dart`

**Add polling:**
```dart
Timer.periodic(Duration(seconds: 30), (timer) {
  fetchPackages(); // Refresh every 30 seconds
});
```

---

## Testing Checklist

### Backend Testing
```bash
cd "Agentra1/Agentra/abdulah amin/agentra-backend"
npm start

# Test endpoints:
curl http://localhost:5000/api/packages
curl http://localhost:5000/api/bookings/agent -H "Authorization: Bearer TOKEN"
curl http://localhost:5000/api/refund/agent -H "Authorization: Bearer TOKEN"
curl http://localhost:5000/api/subscription/current -H "Authorization: Bearer TOKEN"
curl http://localhost:5000/api/payments/history -H "Authorization: Bearer TOKEN"
curl http://localhost:5000/api/users/rewards -H "Authorization: Bearer TOKEN"
curl http://localhost:5000/api/users/completed-trips -H "Authorization: Bearer TOKEN"
```

### Travel Agent App Testing
```bash
cd "Agentra1/Agentra/abdulah amin/agentra_travelagent"
flutter run

# Test:
1. Login as agent
2. Check bookings tab (no dummy data, real bookings showing, no completed trips)
3. Check refund requests (no dummy data)
4. Check subscription (payment data showing)
5. Check images loading
```

### User App Testing
```bash
cd "Agentra1/Agentra/abdulah amin/agentra_user_frontend"
flutter run

# Test:
1. Login as user
2. Check payment methods (only JazzCash & Bank)
3. Save a package, logout, login → check if still saved
4. Search for packages
5. Check profile (reward points, saved packages, completed trips)
6. Edit profile (bio field present)
7. Check payment history (dates and data showing)
8. Check refund section (only cancelled bookings)
9. Check for blue button with blue text
10. Check packages updating in real-time
```

---

## Implementation Order

### Phase 1: Backend Fixes (2-3 hours)
1. ✅ Update User model (add rewardPoints, bio)
2. ✅ Update payment method enums (remove CARD, EASYPAISA)
3. ✅ Fix booking controller (filter completed trips)
4. ✅ Add reward points logic
5. ✅ Add user endpoints (rewards, completed trips)
6. ✅ Update payment methods endpoint
7. ✅ Fix refund query (only cancelled)
8. ✅ Add routes

### Phase 2: Travel Agent App Fixes (2-3 hours)
1. Fix bookings screen
2. Fix refund requests screen
3. Fix subscription screen
4. Fix image loading

### Phase 3: User App Fixes (3-4 hours)
1. Fix payment screen (remove Card & EasyPaisa)
2. Fix saved packages persistence
3. Fix search screen
4. Fix profile screen (add 3 sections)
5. Fix edit profile (add bio)
6. Fix payment history
7. Fix refund screen
8. Fix blue button
9. Add real-time package sync

### Phase 4: Testing & Verification (2-3 hours)
1. Test all backend endpoints
2. Test travel agent app end-to-end
3. Test user app end-to-end
4. Fix any remaining bugs

**Total Estimated Time: 9-13 hours**

---

## Next Steps

1. **Start with Backend Fixes** — This will unblock both Flutter apps
2. **Test Backend Endpoints** — Ensure all APIs return correct data
3. **Fix Travel Agent App** — Simpler, fewer screens
4. **Fix User App** — More complex, more screens
5. **End-to-End Testing** — Test complete user flows

Ready to start implementing? Let's begin with Phase 1: Backend Fixes! 🚀
