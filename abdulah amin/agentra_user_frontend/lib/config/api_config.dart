class ApiConfig {
  // Base URL - Change based on your device
  // 1. LIVE CLOUD URL (For production/deployed backend)
  // static const String BASE_URL = 'https://agentra-backend.vercel.app/api';
  static const String BASE_URL = 'http://localhost:5000/api'; 
  static const String SERVER_URL = 'http://localhost:5000';

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return 'https://placehold.co/600x400/e2e8f0/475569?text=No+Image';
    if (path.startsWith('http')) return path;
    if (path.startsWith('/')) return '$SERVER_URL$path';
    return '$SERVER_URL/$path';
  }
  // 2. LOCAL BACKEND URL (Use this if you are running the backend locally)
  // static const String BASE_URL = 'http://localhost:5000/api'; // For Web/iOS
  // static const String BASE_URL = 'http://10.0.2.2:5000/api';  // For Android Emulator
  // static const String BASE_URL = 'http://192.168.x.x:5000/api'; // For Physical Device (Use your IP)
  
  // ===== AUTH ENDPOINTS =====
  static const String USER_REGISTER = '$BASE_URL/auth/user/register';
  static const String USER_LOGIN = '$BASE_URL/auth/user/login';
  static const String USER_LOGOUT = '$BASE_URL/auth/user/logout';
  static const String AGENT_REGISTER = '$BASE_URL/auth/agent/register';
  static const String AGENT_LOGIN = '$BASE_URL/auth/agent/login';
  
  // ===== PACKAGE ENDPOINTS =====
  static const String PACKAGES = '$BASE_URL/packages';
  static const String PACKAGE_LOCATIONS = '$BASE_URL/packages/locations';
  static const String SEARCH = '$BASE_URL/search';
  static const String PROMOTIONS = '$BASE_URL/promotion';
  static String packageDetail(String id) => '$BASE_URL/packages/$id';
  
  // ===== BOOKING ENDPOINTS =====
  static const String BOOKINGS = '$BASE_URL/bookings';
  static const String MY_BOOKINGS = '$BASE_URL/bookings/my';
  static String cancelBooking(String id) => '$BASE_URL/bookings/$id/cancel';
  
  // ===== USER ENDPOINTS =====
  static const String USER_PROFILE = '$BASE_URL/users/profile';
  static const String UPDATE_PROFILE = '$BASE_URL/users/profile';
  static const String USER_PREFERENCES = '$BASE_URL/users/preferences';
  
  // ===== PAYMENT ENDPOINTS =====
  static const String PAYMENT_METHODS = '$BASE_URL/payments/methods';
  static const String PAYMENT_INTENT = '$BASE_URL/payments/intent';
  static const String PROCESS_PAYMENT = '$BASE_URL/payments/process';
  static const String PAYMENT_HISTORY = '$BASE_URL/payments/history';
  static String verifyPayment(String transactionId) => '$BASE_URL/payments/verify/$transactionId';
  
  // ===== REVIEW ENDPOINTS =====
  static const String REVIEWS = '$BASE_URL/users/reviews';
  static const String CREATE_REVIEW = '$BASE_URL/users/reviews';
  static const String MY_REVIEWS = '$BASE_URL/users/reviews';
  
  // ===== COMPLAINT ENDPOINTS =====
  static const String SUBMIT_COMPLAINT = '$BASE_URL/users/complaints';
  static const String MY_COMPLAINTS = '$BASE_URL/users/complaints';
  
  // ===== CHATBOT ENDPOINTS =====
  static const String CHATBOT = '$BASE_URL/chatbot';
  static const String CHATBOT_START = '$BASE_URL/chatbot/start';
  static const String CHATBOT_MESSAGE = '$BASE_URL/chatbot/message';
  static String chatbotHistory(String conversationId) => '$BASE_URL/chatbot/$conversationId';
  
  // ===== SAVED PACKAGES ENDPOINTS =====
  static const String SAVED_PACKAGES = '$BASE_URL/favorites';
  static const String TOGGLE_FAVORITE = '$BASE_URL/favorites/toggle';
  
  // ===== AGENT ENDPOINTS (BONUS) =====
  static const String AGENT_DASHBOARD = '$BASE_URL/dashboard/agent';
  static const String AGENT_ANALYTICS = '$BASE_URL/analytics/agent';
  static const String SUBSCRIPTION_PLANS = '$BASE_URL/subscription/plans';
  static const String CURRENT_SUBSCRIPTION = '$BASE_URL/subscription/current';
  static const String EARNINGS_OVERVIEW = '$BASE_URL/earnings/overview';
}