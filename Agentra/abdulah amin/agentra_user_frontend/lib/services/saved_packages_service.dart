import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/package.dart';
import '../services/auth_service.dart';

class SavedPackagesService {
  /// Fetch all saved packages for the logged-in user from the backend.
  static Future<List<Package>> getSavedPackages() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(ApiConfig.SAVED_PACKAGES),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List raw = data['savedPackages'] ?? [];
        return raw
            .map((sp) {
              final pkgData = sp['packageId'];
              if (pkgData is Map<String, dynamic>) {
                return Package.fromJson(pkgData);
              }
              return null;
            })
            .whereType<Package>()
            .toList();
      }
    } catch (e) {
      print('SavedPackagesService.getSavedPackages error: $e');
    }
    return [];
  }

  /// Check if a package is saved by the current user.
  static Future<bool> isPackageSaved(String packageId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('${ApiConfig.SAVED_PACKAGES}/$packageId/check'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isSaved'] == true;
      }
    } catch (e) {
      print('SavedPackagesService.isPackageSaved error: $e');
    }
    return false;
  }

  /// Save a package for the current user (persisted in the database).
  static Future<bool> savePackage(Package package) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConfig.SAVED_PACKAGES}/${package.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      // 400 means already saved — treat as success
      if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        if (data['message']?.toString().contains('already saved') == true) {
          return true;
        }
      }
    } catch (e) {
      print('SavedPackagesService.savePackage error: $e');
    }
    return false;
  }

  /// Remove a saved package for the current user.
  static Future<bool> unsavePackage(String packageId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConfig.SAVED_PACKAGES}/$packageId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('SavedPackagesService.unsavePackage error: $e');
    }
    return false;
  }
}
