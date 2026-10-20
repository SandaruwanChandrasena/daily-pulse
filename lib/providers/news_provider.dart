import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../services/news_api_service.dart';

/// Holds the news list and tells the UI when it changes.
///
/// The UI only reads 3 things from here:
/// - [articles]     the news to show
/// - [isLoading]    true while we wait for the API
/// - [errorMessage] a message to show if something failed
class NewsProvider extends ChangeNotifier {
  final NewsApiService _apiService;

  NewsProvider({NewsApiService? apiService})
    : _apiService = apiService ?? NewsApiService();

  List<Article> _articles = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Gets the top news from the API.
  Future<void> loadTopHeadlines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // UI shows the spinner

    try {
      _articles = await _apiService.fetchTopHeadlines();
    } on NewsApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      debugPrint('loadTopHeadlines error: $e');
    }

    _isLoading = false;
    notifyListeners(); // UI shows the news or the error
  }
}
