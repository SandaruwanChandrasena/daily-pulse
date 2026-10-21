import 'package:flutter/material.dart';

/// One news category. [id] is the name NewsAPI uses, [label] is what users see.
///
/// Most categories use top headlines. If [searchQuery] is set, we use
/// search instead (NewsAPI has no Sri Lanka top headlines).
class NewsCategory {
  final String id;
  final String label;
  final IconData icon;
  final String? searchQuery;
  final String? note;

  const NewsCategory({
    required this.id,
    required this.label,
    required this.icon,
    this.searchQuery,
    this.note,
  });

  bool get usesSearch => searchQuery != null;

  static const List<NewsCategory> all = [
    NewsCategory(id: 'general', label: 'General', icon: Icons.public),
    NewsCategory(
      id: 'srilanka',
      label: 'Sri Lanka',
      icon: Icons.flag_outlined,
      searchQuery: '"Sri Lanka"',
      note: 'Sri Lanka news is updated daily. Stories are at least 1 day old.',
    ),
    NewsCategory(
      id: 'business',
      label: 'Business',
      icon: Icons.business_center,
    ),
    NewsCategory(id: 'sports', label: 'Sports', icon: Icons.sports_soccer),
    NewsCategory(id: 'technology', label: 'Technology', icon: Icons.memory),
    NewsCategory(id: 'health', label: 'Health', icon: Icons.favorite),
    NewsCategory(
      id: 'entertainment',
      label: 'Entertainment',
      icon: Icons.movie,
    ),
    NewsCategory(id: 'science', label: 'Science', icon: Icons.science),
  ];

  static NewsCategory byId(String id) {
    return all.firstWhere(
      (category) => category.id == id,
      orElse: () => all.first,
    );
  }
}