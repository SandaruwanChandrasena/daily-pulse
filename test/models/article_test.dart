import 'package:daily_pulse/models/article.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Article.fromJson', () {
    test('reads all fields from NewsAPI JSON', () {
      final article = Article.fromJson({
        'source': {'id': null, 'name': 'BBC News'},
        'title': 'Rain in Colombo',
        'description': 'Heavy rain today.',
        'url': 'https://bbc.com/rain',
        'urlToImage': 'https://bbc.com/rain.jpg',
        'publishedAt': '2026-10-19T06:30:00Z',
      });

      expect(article.title, 'Rain in Colombo');
      expect(article.description, 'Heavy rain today.');
      expect(article.url, 'https://bbc.com/rain');
      expect(article.imageUrl, 'https://bbc.com/rain.jpg');
      expect(article.sourceName, 'BBC News');
      expect(article.publishedAt, DateTime.utc(2026, 10, 19, 6, 30));
    });

    test('uses safe defaults when fields are null or missing', () {
      final article = Article.fromJson({
        'source': null,
        'title': null,
        'description': null,
        'url': null,
        'urlToImage': null,
        'publishedAt': 'not a date',
      });

      expect(article.title, 'No title');
      expect(article.description, '');
      expect(article.url, '');
      expect(article.imageUrl, '');
      expect(article.sourceName, 'Unknown source');
      expect(
        DateTime.now().difference(article.publishedAt).inMinutes,
        lessThan(1),
      );
    });

    test('removes " - Source" from the end of the title', () {
      final article = Article.fromJson({
        'source': {'name': 'Axios'},
        'title': 'Big news today - Axios',
      });

      expect(article.title, 'Big news today');
    });

    test('keeps the title if the ending is a different source', () {
      final article = Article.fromJson({
        'source': {'name': 'Axios'},
        'title': 'Big news today - Reuters',
      });

      expect(article.title, 'Big news today - Reuters');
    });
  });

  group('Article.toJson', () {
    test('toJson then fromJson gives the same article', () {
      final original = Article(
        title: 'Cricket final',
        description: 'Sri Lanka wins.',
        imageUrl: 'https://example.com/a.jpg',
        sourceName: 'ESPN',
        publishedAt: DateTime.utc(2026, 10, 20, 8),
        url: 'https://example.com/a',
      );

      final copy = Article.fromJson(original.toJson());

      expect(copy.title, original.title);
      expect(copy.description, original.description);
      expect(copy.imageUrl, original.imageUrl);
      expect(copy.sourceName, original.sourceName);
      expect(copy.publishedAt, original.publishedAt);
      expect(copy.url, original.url);
    });
  });
}