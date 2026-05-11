import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AdminService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.OWNER_LOGIN),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        if (data['token'] != null) {
          await prefs.setString('token', data['token']);
          await prefs.setBool('isAdmin', true);
        }
        return {'success': true};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
  static Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('owner_token');
}
static Future<List<dynamic>> getAllAgents() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return [];

    final response = await http.get(
      Uri.parse(ApiConfig.ALL_AGENTS),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['agents'] ?? [];
    }
    return [];
  } catch (e) {
    print('Get all agents error: $e');
    return [];
  }
}

static Future<Map<String, dynamic>> getOwnerDashboard() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return {};

    final response = await http.get(
      Uri.parse(ApiConfig.OWNER_DASHBOARD),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {};
  } catch (e) {
    print('Owner dashboard error: $e');
    return {};
  }
}

  static Future<List<dynamic>> getUnverifiedAgents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(ApiConfig.UNVERIFIED_AGENTS),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['agents'] ?? [];
      }
      return [];
    } catch (e) {
      print('Fetch agents error: $e');
      return [];
    }
  }

  static Future<bool> verifyAgent(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse(ApiConfig.verifyAgent(id)),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Verify agent error: $e');
      return false;
    }
  }

  static Future<bool> rejectAgent(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      print('🔍 Reject Agent Debug:');
      print('  Agent ID: $id');
      print('  Token exists: ${token != null}');
      print('  Token: ${token?.substring(0, 20)}...');
      
      if (token == null) {
        print('❌ No token found');
        return false;
      }

      final url = ApiConfig.rejectAgentAdmin(id);
      print('  URL: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      
      print('  Response Status: ${response.statusCode}');
      print('  Response Body: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Reject agent error: $e');
      return false;
    }
  }

  // ===== NEW APPROVAL WORKFLOW =====
  static Future<List<dynamic>> getPendingAgents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConfig.BASE_URL}/auth/admin/agents/pending'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['agents'] ?? [];
      }
      return [];
    } catch (e) {
      print('Get pending agents error: $e');
      return [];
    }
  }

  static Future<bool> approveAgent(String agentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${ApiConfig.BASE_URL}/auth/admin/agents/$agentId/approve'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Approve agent error: $e');
      return false;
    }
  }

  static Future<bool> rejectAgentApproval(String agentId, {String? reason}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${ApiConfig.BASE_URL}/auth/admin/agents/$agentId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({'reason': reason ?? ''}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Reject agent approval error: $e');
      return false;
    }
  }
}

