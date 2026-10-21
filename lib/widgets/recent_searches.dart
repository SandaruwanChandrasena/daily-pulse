import 'package:flutter/material.dart';

/// A list of recent search words. Tap to search again, ✖ to remove one.
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
    final theme = Theme.of(context);

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Recent searches',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(onPressed: onClearAll, child: const Text('Clear all')),
            ],
          ),
        ),
        for (final word in words)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(word),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Remove',
              onPressed: () => onRemove(word),
            ),
            onTap: () => onTap(word),
          ),
      ],
    );
  }
}