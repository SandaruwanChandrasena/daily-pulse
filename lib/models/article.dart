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

    return Article(
      title: (json['title'] as String?)?.trim() ?? 'No title',
      description: (json['description'] as String?)?.trim() ?? '',
      imageUrl: json['urlToImage'] as String? ?? '',
      sourceName: source?['name'] as String? ?? 'Unknown source',
      publishedAt:
          DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
          DateTime.now(),
      url: json['url'] as String? ?? '',
    );
  }
}
