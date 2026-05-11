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
        Uri.parse(ApiConfig.PENDING_AGENTS),
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

      final response = await http.patch(
        Uri.parse(ApiConfig.approveAgent(id)),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      if (response.statusCode != 200) {
        print('Verify agent failed with status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
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
      
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse(ApiConfig.rejectAgent(id)),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({'reason': 'Rejected by Admin'}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Reject agent error: $e');
      return false;
    }
  }

  // ===== NEW APPROVAL WORKFLOW (ALIAS TO ABOVE) =====
  static Future<List<dynamic>> getPendingAgents() => getUnverifiedAgents();
  static Future<bool> approveAgent(String agentId) => verifyAgent(agentId);
  static Future<bool> rejectAgentApproval(String agentId, {String? reason}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse(ApiConfig.rejectAgent(agentId)),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({'reason': reason ?? 'Rejected by Admin'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Reject agent approval error: $e');
      return false;
    }
  }

  static Future<bool> blockAgent(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${ApiConfig.BASE_URL}/owner/agents/$id/block'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Block agent error: $e');
      return false;
    }
  }

  static Future<bool> unblockAgent(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${ApiConfig.BASE_URL}/owner/agents/$id/unblock'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Unblock agent error: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getComplaints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(ApiConfig.COMPLAINTS),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['complaints'] ?? [];
      }
      return [];
    } catch (e) {
      print('Get complaints error: $e');
      return [];
    }
  }

  static Future<bool> resolveComplaint(String id, String responseText) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse(ApiConfig.updateComplaint(id)),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'status': 'RESOLVED',
          'adminResponse': responseText,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Resolve complaint error: $e');
      return false;
    }
  }
}



