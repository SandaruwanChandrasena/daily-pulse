import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../services/bookmark_service.dart';

/// Holds the saved news. The article url is used as its ID.
class BookmarkProvider extends ChangeNotifier {
  final BookmarkService _service;

  BookmarkProvider({BookmarkService? service})
    : _service = service ?? BookmarkService();

  List<Article> _saved = [];

  List<Article> get saved => List.unmodifiable(_saved);

  /// Reads the saved news from the phone (called once at start).
  Future<void> load() async {
    try {
      _saved = await _service.load();
      notifyListeners();
    } catch (e) {
      debugPrint('loadBookmarks error: $e');
    }
  }

  bool isBookmarked(Article article) {
    return _saved.any((item) => item.url == article.url);
  }

  /// Saves the article. [index] is used by "Undo" to put it back in place.
  void add(Article article, {int index = 0}) {
    if (isBookmarked(article)) return;
    final safeIndex = index.clamp(0, _saved.length);
    _saved = [..._saved]..insert(safeIndex, article);
    _saveToPhone();
  }

  /// Removes the article and returns where it was (for "Undo").
  int remove(Article article) {
    final index = _saved.indexWhere((item) => item.url == article.url);
    if (index == -1) return 0;
    _saved = [..._saved]..removeAt(index);
    _saveToPhone();
    return index;
  }

  void clearAll() {
    _saved = [];
    _saveToPhone();
  }

  Future<void> _saveToPhone() async {
    notifyListeners();
    try {
      await _service.save(_saved);
    } catch (e) {
      debugPrint('saveBookmarks error: $e');
    }
  }
}