import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_keys.dart';
import '../models/article.dart';

/// A simple error with a message we can show to the user.
class NewsApiException implements Exception {
  final String message;

  const NewsApiException(this.message);

  @override
  String toString() => message;
}

/// Talks to NewsAPI.org. Only this file knows about URLs and JSON.
class NewsApiService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _country = 'us';
  static const Duration _timeout = Duration(seconds: 15);
  static const String _noInternetMessage =
      'No internet connection. Please check your network and try again.';

  final http.Client _client;

  /// We can pass a fake client in tests. In the app we use a real one.
  NewsApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Gets the top news. [category] is optional (like 'sports').
  Future<List<Article>> fetchTopHeadlines({String? category}) async {
    final uri = Uri.parse('$_baseUrl/top-headlines').replace(
      queryParameters: {
        'country': _country,
        // "?category" adds this entry only when category is not null.
        'category': ?category,
        'pageSize': '30',
      },
    );

    return _getArticles(uri);
  }

  /// Searches all news for a keyword (newest first).
  Future<List<Article>> searchNews(String query) async {
    final uri = Uri.parse('$_baseUrl/everything').replace(
      queryParameters: {
        'q': query,
        'language': 'en',
        'sortBy': 'publishedAt',
        'pageSize': '30',
      },
    );

    return _getArticles(uri);
  }

  /// Sends the request and turns the JSON into a list of Articles.
  Future<List<Article>> _getArticles(Uri uri) async {
    final http.Response response;

    try {
      response = await _client
          .get(uri, headers: {'X-Api-Key': ApiKeys.newsApiKey})
          .timeout(_timeout);
    } on SocketException {
      throw const NewsApiException(_noInternetMessage);
    } on http.ClientException {
      // On Android, the http package often wraps "no internet" errors
      // inside a ClientException. So we show the same message.
      throw const NewsApiException(_noInternetMessage);
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

    return items
        .map((item) => Article.fromJson(item as Map<String, dynamic>))
        // NewsAPI sends "[Removed]" for deleted news. We hide those.
        .where((article) => article.title != '[Removed]')
        .toList();
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
