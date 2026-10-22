import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/article.dart';
import '../../providers/bookmark_provider.dart';

/// The 🔖 button. Red and filled when the article is saved.
/// Tap to save or remove. Shows a short message (with Undo after removing).
class BookmarkButton extends StatelessWidget {
  final Article article;
  final Color? color;

  const BookmarkButton({super.key, required this.article, this.color});

  void _toggle(BuildContext context) {
    final bookmarks = context.read<BookmarkProvider>();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (bookmarks.isBookmarked(article)) {
      final index = bookmarks.remove(article);
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Removed from saved'),
          behavior: SnackBarBehavior.floating,
          persist: false,
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => bookmarks.add(article, index: index),
          ),
        ),
      );
    } else {
      bookmarks.add(article);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Saved to bookmarks'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = context.select<BookmarkProvider, bool>(
      (bookmarks) => bookmarks.isBookmarked(article),
    );
    final colors = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
      color: isSaved ? colors.primary : (color ?? colors.onSurfaceVariant),
      tooltip: isSaved ? 'Remove from saved' : 'Save',
      visualDensity: VisualDensity.compact,
      onPressed: () => _toggle(context),
    );
  }
}