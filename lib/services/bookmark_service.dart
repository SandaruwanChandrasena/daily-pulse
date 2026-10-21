import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

/// Saves bookmarked news on the phone, so it stays after the app closes.
/// Each article is stored as one JSON string.
class BookmarkService {
  static const String _key = 'bookmarks';

  final SharedPreferencesAsync _prefs;

  BookmarkService({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();

  Future<List<Article>> load() async {
    final items = await _prefs.getStringList(_key) ?? [];
    final articles = <Article>[];

    for (final item in items) {
      try {
        final json = jsonDecode(item) as Map<String, dynamic>;
        articles.add(Article.fromJson(json));
      } catch (e) {
        debugPrint('Skipped a broken bookmark: $e');
      }
    }
    return articles;
  }

  Future<void> save(List<Article> articles) async {
    final items = [
      for (final article in articles) jsonEncode(article.toJson()),
    ];
    await _prefs.setStringList(_key, items);
  }
}