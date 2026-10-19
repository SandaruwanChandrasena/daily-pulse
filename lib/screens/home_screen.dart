import 'package:flutter/material.dart';

import '../services/dummy_data.dart';
import '../widgets/news_card.dart';

/// First screen. Shows a list of news.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articles = dummyArticles;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Pulse',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
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
    );
  }
}
