import 'package:flutter/material.dart';

import '../services/settings_service.dart';

/// Holds the theme choice: light, dark or system (same as the phone).
class ThemeProvider extends ChangeNotifier {
  final SettingsService _service;

  ThemeProvider({SettingsService? service})
    : _service = service ?? SettingsService();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Reads the saved choice from the phone (called once at start).
  Future<void> load() async {
    try {
      _themeMode = await _service.loadThemeMode();
      notifyListeners();
    } catch (e) {
      debugPrint('loadTheme error: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    try {
      await _service.saveThemeMode(mode);
    } catch (e) {
      debugPrint('saveTheme error: $e');
    }
  }
}