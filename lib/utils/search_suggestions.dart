import '../models/article.dart';
import '../models/suggestion.dart';

/// Builds live suggestions from data already on the phone (no API calls).
/// Order: recent searches, then topics, then common words from news titles.
List<Suggestion> buildSuggestions({
  required String query,
  required List<String> history,
  required List<String> topics,
  required List<Article> articles,
  int limit = 6,
}) {
  final typed = query.trim().toLowerCase();
  if (typed.isEmpty) return [];

  final results = <Suggestion>[];
  final seen = <String>{};

  void addIfMatch(String text, SuggestionType type) {
    final lower = text.toLowerCase();
    if (lower == typed || seen.contains(lower)) return;
    if (!lower.startsWith(typed) && !lower.contains(' $typed')) return;
    seen.add(lower);
    results.add(Suggestion(text, type));
  }

  for (final word in history) {
    addIfMatch(word, SuggestionType.recent);
  }
  for (final topic in topics) {
    addIfMatch(topic, SuggestionType.topic);
  }
  for (final word in _commonTitleWords(articles)) {
    if (results.length >= limit) break;
    addIfMatch(word, SuggestionType.word);
  }

  return results.take(limit).toList();
}

/// Loaded news whose title contains the typed text (the "live results").
List<Article> findInTitles(
  String query,
  List<Article> articles, {
  int limit = 10,
}) {
  final typed = query.trim().toLowerCase();
  if (typed.length < 2) return [];

  return articles
      .where((article) => article.title.toLowerCase().contains(typed))
      .take(limit)
      .toList();
}

/// Words (4+ letters) from all titles, most used first.
List<String> _commonTitleWords(List<Article> articles) {
  final counts = <String, int>{};
  final firstSpelling = <String, String>{};

  for (final article in articles) {
    for (final word in article.title.split(RegExp(r'[^A-Za-z0-9]+'))) {
      if (word.length < 4) continue;
      final lower = word.toLowerCase();
      counts[lower] = (counts[lower] ?? 0) + 1;
      firstSpelling.putIfAbsent(lower, () => word);
    }
  }

  final words = counts.keys.toList()
    ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  return [for (final lower in words) firstSpelling[lower]!];
}