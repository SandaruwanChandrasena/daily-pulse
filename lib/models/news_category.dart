import 'package:flutter/material.dart';

/// One news category. [id] is the name NewsAPI uses, [label] is what users see.
class NewsCategory {
  final String id;
  final String label;
  final IconData icon;

  const NewsCategory({
    required this.id,
    required this.label,
    required this.icon,
  });

  static const List<NewsCategory> all = [
    NewsCategory(id: 'general', label: 'General', icon: Icons.public),
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
  ];
}
