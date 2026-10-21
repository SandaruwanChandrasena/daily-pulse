import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../services/news_api_service.dart';
import '../services/search_history_service.dart';

/// Holds the search results and the recent searches for the Search screen.
class SearchProvider extends ChangeNotifier {
  static const int _maxHistory = 10;

  final NewsApiService _apiService;
  final SearchHistoryService _historyService;

  SearchProvider({
    NewsApiService? apiService,
    SearchHistoryService? historyService,
  }) : _apiService = apiService ?? NewsApiService(),
       _historyService = historyService ?? SearchHistoryService();

  List<Article> _articles = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _query = '';
  List<String> _history = [];

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  bool get hasSearched => _query.isNotEmpty;
  List<String> get history => _history;

  /// Reads the saved recent searches from the phone (called once at start).
  Future<void> loadHistory() async {
    try {
      _history = await _historyService.load();
      notifyListeners();
    } catch (e) {
      debugPrint('loadHistory error: $e');
    }
  }

  /// Searches the API. Skips the call if we already have results for this word.
  Future<void> search(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _addToHistory(query);

    final sameAsBefore = query.toLowerCase() == _query.toLowerCase();
    if (sameAsBefore && _isLoading) return;
    if (sameAsBefore && _articles.isNotEmpty && _errorMessage == null) return;

    _query = query;
    _articles = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _apiService.searchNews(query);
      if (query != _query) return;
      _articles = results;
    } on NewsApiException catch (e) {
      if (query != _query) return;
      _errorMessage = e.message;
    } catch (e) {
      if (query != _query) return;
      _errorMessage = 'Something went wrong. Please try again.';
      debugPrint('search error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Runs the last search again (used by the "Try again" button).
  Future<void> retry() {
    final lastQuery = _query;
    _query = '';
    return search(lastQuery);
  }

  /// Clears the results, so the recent searches show again.
  void clear() {
    _query = '';
    _articles = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void removeFromHistory(String word) {
    _history = _history.where((item) => item != word).toList();
    _saveHistory();
  }

  void clearHistory() {
    _history = [];
    _saveHistory();
  }

  /// Puts the word at the top of the list, with no duplicates and max 10 words.
  void _addToHistory(String word) {
    final lower = word.toLowerCase();
    _history = [
      word,
      ..._history.where((item) => item.toLowerCase() != lower),
    ].take(_maxHistory).toList();
    _saveHistory();
  }

  Future<void> _saveHistory() async {
    notifyListeners();
    try {
      await _historyService.save(_history);
    } catch (e) {
      debugPrint('saveHistory error: $e');
    }
  }
}