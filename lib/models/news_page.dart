import 'article.dart';

/// One page of news from the API, plus how many results exist in total.
class NewsPage {
  final List<Article> articles;
  final int totalResults;

  const NewsPage({required this.articles, required this.totalResults});
}