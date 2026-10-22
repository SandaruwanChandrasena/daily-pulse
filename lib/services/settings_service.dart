import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Saves the user's settings on the phone:
/// theme choice, "welcome screens done" and the chosen news interests.
class SettingsService {
  static const String _themeKey = 'theme_mode';
  static const String _onboardingKey = 'onboarding_done';
  static const String _interestsKey = 'interests';

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

  Future<bool> loadOnboardingDone() async {
    return await _prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> saveOnboardingDone(bool done) async {
    await _prefs.setBool(_onboardingKey, done);
  }

  /// Category ids the user picked, like ['srilanka', 'sports'].
  Future<List<String>> loadInterests() async {
    return await _prefs.getStringList(_interestsKey) ?? [];
  }

  Future<void> saveInterests(List<String> categoryIds) async {
    await _prefs.setStringList(_interestsKey, categoryIds);
  }
}