import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';
import '../utils/date_helper.dart';
import '../widgets/news_image.dart';

/// Shows one news item and a button to read the full article.
class NewsDetailsScreen extends StatelessWidget {
  final Article article;

  const NewsDetailsScreen({super.key, required this.article});

  /// Opens the full article in the phone's browser.
  Future<void> _openArticle(BuildContext context) async {
    final uri = Uri.tryParse(article.url);
    var opened = false;

    if (uri != null) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the article.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(article.sourceName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NewsImage(imageUrl: article.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.public, size: 16, color: colors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          article.sourceName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatDate(article.publishedAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.description.isEmpty
                        ? 'No description available. Tap the button below to read the full article.'
                        : article.description,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: article.url.isEmpty
                          ? null
                          : () => _openArticle(context),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Read full article'),
                    ),
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