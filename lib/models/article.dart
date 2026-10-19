/// One news item.
/// In Stage 2 we will add a fromJson() method to build this from API data.
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
}
