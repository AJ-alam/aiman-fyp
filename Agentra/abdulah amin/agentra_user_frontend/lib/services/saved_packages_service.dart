import 'package:shared_preferences/shared_preferences.dart';
import '../models/package.dart';
import 'dart:convert';

class SavedPackagesService {
  static const String _key = 'saved_packages';

  static Future<List<Package>> getSavedPackages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList(_key) ?? [];
    return savedList.map((e) => Package.fromJson(jsonDecode(e))).toList();
  }

  static Future<bool> isPackageSaved(String packageId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList(_key) ?? [];
    return savedList.any((e) => jsonDecode(e)['_id'].toString() == packageId);
  }

  static Future<void> savePackage(Package package) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList(_key) ?? [];
    final alreadySaved = savedList
        .any((e) => jsonDecode(e)['_id'].toString() == package.id);
    if (!alreadySaved) {
      savedList.add(jsonEncode(package.toJson()));
      await prefs.setStringList(_key, savedList);
    }
  }

  static Future<void> unsavePackage(String packageId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList(_key) ?? [];
    savedList.removeWhere(
        (e) => jsonDecode(e)['_id'].toString() == packageId);
    await prefs.setStringList(_key, savedList);
  }
}