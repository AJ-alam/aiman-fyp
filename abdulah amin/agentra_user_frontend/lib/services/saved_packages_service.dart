import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/package.dart';
import 'auth_service.dart';

class SavedPackagesService {
  static Future<List<Package>> getSavedPackages() async {
    final token = await AuthService.getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.SAVED_PACKAGES),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List favorites = data['favorites'] ?? [];
        return favorites.map((e) => Package.fromJson(e)).toList();
      }
    } catch (e) {
      print('Get favorites error: $e');
    }
    return [];
  }

  static Future<bool> isPackageSaved(String packageId) async {
    final favorites = await getSavedPackages();
    return favorites.any((p) => p.id == packageId);
  }

  static Future<void> savePackage(Package package) async {
    await _toggleFavorite(package.id);
  }

  static Future<void> unsavePackage(String packageId) async {
    await _toggleFavorite(packageId);
  }

  static Future<bool> _toggleFavorite(String packageId) async {
    final token = await AuthService.getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.TOGGLE_FAVORITE),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({'packageId': packageId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
    } catch (e) {
      print('Toggle favorite error: $e');
    }
    return false;
  }
}