import 'package:flutter/material.dart';

import '../../models/article.dart';
import 'bookmark_button.dart';
import 'news_image.dart';
import 'source_and_time.dart';

/// One news row: small image, title and "source • time", then a 🔖 button.
class NewsListTile extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const NewsListTile({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 120,
                height: 90,
                child: NewsImage(
                  imageUrl: article.imageUrl,
                  sourceName: article.sourceName,
                  aspectRatio: null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SourceAndTime(
                    article: article,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            BookmarkButton(article: article),
          ],
        ),
      ),
    );
  }
}