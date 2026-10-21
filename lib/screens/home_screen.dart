import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../models/news_category.dart';
import '../providers/news_provider.dart';
import '../utils/date_helper.dart';
import '../widgets/app_logo.dart';
import '../widgets/category_tabs.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/featured_carousel.dart';
import '../widgets/info_bar.dart';
import '../widgets/news_list_tile.dart';
import '../widgets/section_title.dart';
import 'news_details_screen.dart';

/// Home tab: category tabs, a big top-stories slider, then the latest news.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const int _featuredCount = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppLogo(), centerTitle: false),
      body: Consumer<NewsProvider>(
        builder: (context, news, child) {
          return Column(
            children: [
              CategoryTabs(
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

  /// Picks what to show under the tabs: spinner, error, empty text or news.
  Widget _buildNewsArea(BuildContext context, NewsProvider news) {
    if (news.isLoading && news.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (news.errorMessage != null && news.articles.isEmpty) {
      return ErrorView(message: news.errorMessage!, onRetry: news.refresh);
    }

    if (news.articles.isEmpty) {
      return const EmptyView(
        icon: Icons.newspaper,
        title: 'No news found',
        message: 'Try another category, or come back later.',
      );
    }

    final category = NewsCategory.byId(news.selectedCategory);
    void openDetails(Article article) => NewsDetailsScreen.open(
      context,
      article,
      categoryLabel: category.label,
      related: news.articles,
    );

    final featured = news.articles
        .where((article) => article.imageUrl.isNotEmpty)
        .take(_featuredCount)
        .toList();
    final latest = news.articles
        .where((article) => !featured.contains(article))
        .toList();

    return RefreshIndicator(
      onRefresh: news.refresh,
      child: CustomScrollView(
        key: PageStorageKey(category.id),
        slivers: [
          if (news.errorMessage != null)
            SliverToBoxAdapter(child: _savedNewsBar(context, news)),
          if (category.note != null)
            SliverToBoxAdapter(child: _noteBar(context, category.note!)),
          if (featured.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FeaturedCarousel(
                  key: ValueKey(category.id),
                  articles: featured,
                  badgeText: category.label,
                  onTap: openDetails,
                ),
              ),
            ),
          if (latest.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: SectionTitle(text: 'Latest News'),
            ),
            SliverList.builder(
              itemCount: latest.length,
              itemBuilder: (context, index) {
                final article = latest[index];
                return NewsListTile(
                  article: article,
                  onTap: () => openDetails(article),
                );
              },
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  /// Shown when we could not get fresh news, so we show saved news.
  Widget _savedNewsBar(BuildContext context, NewsProvider news) {
    final colors = Theme.of(context).colorScheme;
    final savedAt = news.savedAt;
    final time = savedAt == null ? '' : ' from ${timeAgo(savedAt)}';

    if (news.isOffline) {
      return InfoBar(
        icon: Icons.wifi_off_rounded,
        text: 'You are offline. Showing saved news$time.',
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
      );
    }

    return InfoBar(
      icon: Icons.error_outline,
      text: '${news.errorMessage}\nShowing saved news$time.',
      background: colors.errorContainer,
      foreground: colors.onErrorContainer,
    );
  }

  Widget _noteBar(BuildContext context, String note) {
    final colors = Theme.of(context).colorScheme;

    return InfoBar(
      icon: Icons.info_outline,
      text: note,
      background: colors.surfaceContainerHighest,
      foreground: colors.onSurfaceVariant,
    );
  }
}