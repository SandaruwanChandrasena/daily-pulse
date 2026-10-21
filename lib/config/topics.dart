/// Fixed topic lists. NewsAPI has no "trending" feature, so we pick them.
/// [hot] topics get a red chip, like in the design.
class Topics {
  static const List<String> popular = [
    'Elections',
    'Economy',
    'AI',
    'Sri Lanka',
    'Cricket',
    'Climate',
    'Space',
    'Crypto',
  ];

  static const List<String> trending = [
    'Sri Lanka',
    'Elections',
    'AI',
    'Technology',
    'Cricket',
    'Economy',
    'Health',
    'Climate',
  ];

  static const Set<String> hot = {'Sri Lanka', 'Elections', 'Cricket'};
}