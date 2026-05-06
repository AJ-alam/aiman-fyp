import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/package.dart';
import 'auth_service.dart';

class PackageService {
  static Future<List<Package>> getAgentPackages() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(ApiConfig.AGENT_PACKAGES),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> packagesJson = data['packages'] ?? [];
        return packagesJson.map((json) => Package.fromJson(json)).toList();
      }
    } catch (e) {
      print('Get agent packages error: $e');
    }
    return [];
  }

  static Future<bool> createPackage({
  required String title,
  required String description,
  required String location,
  required double price,
  required String duration,
  required int availableSeats,
  String? image,
  String? province,
  String? departureCity,
  String? notIncluded,
  String? tripHighlights,
  bool includesTransport = false,
  bool includesAccommodation = false,
  bool includesMeals = false,
  bool isFeatured = false,
  bool hasDiscount = false,
  double discountPercentage = 0,
  DateTime? startDate,
  DateTime? endDate,
  List<DateTime> availableDates = const [],
  List<Map<String, dynamic>> itinerary = const [],
}) async {
  try {
    // Check if agent is approved before allowing package creation
    final currentAgent = await AuthService.getCurrentAgent();
    if (currentAgent == null) {
      print('❌ [PACKAGE] No current agent found');
      return false;
    }

    if (currentAgent.status != 'APPROVED') {
      print('⏳ [PACKAGE] Agent not approved. Status: ${currentAgent.status}');
      return false;
    }

    final token = await AuthService.getToken();
    if (token == null) {
      print('❌ [PACKAGE] No auth token found');
      return false;
    }

    print('📦 [PACKAGE] Creating package: $title');
    print('🔗 [PACKAGE] URL: ${ApiConfig.PACKAGES}');

    final requestBody = {
      'title': title,
      'description': description,
      'location': location,
      'price': price,
      'duration': duration,
      'availableSeats': availableSeats,
      'image': image,
      'province': province,
      'departureCity': departureCity,
      'notIncluded': notIncluded,
      'tripHighlights': tripHighlights,
      'includes': {
        'transport': includesTransport,
        'accommodation': includesAccommodation,
        'meals': includesMeals,
      },
      'isFeatured': isFeatured,
      'hasDiscount': hasDiscount,
      'discountPercentage': discountPercentage,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'availableDates': availableDates.map((d) => d.toIso8601String()).toList(),
      'itinerary': itinerary,
    };

    print('📤 [PACKAGE] Request body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse(ApiConfig.PACKAGES),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: jsonEncode(requestBody),
    );

    print('📥 [PACKAGE] Response status: ${response.statusCode}');
    print('📥 [PACKAGE] Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ [PACKAGE] Package created successfully');
      return true;
    } else {
      print('❌ [PACKAGE] Package creation failed: ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ [PACKAGE] Exception: $e');
    return false;
  }
}

  static Future<bool> updatePackage(String id, Map<String, dynamic> updateData) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse(ApiConfig.packageDetail(id)),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(updateData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update package error: $e');
      return false;
    }
  }

  static Future<bool> deletePackage(String id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse(ApiConfig.packageDetail(id)),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Delete package error: $e');
      return false;
    }
  }
 static Future<String?> uploadImage(dynamic imageFile) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/dk66ra1nm/image/upload'),
    );

    request.fields['upload_preset'] = 'agentra_packages';
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = jsonDecode(body);

    if (response.statusCode == 200) {
      return data['secure_url'];
    }
    return null;
  } catch (e) {
    print('Upload image error: $e');
    return null;
  }
}
}
