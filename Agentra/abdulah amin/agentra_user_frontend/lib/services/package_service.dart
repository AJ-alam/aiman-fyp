import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/package.dart';
import 'auth_service.dart';

class PackageService {
  static Future<List<Package>> getPackages({String? search}) async {
    try {
      String url = ApiConfig.PACKAGES;
      if (search != null && search.isNotEmpty) {
        url = '${ApiConfig.SEARCH}?q=$search';
      }

      print('🔵 Fetching packages from: $url');

      final response = await http.get(Uri.parse(url));

      print('🟢 Packages Status: ${response.statusCode}');
      print('🟢 Packages Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> packagesJson = data['packages'] ?? data['data'] ?? [];
        return packagesJson.map((json) => Package.fromJson(json)).toList();
      }
    } catch (e) {
      print('🔴 Get packages error: $e');
    }
    return [];
  }

  static Future<Package?> getPackageDetail(String id) async {
    try {
      print('🔵 Fetching package detail: $id');
      
      final response = await http.get(
        Uri.parse(ApiConfig.packageDetail(id)),
      );

      print('🟢 Package Detail Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Package.fromJson(data['package']);
      }
    } catch (e) {
      print('🔴 Get package detail error: $e');
    }
    return null;
  }

  static Future<bool> createBooking({
    required String packageId,
    required int seats,
    required String travelDate,
    required String paymentMethod,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse(ApiConfig.BOOKINGS),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'packageId': packageId,
          'seats': seats,
          'travelDate': travelDate,
          'paymentMethod': paymentMethod,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('🔴 Create booking error: $e');
      return false;
    }
  }
}