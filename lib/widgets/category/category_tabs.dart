import 'package:flutter/material.dart';

import '../../models/news_category.dart';

/// A row of category names that scrolls left and right.
/// The selected one is red with a red line under it.
class CategoryTabs extends StatefulWidget {
  final List<NewsCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  final Map<String, GlobalKey> _tabKeys = {};

  GlobalKey _keyFor(String id) => _tabKeys.putIfAbsent(id, () => GlobalKey());

  @override
  void didUpdateWidget(CategoryTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  /// Slides the row so the selected tab is in view (in the middle if it can).
  void _scrollToSelected() {
    final tabContext = _tabKeys[widget.selectedId]?.currentContext;
    if (tabContext == null) return;
    Scrollable.ensureVisible(
      tabContext,
      alignment: 0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final category in widget.categories)
              _buildTab(category, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(NewsCategory category, ColorScheme colors) {
    final isSelected = category.id == widget.selectedId;

    return InkWell(
      key: _keyFor(category.id),
      onTap: () => widget.onSelected(category.id),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              category.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 28 : 0,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}