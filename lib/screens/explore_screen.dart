import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/topics.dart';
import '../models/article.dart';
import '../models/news_category.dart';
import '../providers/navigation_provider.dart';
import '../providers/news_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/news_list_tile.dart';
import '../widgets/page_title.dart';
import '../widgets/section_title.dart';
import '../widgets/topic_chips.dart';
import 'news_details_screen.dart';

/// Explore tab: filter chips, all categories, popular topics and top stories.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const int _topStoriesCount = 5;

  String _filterId = NewsCategory.all.first.id;
  bool _showAllTopics = false;

  /// The chips at the top only change the Top Stories list.
  void _selectFilter(String categoryId) {
    setState(() => _filterId = categoryId);
    context.read<NewsProvider>().loadNews(categoryId: categoryId);
  }

  /// Opens the Home tab with this category selected.
  void _openCategory(String categoryId) {
    context.read<NewsProvider>().selectCategory(categoryId);
    context.read<NavigationProvider>().goTo(AppTab.home);
  }

  /// Opens the Search tab and searches this topic.
  void _searchTopic(String topic) {
    context.read<SearchProvider>().search(topic);
    context.read<NavigationProvider>().goTo(AppTab.search);
  }

  void _openDetails(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailsScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final news = context.watch<NewsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const PageTitle('Explore'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () =>
                context.read<NavigationProvider>().goTo(AppTab.search),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: CategoryChips(
              categories: NewsCategory.all,
              selectedId: _filterId,
              onSelected: _selectFilter,
              firstLabel: 'All',
            ),
          ),
          const SliverToBoxAdapter(child: SectionTitle(text: 'Categories')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisExtent: 84,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: NewsCategory.all.length,
              itemBuilder: (context, index) {
                final category = NewsCategory.all[index];
                return CategoryCard(
                  category: category,
                  onTap: () => _openCategory(category.id),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SectionTitle(
              text: 'Popular Topics',
              actionLabel: _showAllTopics ? 'Show less' : 'See All',
              onAction: () => setState(() => _showAllTopics = !_showAllTopics),
            ),
          ),
          SliverToBoxAdapter(
            child: TopicChips(
              topics: Topics.popular,
              hotTopics: Topics.hot,
              scrollable: !_showAllTopics,
              onTap: _searchTopic,
            ),
          ),
          SliverToBoxAdapter(
            child: SectionTitle(
              text: 'Top Stories',
              actionLabel: 'See All',
              onAction: () => _openCategory(_filterId),
            ),
          ),
          ..._buildTopStories(news),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  /// Top stories for the chosen chip: list, spinner, error or empty text.
  List<Widget> _buildTopStories(NewsProvider news) {
    final stories = news
        .articlesFor(_filterId)
        .take(_topStoriesCount)
        .toList();

    if (stories.isNotEmpty) {
      return [
        SliverList.builder(
          itemCount: stories.length,
          itemBuilder: (context, index) {
            final article = stories[index];
            return NewsListTile(
              article: article,
              onTap: () => _openDetails(article),
            );
          },
        ),
      ];
    }

    final Widget message;
    if (news.isLoadingFor(_filterId)) {
      message = const CircularProgressIndicator();
    } else if (news.errorFor(_filterId) != null) {
      message = Column(
        children: [
          Text(news.errorFor(_filterId)!, textAlign: TextAlign.center),
          TextButton(
            onPressed: () =>
                news.loadNews(categoryId: _filterId, forceRefresh: true),
            child: const Text('Try again'),
          ),
        ],
      );
    } else {
      message = const Text('No news found.');
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: message),
        ),
      ),
    ];
  }
}