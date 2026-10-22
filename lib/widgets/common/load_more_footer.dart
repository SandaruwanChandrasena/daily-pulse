import 'package:flutter/material.dart';

/// The row at the end of a news list: a spinner while loading more,
/// "tap to try again" after an error, or "You're all caught up".
class LoadMoreFooter extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final VoidCallback onRetry;

  const LoadMoreFooter({
    super.key,
    required this.isLoadingMore,
    required this.hasMore,
    required this.error,
    required this.onRetry,
  });

  /// True when the user scrolls the main list near its end (600 px or less).
  /// depth 0 = the main list, not a list inside it (like the banner).
  static bool isNearEnd(ScrollNotification notification) {
    return notification is ScrollUpdateNotification &&
        notification.depth == 0 &&
        notification.metrics.extentAfter < 600;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final smallText = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );

    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (error != null) {
      return InkWell(
        onTap: onRetry,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "Couldn't load more. Tap to try again.",
                  style: smallText?.copyWith(color: colors.primary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 16, color: colors.outline),
            const SizedBox(width: 6),
            Text("You're all caught up", style: smallText),
          ],
        ),
      );
    }

    return const SizedBox(height: 16);
  }
}