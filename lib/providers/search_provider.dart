import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../services/news_api_service.dart';

/// Holds the search results and tells the Search screen when they change.
class SearchProvider extends ChangeNotifier {
  final NewsApiService _apiService;

  SearchProvider({NewsApiService? apiService})
    : _apiService = apiService ?? NewsApiService();

  List<Article> _articles = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _query = '';

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  bool get hasSearched => _query.isNotEmpty;

  /// Searches the API. Skips the call if we already have results for this word.
  Future<void> search(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

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

  /// Clears the search box results.
  void clear() {
    _query = '';
    _articles = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
