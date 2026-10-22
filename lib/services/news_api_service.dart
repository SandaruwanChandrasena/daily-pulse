import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_keys.dart';
import '../models/article.dart';
import '../models/news_page.dart';

/// A simple error with a message we can show to the user.
class NewsApiException implements Exception {
  final String message;
  final bool isNoInternet;

  const NewsApiException(this.message, {this.isNoInternet = false});

  @override
  String toString() => message;
}

/// Talks to NewsAPI.org. Only this file knows about URLs and JSON.
class NewsApiService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _country = 'us';
  static const Duration _timeout = Duration(seconds: 15);

  /// News per page. 4 pages × 25 = 100, the free plan's maximum results.
  static const int pageSize = 25;
  static const int maxResults = 100;
  static const String _noInternetMessage =
      'No internet connection. Please check your network and try again.';

  final http.Client _client;

  /// We can pass a fake client in tests. In the app we use a real one.
  NewsApiService({http.Client? client}) : _client = client ?? http.Client();

  /// True if there is another page after [page] for this list.
  static bool hasMorePages({required int page, required int totalResults}) {
    final limit = totalResults < maxResults ? totalResults : maxResults;
    return page * pageSize < limit;
  }

  /// Gets the top news. [category] is optional (like 'sports').
  Future<NewsPage> fetchTopHeadlines({String? category, int page = 1}) async {
    final uri = Uri.parse('$_baseUrl/top-headlines').replace(
      queryParameters: {
        'country': _country,
        // "?category" adds this entry only when category is not null.
        'category': ?category,
        'pageSize': '$pageSize',
        'page': '$page',
      },
    );

    return _getArticles(uri);
  }

  /// Searches all news for a keyword (newest first).
  /// [searchIn] is optional, like 'title' to only match words in the title.
  Future<NewsPage> searchNews(
    String query, {
    String? searchIn,
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/everything').replace(
      queryParameters: {
        'q': query,
        'searchIn': ?searchIn,
        'language': 'en',
        'sortBy': 'publishedAt',
        'pageSize': '$pageSize',
        'page': '$page',
      },
    );

    return _getArticles(uri);
  }

  /// Sends the request and turns the JSON into a page of Articles.
  Future<NewsPage> _getArticles(Uri uri) async {
    final http.Response response;

    try {
      response = await _client
          .get(uri, headers: {'X-Api-Key': ApiKeys.newsApiKey})
          .timeout(_timeout);
    } on SocketException {
      throw const NewsApiException(_noInternetMessage, isNoInternet: true);
    } on http.ClientException {
      // On Android, the http package often wraps "no internet" errors
      // inside a ClientException. So we show the same message.
      throw const NewsApiException(_noInternetMessage, isNoInternet: true);
    } on TimeoutException {
      throw const NewsApiException(
        'The server is taking too long. Please try again.',
      );
    }

    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const NewsApiException(
        'The server sent bad data. Please try again.',
      );
    }

    if (response.statusCode != 200 || body['status'] != 'ok') {
      throw NewsApiException(_errorMessage(response.statusCode, body));
    }

    final items = body['articles'] as List<dynamic>? ?? [];

    final articles = items
        .map((item) => Article.fromJson(item as Map<String, dynamic>))
        // NewsAPI sends "[Removed]" for deleted news. We hide those.
        .where((article) => article.title != '[Removed]')
        .toList();

    return NewsPage(
      articles: articles,
      totalResults: body['totalResults'] as int? ?? articles.length,
    );
  }

  /// Turns an API error into a friendly message.
  String _errorMessage(int statusCode, Map<String, dynamic> body) {
    switch (statusCode) {
      case 401:
        return 'Your API key is wrong or missing. Check lib/config/api_keys.dart.';
      case 429:
        return 'Too many requests today. The free plan has a daily limit. Try again later.';
      default:
        return body['message'] as String? ??
            'Something went wrong (error $statusCode). Please try again.';
    }
  }
}