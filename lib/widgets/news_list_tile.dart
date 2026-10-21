import 'package:flutter/material.dart';

import '../models/article.dart';
import '../utils/date_helper.dart';
import 'bookmark_button.dart';
import 'news_image.dart';

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
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 110,
                height: 80,
                child: NewsImage(imageUrl: article.imageUrl, aspectRatio: null),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${article.sourceName} • ${timeAgo(article.publishedAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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