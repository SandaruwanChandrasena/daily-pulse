import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Saves the user's settings on the phone (now: the theme choice).
class SettingsService {
  static const String _themeKey = 'theme_mode';

  final SharedPreferencesAsync _prefs;

  SettingsService({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();

  /// Reads the saved theme. Unknown or missing → follow the phone (system).
  Future<ThemeMode> loadThemeMode() async {
    final name = await _prefs.getString(_themeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.name);
  }
}