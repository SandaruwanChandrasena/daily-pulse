import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../models/news_category.dart';
import '../models/news_page.dart';
import '../services/news_api_service.dart';
import '../services/news_cache_service.dart';

/// Holds the news for each category. Shows saved news first, then fresh news.
/// [loadMore] adds the next page when the user scrolls near the bottom.
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
  final Map<String, int> _pageByCategory = {};
  final Set<String> _noMorePages = {};
  final Set<String> _loadingMoreCategories = {};
  final Map<String, String?> _loadMoreErrors = {};

  String get selectedCategory => _selectedCategory;
  List<Article> get articles => articlesFor(_selectedCategory);
  bool get isLoading => isLoadingFor(_selectedCategory);
  String? get errorMessage => errorFor(_selectedCategory);
  bool get isOffline => _offlineCategories.contains(_selectedCategory);
  DateTime? get savedAt => _savedAtByCategory[_selectedCategory];
  bool get hasMore => !_noMorePages.contains(_selectedCategory);
  bool get isLoadingMore => _loadingMoreCategories.contains(_selectedCategory);
  String? get loadMoreError => _loadMoreErrors[_selectedCategory];

  /// The news we already have for any category (no API call).
  List<Article> articlesFor(String categoryId) {
    return _articlesByCategory[categoryId] ?? [];
  }

  /// All news we have in memory, from every category, with no duplicates.
  List<Article> get allArticles {
    final seenUrls = <String>{};
    return [
      for (final list in _articlesByCategory.values)
        for (final article in list)
          if (seenUrls.add(article.url)) article,
    ];
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
        _restorePaging(category, cached.articles.length);
        notifyListeners();
      }
    }

    if (!forceRefresh && _isFresh(category)) {
      _loadingCategories.remove(category);
      notifyListeners();
      return;
    }

    try {
      final firstPage = await _fetchFromApi(category, page: 1);
      final now = DateTime.now();
      _articlesByCategory[category] = firstPage.articles;
      _savedAtByCategory[category] = now;
      _offlineCategories.remove(category);
      _setPaging(category, page: 1, totalResults: firstPage.totalResults);
      _loadMoreErrors[category] = null;
      await _cacheService.save(category, firstPage.articles, now);
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

  /// Adds the next page to the selected category (no duplicates).
  /// Does nothing while loading, or when there are no more pages.
  Future<void> loadMore() async {
    final category = _selectedCategory;
    if (_loadingCategories.contains(category) ||
        _loadingMoreCategories.contains(category) ||
        _noMorePages.contains(category) ||
        articlesFor(category).isEmpty) {
      return;
    }

    _loadingMoreCategories.add(category);
    _loadMoreErrors[category] = null;
    notifyListeners();

    final nextPage = (_pageByCategory[category] ?? 1) + 1;
    try {
      final page = await _fetchFromApi(category, page: nextPage);
      final current = articlesFor(category);
      final knownUrls = current.map((article) => article.url).toSet();
      final newArticles = page.articles
          .where((article) => knownUrls.add(article.url))
          .toList();

      final all = [...current, ...newArticles];
      _articlesByCategory[category] = all;
      _setPaging(category, page: nextPage, totalResults: page.totalResults);
      if (newArticles.isEmpty) _noMorePages.add(category);
      await _cacheService.save(
        category,
        all,
        _savedAtByCategory[category] ?? DateTime.now(),
      );
    } on NewsApiException catch (e) {
      _loadMoreErrors[category] = e.message;
    } catch (e) {
      _loadMoreErrors[category] = 'Could not load more news.';
      debugPrint('loadMore error: $e');
    }

    _loadingMoreCategories.remove(category);
    notifyListeners();
  }

  /// Deletes saved news (phone + memory), then loads fresh news.
  Future<void> clearCache() async {
    await _cacheService.clearAll();
    _articlesByCategory.clear();
    _savedAtByCategory.clear();
    _errorsByCategory.clear();
    _offlineCategories.clear();
    _pageByCategory.clear();
    _noMorePages.clear();
    _loadMoreErrors.clear();
    notifyListeners();
    await loadNews();
  }

  /// Sri Lanka uses search (title only). Other categories use top headlines.
  Future<NewsPage> _fetchFromApi(String categoryId, {required int page}) {
    final category = NewsCategory.byId(categoryId);
    if (category.usesSearch) {
      return _apiService.searchNews(
        category.searchQuery!,
        searchIn: 'title',
        page: page,
      );
    }
    return _apiService.fetchTopHeadlines(category: category.id, page: page);
  }

  void _setPaging(
    String category, {
    required int page,
    required int totalResults,
  }) {
    _pageByCategory[category] = page;
    final more = NewsApiService.hasMorePages(
      page: page,
      totalResults: totalResults,
    );
    if (more) {
      _noMorePages.remove(category);
    } else {
      _noMorePages.add(category);
    }
  }

  /// Saved news has no page number, so we guess it from the list length.
  void _restorePaging(String category, int length) {
    const pageSize = NewsApiService.pageSize;
    _pageByCategory[category] = length == 0 ? 1 : (length / pageSize).ceil();
    if (length < NewsApiService.maxResults) {
      _noMorePages.remove(category);
    } else {
      _noMorePages.add(category);
    }
  }

  bool _isFresh(String category) {
    final savedAt = _savedAtByCategory[category];
    if (savedAt == null) return false;
    return DateTime.now().difference(savedAt) < _freshFor;
  }
}