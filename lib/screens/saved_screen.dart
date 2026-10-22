import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../utils/confirm_dialog.dart';
import '../widgets/common/empty_view.dart';
import '../widgets/news/news_list_tile.dart';
import '../widgets/common/page_title.dart';
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

    final confirmed = await showConfirmDialog(
      context,
      title: 'Clear all saved news?',
      message: "This removes every saved story. You can't undo it.",
      confirmLabel: 'Clear all',
    );
    if (confirmed) bookmarks.clearAll();
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
          ? const EmptyView(
              icon: Icons.bookmark_border,
              title: 'No saved news yet',
              message: 'Tap the bookmark icon on any story to save it here.',
            )
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