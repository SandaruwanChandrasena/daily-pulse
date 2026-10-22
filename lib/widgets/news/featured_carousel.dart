import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/article.dart';
import 'category_badge.dart';
import 'news_image.dart';
import 'source_and_time.dart';

/// Big top stories as an endless slide show, with dots under them.
/// Moves every 5 seconds. Stops while a finger touches it.
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
  static const Duration _slideEvery = Duration(seconds: 5);
  static const Duration _slideSpeed = Duration(milliseconds: 600);

  /// We start far from page 0, so the user can also swipe back "forever".
  static const int _loopStart = 1000;

  late final PageController _controller;
  Timer? _timer;
  late int _currentPage;

  bool get _canLoop => widget.articles.length > 1;

  @override
  void initState() {
    super.initState();
    _currentPage = _canLoop ? widget.articles.length * _loopStart : 0;
    _controller = PageController(
      viewportFraction: 0.9,
      initialPage: _currentPage,
    );
    _startAutoSlide();
  }

  @override
  void didUpdateWidget(FeaturedCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.articles.length != widget.articles.length) {
      _startAutoSlide();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Starts (or restarts) the 5-second timer.
  void _startAutoSlide() {
    _timer?.cancel();
    if (!_canLoop) return;
    _timer = Timer.periodic(_slideEvery, (_) => _nextPage());
  }

  void _stopAutoSlide() => _timer?.cancel();

  void _nextPage() {
    if (!_controller.hasClients) return;
    _controller.nextPage(duration: _slideSpeed, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final count = widget.articles.length;
    if (count == 0) return const SizedBox.shrink();
    final activeDot = _currentPage % count;

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Listener(
            onPointerDown: (_) => _stopAutoSlide(),
            onPointerUp: (_) => _startAutoSlide(),
            onPointerCancel: (_) => _startAutoSlide(),
            child: PageView.builder(
              controller: _controller,
              itemCount: _canLoop ? null : count,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                final article = widget.articles[index % count];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _FeaturedCard(
                    article: article,
                    badgeText: widget.badgeText,
                    onTap: () => widget.onTap(article),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == activeDot ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == activeDot
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
            NewsImage(
              imageUrl: article.imageUrl,
              sourceName: article.sourceName,
              aspectRatio: null,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryBadge(text: badgeText),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SourceAndTime(
                    article: article,
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