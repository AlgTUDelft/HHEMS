import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier for handling theme quick switching.
class ThemeNotifier extends ChangeNotifier {
  static const themePrefKey = 'isDarkMode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get currentTheme => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeNotifier._();

  /// Initialize the notifier.
  static Future<ThemeNotifier> create() async {
    final themeNotifier = ThemeNotifier._();
    await themeNotifier._loadThemePreference();
    return themeNotifier;
  }

  /// Method for changing the theme.
  void toggleTheme(bool isOn) async {
    _isDarkMode = isOn;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themePrefKey, _isDarkMode);
  }

  /// Method for loading the theme on startup.
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(themePrefKey) ?? false;
    notifyListeners();
  }
}
