/// One news item.
class Article {
  final String title;
  final String description;
  final String imageUrl;
  final String sourceName;
  final DateTime publishedAt;
  final String url;

  const Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
    required this.url,
  });

  /// Builds an Article from one item in the NewsAPI "articles" list.
  ///
  /// The API can send null for many fields, so we give each one a safe default.
  /// Example JSON:
  /// {
  ///   "source": {"id": null, "name": "BBC News"},
  ///   "title": "Some title",
  ///   "description": "Short text",
  ///   "url": "https://...",
  ///   "urlToImage": "https://...jpg",
  ///   "publishedAt": "2026-10-19T06:30:00Z"
  /// }
  factory Article.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as Map<String, dynamic>?;
    final sourceName = source?['name'] as String? ?? 'Unknown source';
    final title = (json['title'] as String?)?.trim() ?? 'No title';

    return Article(
      title: _removeSourceFromTitle(title, sourceName),
      description: (json['description'] as String?)?.trim() ?? '',
      imageUrl: json['urlToImage'] as String? ?? '',
      sourceName: sourceName,
      publishedAt:
          DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
          DateTime.now(),
      url: json['url'] as String? ?? '',
    );
  }

  /// NewsAPI often adds " - Axios" to the end of the title. We remove it,
  /// because the source name is already shown under the title.
  static String _removeSourceFromTitle(String title, String sourceName) {
    final ending = ' - $sourceName';
    if (title.endsWith(ending) && title.length > ending.length) {
      return title.substring(0, title.length - ending.length).trim();
    }
    return title;
  }

  /// Turns the Article back into JSON in the same shape as NewsAPI,
  /// so [Article.fromJson] can read it again (used to save news on the phone).
  Map<String, dynamic> toJson() {
    return {
      'source': {'name': sourceName},
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': imageUrl,
      'publishedAt': publishedAt.toIso8601String(),
    };
  }
}