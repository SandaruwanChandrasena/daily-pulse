import '../models/article.dart';

/// Fake news for Stage 1.
/// In Stage 2 we will replace this with real news from the API.
final List<Article> dummyArticles = [
  Article(
    title: 'New Phone Chip Promises Two-Day Battery Life',
    description:
        'A new mobile chip uses less power. Phone makers say batteries may last two full days.',
    imageUrl: 'https://picsum.photos/seed/tech1/800/450',
    sourceName: 'Tech Daily',
    publishedAt: DateTime(2026, 10, 18, 9, 30),
    url: 'https://example.com/news/1',
  ),
  Article(
    title: 'Local Cricket Team Wins Final in Last Over Thriller',
    description:
        'The home team won the final by two wickets. Fans celebrated across the city.',
    imageUrl: 'https://picsum.photos/seed/sports1/800/450',
    sourceName: 'Sports Now',
    publishedAt: DateTime(2026, 10, 17, 20, 15),
    url: 'https://example.com/news/2',
  ),
  Article(
    title: 'Stock Market Rises for Third Day in a Row',
    description:
        'Shares went up again today. Banks and tech companies led the gains.',
    imageUrl: 'https://picsum.photos/seed/business1/800/450',
    sourceName: 'Money Times',
    publishedAt: DateTime(2026, 10, 17, 15, 0),
    url: 'https://example.com/news/3',
  ),
  Article(
    title: 'Doctors Share Simple Tips for Better Sleep',
    description:
        'Go to bed at the same time. Keep your phone away. Doctors say small habits help.',
    imageUrl: 'https://picsum.photos/seed/health1/800/450',
    sourceName: 'Health Weekly',
    publishedAt: DateTime(2026, 10, 16, 8, 45),
    url: 'https://example.com/news/4',
  ),
  Article(
    title: 'New Animated Movie Breaks Opening Weekend Record',
    description:
        'The film earned more money in its first weekend than any animated movie before.',
    imageUrl: 'https://picsum.photos/seed/movie1/800/450',
    sourceName: 'Screen Buzz',
    publishedAt: DateTime(2026, 10, 16, 11, 20),
    url: 'https://example.com/news/5',
  ),
  Article(
    title: 'City Opens New Public Library With Free Wi-Fi',
    description:
        'The new library has study rooms, free internet and a kids corner.',
    imageUrl: 'https://picsum.photos/seed/general1/800/450',
    sourceName: 'City News',
    publishedAt: DateTime(2026, 10, 15, 14, 10),
    url: 'https://example.com/news/6',
  ),
];
