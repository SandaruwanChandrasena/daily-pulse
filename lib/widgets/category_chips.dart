import 'package:flutter/material.dart';

import '../models/news_category.dart';

/// A row of category chips that scrolls left and right.
class CategoryChips extends StatelessWidget {
  final List<NewsCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedId;

          return ChoiceChip(
            avatar: Icon(category.icon, size: 18),
            label: Text(category.label),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(category.id),
          );
        },
      ),
    );
  }
}
