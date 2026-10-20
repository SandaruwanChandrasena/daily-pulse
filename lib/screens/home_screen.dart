import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/news_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/news_card.dart';

/// First screen. Shows the latest news from the API.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      // Consumer rebuilds this part every time NewsProvider calls notifyListeners().
      body: Consumer<NewsProvider>(
        builder: (context, news, child) {
          // 1. First load: show a spinner.
          if (news.isLoading && news.articles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error and nothing to show: show the error with a retry button.
          if (news.errorMessage != null && news.articles.isEmpty) {
            return ErrorView(
              message: news.errorMessage!,
              onRetry: news.loadTopHeadlines,
            );
          }

          // 3. No error, but the list is empty.
          if (news.articles.isEmpty) {
            return const Center(child: Text('No news found.'));
          }

          // 4. Show the news. Pull down to refresh.
          // If a refresh failed, we keep the old news and show a red strip on top.
          return Column(
            children: [
              if (news.errorMessage != null)
                _RefreshErrorBar(message: news.errorMessage!),
              // Expanded gives the ListView a fixed height inside the Column.
              // Without it, the app crashes with "unbounded height".
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
                        onTap: () {
                          // The details page comes in Stage 3.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tapped: ${article.title}')),
                          );
                        },
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

/// Small red bar shown above the list when a refresh fails.
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
