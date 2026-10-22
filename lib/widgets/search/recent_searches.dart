import 'package:flutter/material.dart';

import '../common/section_title.dart';

/// Recent search words. Tap to search again. Swipe a row to remove it.
class RecentSearches extends StatelessWidget {
  final List<String> words;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  const RecentSearches({
    super.key,
    required this.words,
    required this.onTap,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          text: 'Recent Searches',
          actionLabel: 'Clear All',
          onAction: onClearAll,
        ),
        for (final word in words)
          Dismissible(
            key: ValueKey('recent-$word'),
            onDismissed: (_) => onRemove(word),
            background: Container(
              color: colors.errorContainer,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.delete_outline, color: colors.onErrorContainer),
                  Icon(Icons.delete_outline, color: colors.onErrorContainer),
                ],
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: Icon(Icons.history, color: colors.onSurfaceVariant),
                  titleTextStyle: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 15),
                  title: Text(word),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colors.onSurfaceVariant,
                  ),
                  onTap: () => onTap(word),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: colors.outlineVariant,
                ),
              ],
            ),
          ),
      ],
    );
  }
}