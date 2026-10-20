import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../models/news_category.dart';
import '../services/news_api_service.dart';

/// Holds the news for each category and tells the UI when it changes.
class NewsProvider extends ChangeNotifier {
  final NewsApiService _apiService;

  NewsProvider({NewsApiService? apiService})
    : _apiService = apiService ?? NewsApiService();

  String _selectedCategory = NewsCategory.all.first.id;
  final Map<String, List<Article>> _articlesByCategory = {};
  final Map<String, String?> _errorsByCategory = {};
  final Set<String> _loadingCategories = {};

  String get selectedCategory => _selectedCategory;
  List<Article> get articles => _articlesByCategory[_selectedCategory] ?? [];
  bool get isLoading => _loadingCategories.contains(_selectedCategory);
  String? get errorMessage => _errorsByCategory[_selectedCategory];

  /// Switches category. Uses saved news if we already have it (saves API calls).
  void selectCategory(String categoryId) {
    if (categoryId == _selectedCategory) return;

    _selectedCategory = categoryId;
    notifyListeners();

    final hasSavedNews = _articlesByCategory[categoryId]?.isNotEmpty ?? false;
    if (!hasSavedNews && !isLoading) {
      loadTopHeadlines();
    }
  }

  /// Gets fresh news for the selected category from the API.
  Future<void> loadTopHeadlines() async {
    final category = _selectedCategory;

    _loadingCategories.add(category);
    _errorsByCategory[category] = null;
    notifyListeners();

    try {
      _articlesByCategory[category] = await _apiService.fetchTopHeadlines(
        category: category,
      );
    } on NewsApiException catch (e) {
      _errorsByCategory[category] = e.message;
    } catch (e) {
      _errorsByCategory[category] = 'Something went wrong. Please try again.';
      debugPrint('loadTopHeadlines error: $e');
    }

    _loadingCategories.remove(category);
    notifyListeners();
  }
}
