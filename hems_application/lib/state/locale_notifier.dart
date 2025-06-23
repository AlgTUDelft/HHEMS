import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier for handling language quick switching.
class LocaleNotifier extends ChangeNotifier {
  static const localePrefKey = 'appLocale';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleNotifier._();

  /// Initialize the notifier.
  static Future<LocaleNotifier> create() async {
    final notifier = LocaleNotifier._();
    await notifier._loadLocale();
    return notifier;
  }

  /// Method for changing the locale.
  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(localePrefKey, newLocale.languageCode);
  }

  /// Method for loading the locale on startup.
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(localePrefKey) ?? 'en';
    _locale = Locale(code);
  }
}
