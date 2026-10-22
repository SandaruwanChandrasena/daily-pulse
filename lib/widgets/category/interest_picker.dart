import 'package:flutter/material.dart';

import '../../models/news_category.dart';

/// A 2-column grid of categories to pick. Picked ones are light red
/// with a red check. Used on the welcome screens and in Settings.
class InterestPicker extends StatelessWidget {
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  const InterestPicker({
    super.key,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final categories = NewsCategory.choosable;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 64,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _InterestTile(
          category: category,
          isSelected: selectedIds.contains(category.id),
          onTap: () => onToggle(category.id),
        );
      },
    );
  }
}

class _InterestTile extends StatelessWidget {
  final NewsCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: isSelected
          ? colors.primaryContainer.withValues(alpha: 0.5)
          : colors.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? colors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(category.icon, color: category.color, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  key: ValueKey(isSelected),
                  color: isSelected ? colors.primary : colors.outline,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}