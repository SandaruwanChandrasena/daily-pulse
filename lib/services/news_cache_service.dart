import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

/// News loaded from the phone, plus the time it was saved.
class CachedNews {
  final List<Article> articles;
  final DateTime savedAt;

  const CachedNews({required this.articles, required this.savedAt});
}

/// Saves the last news list of each category on the phone, for offline use.
class NewsCacheService {
  static const String _keyPrefix = 'news_cache_';

  final SharedPreferencesAsync _prefs;

  NewsCacheService({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();

  /// Returns the saved news, or null if there is nothing saved (or it is broken).
  Future<CachedNews?> load(String category) async {
    try {
      final text = await _prefs.getString('$_keyPrefix$category');
      if (text == null) return null;

      final data = jsonDecode(text) as Map<String, dynamic>;
      final items = data['articles'] as List<dynamic>;

      return CachedNews(
        savedAt: DateTime.parse(data['savedAt'] as String),
        articles: items
            .map((item) => Article.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      debugPrint('cache load error: $e');
      return null;
    }
  }

  Future<void> save(
    String category,
    List<Article> articles,
    DateTime savedAt,
  ) async {
    try {
      final text = jsonEncode({
        'savedAt': savedAt.toIso8601String(),
        'articles': articles.map((article) => article.toJson()).toList(),
      });
      await _prefs.setString('$_keyPrefix$category', text);
    } catch (e) {
      debugPrint('cache save error: $e');
    }
  }
}