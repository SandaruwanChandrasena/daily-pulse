import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/news_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/news_card.dart';
import 'news_details_screen.dart';

/// First screen. Shows the latest news from the API.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Pulse',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<NewsProvider>(
        builder: (context, news, child) {
          if (news.isLoading && news.articles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (news.errorMessage != null && news.articles.isEmpty) {
            return ErrorView(
              message: news.errorMessage!,
              onRetry: news.loadTopHeadlines,
            );
          }

          if (news.articles.isEmpty) {
            return const Center(child: Text('No news found.'));
          }

          return Column(
            children: [
              if (news.errorMessage != null)
                _RefreshErrorBar(message: news.errorMessage!),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: news.loadTopHeadlines,
                  child: ListView.builder(
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
        },
      ),
    );
  }
}

/// Red bar shown above the list when a refresh fails.
class _RefreshErrorBar extends StatelessWidget {
  final String message;

  const _RefreshErrorBar({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: colors.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
    );
  }
}