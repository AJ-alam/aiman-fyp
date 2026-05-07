class ApiConfig {
  static const String BASE_URL = 'http://localhost:5000';
  // static const String BASE_URL = 'http://10.0.2.2:5000'; // For Android Emulator

  // Use this for Web or iOS Simulator:
  // static const String BASE_URL = 'http://localhost:5000';

  // ===== AUTH ENDPOINTS =====
  static const String USER_LOGIN = "$BASE_URL/api/auth/user/login";
  static const String USER_REGISTER = "$BASE_URL/api/auth/user/register";

  static const String AGENT_LOGIN = "$BASE_URL/api/auth/agent/login";
  static const String AGENT_REGISTER = "$BASE_URL/api/auth/agent/register";

  // ===== PACKAGE ENDPOINTS =====
  static const String PACKAGES = '$BASE_URL/api/packages';
  static const String AGENT_PACKAGES = '$BASE_URL/api/packages/agent';
  static String packageDetail(String id) => '$BASE_URL/api/packages/$id';

  // ===== AGENT ENDPOINTS =====
  static const String AGENT_PROFILE = '$BASE_URL/api/auth/agent/profile';
  static const String UPDATE_AGENT_PROFILE = '$BASE_URL/api/auth/agent/profile';
  static const String AGENT_DASHBOARD = '$BASE_URL/api/dashboard/agent';
  static const String AGENT_PERFORMANCE = '$BASE_URL/api/dashboard/agent';

  // ===== ADMIN ENDPOINTS =====
  static const String OWNER_LOGIN = '$BASE_URL/api/auth/owner/login';
  static const String UNVERIFIED_AGENTS = '$BASE_URL/api/auth/owner/agents';
  static String verifyAgent(String id) => '$BASE_URL/api/auth/owner/agents/$id/verify';
  static String rejectAgent(String id) => '$BASE_URL/api/owner/agents/$id/reject';
  static const String ALL_AGENTS = '$BASE_URL/api/agents';
  static const String OWNER_DASHBOARD = '$BASE_URL/api/dashboard/owner';
  static const String UPLOAD_IMAGE = '$BASE_URL/api/upload/image';
}
