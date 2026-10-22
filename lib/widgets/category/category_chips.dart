import 'package:flutter/material.dart';

import '../../models/news_category.dart';

/// A sideways row of round category chips. The selected chip is red.
/// [firstLabel] can rename the first chip (for example "All").
class CategoryChips extends StatelessWidget {
  final List<NewsCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final String? firstLabel;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    this.firstLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(category, colors),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(NewsCategory category, ColorScheme colors) {
    final isSelected = category.id == selectedId;
    final isFirst = category == categories.first;
    final label = isFirst && firstLabel != null ? firstLabel! : category.label;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(category.id),
      showCheckmark: false,
      selectedColor: colors.primary,
      backgroundColor: colors.surfaceContainer,
      labelStyle: TextStyle(
        color: isSelected ? colors.onPrimary : colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
      shape: const StadiumBorder(),
    );
  }
}