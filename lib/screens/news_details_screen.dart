import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/article.dart';
import '../utils/date_helper.dart';
import '../widgets/bookmark_button.dart';
import '../widgets/category_badge.dart';
import '../widgets/news_image.dart';
import '../widgets/news_list_tile.dart';
import '../widgets/section_title.dart';
import 'article_web_view_screen.dart';

/// One news story: big image header, title, source, text and related news.
/// [categoryLabel] shows the red badge. [related] is the list we came from.
class NewsDetailsScreen extends StatelessWidget {
  final Article article;
  final String? categoryLabel;
  final List<Article> related;

  const NewsDetailsScreen({
    super.key,
    required this.article,
    this.categoryLabel,
    this.related = const [],
  });

  static const int _relatedCount = 5;

  /// Opens a story. [replace] swaps the current page (used by Related News).
  static void open(
    BuildContext context,
    Article article, {
    String? categoryLabel,
    List<Article> related = const [],
    bool replace = false,
  }) {
    final route = MaterialPageRoute(
      builder: (context) => NewsDetailsScreen(
        article: article,
        categoryLabel: categoryLabel,
        related: related,
      ),
    );

    if (replace) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.push(context, route);
    }
  }

  void _openArticle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleWebViewScreen(
          url: article.url,
          title: article.sourceName,
        ),
      ),
    );
  }

  /// Opens the phone's share menu with the title and the link.
  void _share() {
    SharePlus.instance.share(
      ShareParams(
        subject: article.title,
        text: '${article.title}\n\n${article.url}\n\nShared from Daily Pulse',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final relatedNews = related
        .where((item) => item.url != article.url)
        .take(_relatedCount)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: colors.surface,
            leading: _RoundIcon(
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                color: colors.onSurface,
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
            actions: [
              _RoundIcon(
                child: BookmarkButton(
                  article: article,
                  color: colors.onSurface,
                ),
              ),
              _RoundIcon(
                child: IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Share',
                  color: colors.onSurface,
                  visualDensity: VisualDensity.compact,
                  onPressed: article.url.isEmpty ? null : _share,
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: NewsImage(
                imageUrl: article.imageUrl,
                aspectRatio: null,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(24),
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _ArticleBody(
              article: article,
              categoryLabel: categoryLabel,
              onReadFull: () => _openArticle(context),
            ),
          ),
          if (relatedNews.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: SectionTitle(
                text: 'Related News',
                actionLabel: 'See All',
                onAction: () => Navigator.maybePop(context),
              ),
            ),
            SliverList.builder(
              itemCount: relatedNews.length,
              itemBuilder: (context, index) {
                final item = relatedNews[index];
                return NewsListTile(
                  article: item,
                  onTap: () => open(
                    context,
                    item,
                    categoryLabel: categoryLabel,
                    related: related,
                    replace: true,
                  ),
                );
              },
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

/// Badge, title, source avatar, time, description and the "Read" button.
class _ArticleBody extends StatelessWidget {
  final Article article;
  final String? categoryLabel;
  final VoidCallback onReadFull;

  const _ArticleBody({
    required this.article,
    required this.categoryLabel,
    required this.onReadFull,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final source = article.sourceName;
    final firstLetter = source.isEmpty ? '?' : source[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (categoryLabel != null) ...[
            CategoryBadge(text: categoryLabel!),
            const SizedBox(height: 10),
          ],
          Text(
            article.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.primary,
                child: Text(
                  firstLetter,
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'By $source',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${timeAgo(article.publishedAt)} • '
                      '${formatDate(article.publishedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            article.description.isEmpty
                ? 'No description available. '
                      'Tap the button below to read the full article.'
                : article.description,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: article.url.isEmpty ? null : onReadFull,
              icon: const Icon(Icons.article_outlined),
              label: const Text('Read full article'),
            ),
          ),
        ],
      ),
    );
  }
}

/// A white circle behind a top-bar button, so it shows on any image.
class _RoundIcon extends StatelessWidget {
  final Widget child;

  const _RoundIcon({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}