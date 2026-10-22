import 'package:daily_pulse/models/article.dart';
import 'package:daily_pulse/models/suggestion.dart';
import 'package:daily_pulse/utils/search_suggestions.dart';
import 'package:flutter_test/flutter_test.dart';

/// A small article with only a title (other fields don't matter here).
Article _article(String title) {
  return Article(
    title: title,
    description: '',
    imageUrl: '',
    sourceName: 'Test',
    publishedAt: DateTime.utc(2026, 10, 20),
    url: 'https://example.com/$title',
  );
}

void main() {
  group('buildSuggestions', () {
    test('returns nothing for empty text', () {
      final result = buildSuggestions(
        query: '  ',
        history: ['Cricket'],
        topics: ['Climate'],
        articles: [],
      );

      expect(result, isEmpty);
    });

    test('puts recent searches first, then topics', () {
      final result = buildSuggestions(
        query: 'cri',
        history: ['Cricket world cup'],
        topics: ['Cricket', 'Climate'],
        articles: [],
      );

      expect(result.map((s) => s.text), ['Cricket world cup', 'Cricket']);
      expect(result.first.type, SuggestionType.recent);
      expect(result.last.type, SuggestionType.topic);
    });

    test('has no duplicates (ignores upper/lower case)', () {
      final result = buildSuggestions(
        query: 'cri',
        history: ['Cricket'],
        topics: ['cricket', 'CRICKET'],
        articles: [],
      );

      expect(result.length, 1);
      expect(result.single.type, SuggestionType.recent);
    });

    test('does not suggest exactly what was typed', () {
      final result = buildSuggestions(
        query: 'cricket',
        history: [],
        topics: ['Cricket'],
        articles: [],
      );

      expect(result, isEmpty);
    });

    test('matches the start of a later word', () {
      final result = buildSuggestions(
        query: 'cup',
        history: ['Cricket world cup'],
        topics: [],
        articles: [],
      );

      expect(result.single.text, 'Cricket world cup');
    });

    test('finds words from news titles, most used first', () {
      final result = buildSuggestions(
        query: 'cri',
        history: [],
        topics: [],
        articles: [
          _article('Crime in the city'),
          _article('Cricket match today'),
          _article('More cricket news'),
        ],
      );

      expect(result.map((s) => s.text), ['Cricket', 'Crime']);
      expect(result.first.type, SuggestionType.word);
    });

    test('never returns more than the limit', () {
      final result = buildSuggestions(
        query: 'a',
        history: [],
        topics: ['a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7', 'a8'],
        articles: [],
      );

      expect(result.length, 6);
    });
  });

  group('findInTitles', () {
    final articles = [
      _article('AI helps doctors'),
      _article('Rain in Colombo'),
      _article('New AI phone'),
    ];

    test('needs at least 2 letters', () {
      expect(findInTitles('a', articles), isEmpty);
    });

    test('finds titles that contain the text (any case)', () {
      final result = findInTitles('ai', articles);

      expect(result.map((a) => a.title), [
        'AI helps doctors',
        'Rain in Colombo',
        'New AI phone',
      ]);
    });

    test('respects the limit', () {
      expect(findInTitles('ai', articles, limit: 1).length, 1);
    });
  });
}