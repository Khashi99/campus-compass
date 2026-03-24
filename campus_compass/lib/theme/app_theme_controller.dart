import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController._();

  static const preferenceKey = 'profile_dark_mode';
  static final AppThemeController instance = AppThemeController._();

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(preferenceKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) {
      return;
    }

    _isDarkMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(preferenceKey, value);
  }
}
