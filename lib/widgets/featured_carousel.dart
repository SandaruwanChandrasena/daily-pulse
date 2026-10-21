import 'package:flutter/material.dart';

import '../models/article.dart';
import '../utils/date_helper.dart';
import 'category_badge.dart';
import 'news_image.dart';

/// Big top stories you can swipe left and right, with dots under them.
class FeaturedCarousel extends StatefulWidget {
  final List<Article> articles;
  final String badgeText;
  final ValueChanged<Article> onTap;

  const FeaturedCarousel({
    super.key,
    required this.articles,
    required this.badgeText,
    required this.onTap,
  });

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.articles.length,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) {
              final article = widget.articles[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _FeaturedCard(
                  article: article,
                  badgeText: widget.badgeText,
                  onTap: () => widget.onTap(article),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.articles.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentPage ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? colors.primary
                      : colors.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// One big story: image, dark shade at the bottom, badge, title and time.
class _FeaturedCard extends StatelessWidget {
  final Article article;
  final String badgeText;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.article,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NewsImage(imageUrl: article.imageUrl, aspectRatio: null),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryBadge(text: badgeText),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${article.sourceName} • ${timeAgo(article.publishedAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}