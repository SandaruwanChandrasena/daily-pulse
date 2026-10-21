import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../models/news_category.dart';
import '../providers/news_provider.dart';
import '../utils/date_helper.dart';
import '../widgets/category_chips.dart';
import '../widgets/error_view.dart';
import '../widgets/news_card.dart';
import 'news_details_screen.dart';
import 'search_screen.dart';

/// First screen. Category chips on top, news list below.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openDetails(BuildContext context, Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailsScreen(article: article),
      ),
    );
  }

  void _openSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Pulse',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => _openSearch(context),
          ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, news, child) {
          return Column(
            children: [
              CategoryChips(
                categories: NewsCategory.all,
                selectedId: news.selectedCategory,
                onSelected: news.selectCategory,
              ),
              Expanded(child: _buildNewsArea(context, news)),
            ],
          );
        },
      ),
    );
  }

  /// Picks what to show under the chips: spinner, error, empty text or list.
  Widget _buildNewsArea(BuildContext context, NewsProvider news) {
    if (news.isLoading && news.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (news.errorMessage != null && news.articles.isEmpty) {
      return ErrorView(message: news.errorMessage!, onRetry: news.refresh);
    }

    if (news.articles.isEmpty) {
      return const Center(child: Text('No news found.'));
    }

    return Column(
      children: [
        if (news.errorMessage != null)
          _SavedNewsBar(
            isOffline: news.isOffline,
            message: news.errorMessage!,
            savedAt: news.savedAt,
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: news.refresh,
            child: ListView.builder(
              key: PageStorageKey(news.selectedCategory),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: news.articles.length,
              itemBuilder: (context, index) {
                final article = news.articles[index];
                return NewsCard(
                  article: article,
                  onTap: () => _openDetails(context, article),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Bar above the list when we could not get fresh news and show saved news.
class _SavedNewsBar extends StatelessWidget {
  final bool isOffline;
  final String message;
  final DateTime? savedAt;

  const _SavedNewsBar({
    required this.isOffline,
    required this.message,
    required this.savedAt,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final time = savedAt == null ? '' : ' from ${timeAgo(savedAt!)}';
    final text = isOffline
        ? 'You are offline. Showing saved news$time.'
        : '$message\nShowing saved news$time.';
    final background = isOffline
        ? colors.secondaryContainer
        : colors.errorContainer;
    final foreground = isOffline
        ? colors.onSecondaryContainer
        : colors.onErrorContainer;

    return Container(
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.wifi_off_rounded : Icons.error_outline,
            size: 18,
            color: foreground,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: foreground))),
        ],
      ),
    );
  }
}