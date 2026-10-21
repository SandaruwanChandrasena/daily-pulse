import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/news_list_tile.dart';
import '../widgets/page_title.dart';
import 'news_details_screen.dart';

/// Saved tab: the bookmarked news, newest first. Works offline.
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  void _openDetails(
    BuildContext context,
    Article article,
    List<Article> saved,
  ) {
    NewsDetailsScreen.open(context, article, related: saved);
  }

  /// Asks "Are you sure?" before removing all saved news.
  Future<void> _confirmClearAll(BuildContext context) async {
    final bookmarks = context.read<BookmarkProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all saved news?'),
        content: const Text(
          "This removes every saved story. You can't undo it.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );

    if (confirmed == true) bookmarks.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<BookmarkProvider>().saved;

    return Scaffold(
      appBar: AppBar(
        title: const PageTitle('Saved Articles'),
        centerTitle: false,
        actions: [
          if (saved.isNotEmpty)
            PopupMenuButton<String>(
              tooltip: 'More',
              onSelected: (_) => _confirmClearAll(context),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'clear', child: Text('Clear all')),
              ],
            ),
        ],
      ),
      body: saved.isEmpty
          ? const _EmptySaved()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: saved.length,
              itemBuilder: (context, index) {
                final article = saved[index];
                return NewsListTile(
                  article: article,
                  onTap: () => _openDetails(context, article, saved),
                );
              },
            ),
    );
  }
}

/// Shown when nothing is saved yet.
class _EmptySaved extends StatelessWidget {
  const _EmptySaved();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No saved news yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on any story to save it here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}