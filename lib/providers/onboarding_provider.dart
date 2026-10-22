import 'package:flutter/foundation.dart';

import '../services/settings_service.dart';

/// Knows if the welcome screens were finished, and the user's interests.
class OnboardingProvider extends ChangeNotifier {
  final SettingsService _service;

  OnboardingProvider({SettingsService? service})
    : _service = service ?? SettingsService();

  bool _isReady = false;
  bool _isDone = false;
  List<String> _interests = [];

  /// False until the saved values are read from the phone.
  bool get isReady => _isReady;
  bool get isDone => _isDone;
  List<String> get interests => List.unmodifiable(_interests);

  /// Reads the saved values (called once at start).
  Future<void> load() async {
    try {
      _isDone = await _service.loadOnboardingDone();
      _interests = await _service.loadInterests();
    } catch (e) {
      debugPrint('loadOnboarding error: $e');
    }
    _isReady = true;
    notifyListeners();
  }

  /// Ends the welcome screens. Skip passes null to keep the old interests.
  Future<void> finish({List<String>? interests}) async {
    if (interests != null) await saveInterests(interests);
    _isDone = true;
    notifyListeners();
    try {
      await _service.saveOnboardingDone(true);
    } catch (e) {
      debugPrint('saveOnboarding error: $e');
    }
  }

  Future<void> saveInterests(List<String> interests) async {
    _interests = List.of(interests);
    notifyListeners();
    try {
      await _service.saveInterests(_interests);
    } catch (e) {
      debugPrint('saveInterests error: $e');
    }
  }

  /// Shows the welcome screens again (Settings → for demos and testing).
  Future<void> showAgain() async {
    _isDone = false;
    notifyListeners();
    try {
      await _service.saveOnboardingDone(false);
    } catch (e) {
      debugPrint('saveOnboarding error: $e');
    }
  }
}