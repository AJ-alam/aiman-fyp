class ApiConfig {
  static const String BASE_URL = 'http://localhost:5000/api';
  // static const String BASE_URL = 'http://10.0.2.2:5000/api'; // For Android Emulator

  // ===== AUTH ENDPOINTS =====
  static const String USER_LOGIN = "$BASE_URL/auth/user/login";
  static const String USER_REGISTER = "$BASE_URL/auth/user/register";

  static const String AGENT_LOGIN = "$BASE_URL/auth/agent/login";
  static const String AGENT_REGISTER = "$BASE_URL/auth/agent/register";

  // ===== PACKAGE ENDPOINTS =====
  static const String PACKAGES = '$BASE_URL/packages';
  static const String AGENT_PACKAGES = '$BASE_URL/packages/agent';
  static String packageDetail(String id) => '$BASE_URL/packages/$id';

  // ===== AGENT ENDPOINTS =====
  static const String AGENT_PROFILE = '$BASE_URL/auth/agent/profile';
  static const String UPDATE_AGENT_PROFILE = '$BASE_URL/auth/agent/profile';
  static const String AGENT_DASHBOARD = '$BASE_URL/dashboard/agent';
  static const String AGENT_ANALYTICS = '$BASE_URL/analytics/agent';
  static const String AGENT_PERFORMANCE = '$BASE_URL/dashboard/agent';
  static const String AGENT_COMPLAINTS = '$BASE_URL/complaints/agent-received';
  static const String AGENT_BOOKINGS = '$BASE_URL/agents/bookings';
  static const String AGENT_REFUNDS = '$BASE_URL/refund/agent';

  // ===== ADMIN / OWNER ENDPOINTS =====
  static const String OWNER_LOGIN = '$BASE_URL/auth/owner/login';
  static const String OWNER_DASHBOARD = '$BASE_URL/dashboard/owner';
  static const String ALL_AGENTS = '$BASE_URL/admin/agents';

  // New Approval Workflow Routes
  static const String PENDING_AGENTS = '$BASE_URL/auth/admin/agents/pending';
  static String approveAgent(String id) => '$BASE_URL/admin/travel-agents/$id/approve';
  static String rejectAgent(String id) => '$BASE_URL/admin/travel-agents/$id/reject';

  // Legacy / Other Admin Routes
  static const String COMPLAINTS = '$BASE_URL/complaints';
  static String updateComplaint(String id) => '$BASE_URL/complaints/$id';

  static const String UPLOAD_IMAGE = '$BASE_URL/upload/image';

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return 'https://placehold.co/600x400/e2e8f0/475569?text=No+Image';
    if (path.startsWith('http')) return path;
    return path; // Assuming full URL if not starting with /
  }
}


