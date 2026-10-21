import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../models/news_category.dart';
import '../services/news_api_service.dart';
import '../services/news_cache_service.dart';

/// Holds the news for each category. Shows saved news first, then fresh news.
class NewsProvider extends ChangeNotifier {
  static const Duration _freshFor = Duration(minutes: 15);

  final NewsApiService _apiService;
  final NewsCacheService _cacheService;

  NewsProvider({NewsApiService? apiService, NewsCacheService? cacheService})
    : _apiService = apiService ?? NewsApiService(),
      _cacheService = cacheService ?? NewsCacheService();

  String _selectedCategory = NewsCategory.all.first.id;
  final Map<String, List<Article>> _articlesByCategory = {};
  final Map<String, DateTime> _savedAtByCategory = {};
  final Map<String, String?> _errorsByCategory = {};
  final Set<String> _loadingCategories = {};
  final Set<String> _offlineCategories = {};

  String get selectedCategory => _selectedCategory;
  List<Article> get articles => articlesFor(_selectedCategory);
  bool get isLoading => isLoadingFor(_selectedCategory);
  String? get errorMessage => errorFor(_selectedCategory);
  bool get isOffline => _offlineCategories.contains(_selectedCategory);
  DateTime? get savedAt => _savedAtByCategory[_selectedCategory];

  /// The news we already have for any category (no API call).
  List<Article> articlesFor(String categoryId) {
    return _articlesByCategory[categoryId] ?? [];
  }

  bool isLoadingFor(String categoryId) {
    return _loadingCategories.contains(categoryId);
  }

  String? errorFor(String categoryId) => _errorsByCategory[categoryId];

  /// Switches category. The 15-minute rule decides if we call the API.
  void selectCategory(String categoryId) {
    if (categoryId == _selectedCategory) return;

    _selectedCategory = categoryId;
    notifyListeners();
    loadNews();
  }

  /// For pull to refresh and "Try again": always asks the API.
  Future<void> refresh() => loadNews(forceRefresh: true);

  /// Loads [categoryId] (or the selected category if null).
  /// 1. Show saved news from the phone. 2. Skip the API if the news is fresh.
  /// 3. Otherwise get fresh news from the API and save it.
  Future<void> loadNews({
    String? categoryId,
    bool forceRefresh = false,
  }) async {
    final category = categoryId ?? _selectedCategory;
    if (_loadingCategories.contains(category)) return;

    _loadingCategories.add(category);
    _errorsByCategory[category] = null;
    notifyListeners();

    if (!_articlesByCategory.containsKey(category)) {
      final cached = await _cacheService.load(category);
      if (cached != null) {
        _articlesByCategory[category] = cached.articles;
        _savedAtByCategory[category] = cached.savedAt;
        notifyListeners();
      }
    }

    if (!forceRefresh && _isFresh(category)) {
      _loadingCategories.remove(category);
      notifyListeners();
      return;
    }

    try {
      final freshNews = await _fetchFromApi(category);
      final now = DateTime.now();
      _articlesByCategory[category] = freshNews;
      _savedAtByCategory[category] = now;
      _offlineCategories.remove(category);
      await _cacheService.save(category, freshNews, now);
    } on NewsApiException catch (e) {
      _errorsByCategory[category] = e.message;
      if (e.isNoInternet) {
        _offlineCategories.add(category);
      } else {
        _offlineCategories.remove(category);
      }
    } catch (e) {
      _errorsByCategory[category] = 'Something went wrong. Please try again.';
      _offlineCategories.remove(category);
      debugPrint('loadNews error: $e');
    }

    _loadingCategories.remove(category);
    notifyListeners();
  }

  /// Deletes saved news (phone + memory), then loads fresh news.
  Future<void> clearCache() async {
    await _cacheService.clearAll();
    _articlesByCategory.clear();
    _savedAtByCategory.clear();
    _errorsByCategory.clear();
    _offlineCategories.clear();
    notifyListeners();
    await loadNews();
  }

  /// Sri Lanka uses search (title only). Other categories use top headlines.
  Future<List<Article>> _fetchFromApi(String categoryId) {
    final category = NewsCategory.byId(categoryId);
    if (category.usesSearch) {
      return _apiService.searchNews(category.searchQuery!, searchIn: 'title');
    }
    return _apiService.fetchTopHeadlines(category: category.id);
  }

  bool _isFresh(String category) {
    final savedAt = _savedAtByCategory[category];
    if (savedAt == null) return false;
    return DateTime.now().difference(savedAt) < _freshFor;
  }
}