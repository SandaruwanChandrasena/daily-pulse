import 'package:flutter/material.dart';

/// One news category. [id] is the name NewsAPI uses, [label] is what users see.
/// [color] is used for the icon on the Explore screen.
///
/// Most categories use top headlines. If [searchQuery] is set, we use
/// search instead (NewsAPI has no Sri Lanka top headlines).
class NewsCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String? searchQuery;
  final String? note;

  const NewsCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.searchQuery,
    this.note,
  });

  bool get usesSearch => searchQuery != null;

  static const List<NewsCategory> all = [
    NewsCategory(
      id: 'general',
      label: 'General',
      icon: Icons.public,
      color: Color(0xFF3949AB),
    ),
    NewsCategory(
      id: 'srilanka',
      label: 'Sri Lanka',
      icon: Icons.account_balance,
      color: Color(0xFF8D1B3D),
      searchQuery: '"Sri Lanka"',
      note: 'Sri Lanka news is updated daily. Stories are at least 1 day old.',
    ),
    NewsCategory(
      id: 'business',
      label: 'Business',
      icon: Icons.bar_chart_rounded,
      color: Color(0xFF00897B),
    ),
    NewsCategory(
      id: 'sports',
      label: 'Sports',
      icon: Icons.emoji_events,
      color: Color(0xFFF9A825),
    ),
    NewsCategory(
      id: 'technology',
      label: 'Technology',
      icon: Icons.memory,
      color: Color(0xFF1E88E5),
    ),
    NewsCategory(
      id: 'health',
      label: 'Health',
      icon: Icons.favorite,
      color: Color(0xFFE53935),
    ),
    NewsCategory(
      id: 'entertainment',
      label: 'Entertainment',
      icon: Icons.movie_creation,
      color: Color(0xFF8E24AA),
    ),
    NewsCategory(
      id: 'science',
      label: 'Science',
      icon: Icons.science,
      color: Color(0xFF039BE5),
    ),
  ];

  static NewsCategory byId(String id) {
    return all.firstWhere(
      (category) => category.id == id,
      orElse: () => all.first,
    );
  }
}