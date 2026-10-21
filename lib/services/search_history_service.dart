import 'package:shared_preferences/shared_preferences.dart';

/// Saves the recent search words on the phone, so they stay after the app closes.
class SearchHistoryService {
  static const String _key = 'search_history';

  final SharedPreferencesAsync _prefs;

  SearchHistoryService({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();

  Future<List<String>> load() async {
    return await _prefs.getStringList(_key) ?? [];
  }

  Future<void> save(List<String> history) async {
    await _prefs.setStringList(_key, history);
  }
}