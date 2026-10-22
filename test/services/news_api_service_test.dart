import 'dart:convert';

import 'package:daily_pulse/services/news_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Builds a fake NewsAPI answer with these article titles.
String _okBody(List<String> titles) {
  return jsonEncode({
    'status': 'ok',
    'totalResults': titles.length,
    'articles': [
      for (final title in titles)
        {
          'source': {'name': 'Test News'},
          'title': title,
          'url': 'https://example.com/$title',
          'publishedAt': '2026-10-20T08:00:00Z',
        },
    ],
  });
}

/// A service that talks to a fake server instead of the internet.
NewsApiService _serviceWith(MockClientHandler handler) {
  return NewsApiService(client: MockClient(handler));
}

Matcher _apiError(String messagePart, {bool isNoInternet = false}) {
  return throwsA(
    isA<NewsApiException>()
        .having((e) => e.message, 'message', contains(messagePart))
        .having((e) => e.isNoInternet, 'isNoInternet', isNoInternet),
  );
}

void main() {
  group('fetchTopHeadlines', () {
    test('returns the articles from a good answer', () async {
      final service = _serviceWith(
        (request) async => http.Response(_okBody(['One', 'Two']), 200),
      );

      final articles = await service.fetchTopHeadlines();

      expect(articles.length, 2);
      expect(articles.first.title, 'One');
    });

    test('hides "[Removed]" articles', () async {
      final service = _serviceWith(
        (request) async =>
            http.Response(_okBody(['One', '[Removed]', 'Two']), 200),
      );

      final articles = await service.fetchTopHeadlines();

      expect(articles.map((a) => a.title), ['One', 'Two']);
    });

    test('sends the right URL and the API key header', () async {
      late http.Request sent;
      final service = _serviceWith((request) async {
        sent = request;
        return http.Response(_okBody([]), 200);
      });

      await service.fetchTopHeadlines(category: 'sports');

      expect(sent.url.path, '/v2/top-headlines');
      expect(sent.url.queryParameters['category'], 'sports');
      expect(sent.url.queryParameters['country'], 'us');
      expect(sent.headers['X-Api-Key'], isNotNull);
    });

    test('does not send a category when none is given', () async {
      late http.Request sent;
      final service = _serviceWith((request) async {
        sent = request;
        return http.Response(_okBody([]), 200);
      });

      await service.fetchTopHeadlines();

      expect(sent.url.queryParameters.containsKey('category'), isFalse);
    });
  });

  group('searchNews', () {
    test('sends the search word and searchIn', () async {
      late http.Request sent;
      final service = _serviceWith((request) async {
        sent = request;
        return http.Response(_okBody(['Cricket news']), 200);
      });

      final articles = await service.searchNews('cricket', searchIn: 'title');

      expect(sent.url.path, '/v2/everything');
      expect(sent.url.queryParameters['q'], 'cricket');
      expect(sent.url.queryParameters['searchIn'], 'title');
      expect(articles.single.title, 'Cricket news');
    });
  });

  group('errors', () {
    test('401 gives an API key message', () {
      final service = _serviceWith(
        (request) async => http.Response(
          jsonEncode({'status': 'error', 'message': 'Bad key'}),
          401,
        ),
      );

      expect(service.fetchTopHeadlines(), _apiError('API key'));
    });

    test('429 gives a daily limit message', () {
      final service = _serviceWith(
        (request) async => http.Response(
          jsonEncode({'status': 'error', 'message': 'Limit'}),
          429,
        ),
      );

      expect(service.fetchTopHeadlines(), _apiError('Too many requests'));
    });

    test('other errors show the message from NewsAPI', () {
      final service = _serviceWith(
        (request) async => http.Response(
          jsonEncode({'status': 'error', 'message': 'Server is sleeping'}),
          500,
        ),
      );

      expect(service.fetchTopHeadlines(), _apiError('Server is sleeping'));
    });

    test('bad JSON gives a "bad data" message', () {
      final service = _serviceWith(
        (request) async => http.Response('<html>not json</html>', 200),
      );

      expect(service.fetchTopHeadlines(), _apiError('bad data'));
    });

    test('no internet is marked as isNoInternet', () {
      final service = _serviceWith(
        (request) async => throw http.ClientException('Failed host lookup'),
      );

      expect(
        service.fetchTopHeadlines(),
        _apiError('No internet', isNoInternet: true),
      );
    });
  });
}