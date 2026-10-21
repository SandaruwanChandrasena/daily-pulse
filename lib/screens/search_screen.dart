import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/topics.dart';
import '../models/article.dart';
import '../providers/search_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/news_list_tile.dart';
import '../widgets/page_title.dart';
import '../widgets/recent_searches.dart';
import '../widgets/search_field.dart';
import '../widgets/section_title.dart';
import '../widgets/topic_chips.dart';
import 'news_details_screen.dart';

/// Search tab: big title, rounded search box, then ideas or results below.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchProvider _search;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _search = context.read<SearchProvider>();
    _textController = TextEditingController(text: _search.query);
    _search.addListener(_showQueryInBox);
  }

  @override
  void dispose() {
    _search.removeListener(_showQueryInBox);
    _textController.dispose();
    super.dispose();
  }

  /// Explore can start a search, so we copy the new word into the box.
  void _showQueryInBox() {
    final query = _search.query;
    if (query.isNotEmpty && query != _textController.text.trim()) {
      _textController.text = query;
    }
  }

  void _submit(String text) {
    FocusScope.of(context).unfocus();
    _search.search(text);
  }

  void _searchWord(String word) {
    _textController.text = word;
    _submit(word);
  }

  void _clear() {
    _textController.clear();
    _search.clear();
  }

  void _openDetails(Article article) {
    NewsDetailsScreen.open(context, article, related: _search.articles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const PageTitle('Search'), centerTitle: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SearchField(
              controller: _textController,
              onSubmitted: _submit,
              onClear: _clear,
            ),
          ),
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, search, child) => _buildBody(search),
            ),
          ),
        ],
      ),
    );
  }

  /// Picks what to show: ideas, spinner, error, no results or the results.
  Widget _buildBody(SearchProvider search) {
    if (!search.hasSearched) return _buildIdeas(search);

    if (search.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (search.errorMessage != null) {
      return ErrorView(message: search.errorMessage!, onRetry: search.retry);
    }

    if (search.articles.isEmpty) {
      return _MessageView(
        icon: Icons.search_off,
        message: 'No news found for "${search.query}".\nTry another word.',
      );
    }

    return _buildResults(search);
  }

  /// Before a search: recent searches (if any) and trending topics.
  Widget _buildIdeas(SearchProvider search) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        if (search.history.isNotEmpty)
          RecentSearches(
            words: search.history,
            onTap: _searchWord,
            onRemove: search.removeFromHistory,
            onClearAll: search.clearHistory,
          ),
        const SectionTitle(text: 'Trending Topics'),
        TopicChips(
          topics: Topics.trending,
          hotTopics: Topics.hot,
          onTap: _searchWord,
        ),
      ],
    );
  }

  Widget _buildResults(SearchProvider search) {
    final articles = search.articles;

    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: articles.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return SectionTitle(
            text: 'Search Results (${articles.length})',
            actionLabel: 'Clear',
            onAction: _clear,
          );
        }
        final article = articles[index - 1];
        return NewsListTile(
          article: article,
          onTap: () => _openDetails(article),
        );
      },
    );
  }
}

/// A big grey icon with a short message under it.
class _MessageView extends StatelessWidget {
  final IconData icon;
  final String message;

  const _MessageView({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}