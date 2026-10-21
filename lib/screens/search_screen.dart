import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/search_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/news_list_tile.dart';
import '../widgets/recent_searches.dart';
import 'news_details_screen.dart';

/// Search tab: search box in the AppBar, recent searches or results below.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final lastQuery = context.read<SearchProvider>().query;
    _textController = TextEditingController(text: lastQuery);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _textController.clear();
    context.read<SearchProvider>().clear();
    setState(() {});
  }

  void _searchAgain(String word) {
    _textController.text = word;
    FocusScope.of(context).unfocus();
    setState(() {});
    context.read<SearchProvider>().search(word);
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
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _textController,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search news...',
            border: InputBorder.none,
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (text) => context.read<SearchProvider>().search(text),
        ),
        actions: [
          if (_textController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear',
              onPressed: _clearSearch,
            ),
        ],
      ),
      body: Consumer<SearchProvider>(
        builder: (context, search, child) => _buildResults(search),
      ),
    );
  }

  /// Picks what to show: recent searches, start message, spinner, error or list.
  Widget _buildResults(SearchProvider search) {
    if (!search.hasSearched && search.history.isNotEmpty) {
      return RecentSearches(
        words: search.history,
        onTap: _searchAgain,
        onRemove: search.removeFromHistory,
        onClearAll: search.clearHistory,
      );
    }

    if (!search.hasSearched) {
      return const _MessageView(
        icon: Icons.search,
        message: 'Type a word and press search.\nFor example: "AI" or "football".',
      );
    }

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

    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: search.articles.length,
      itemBuilder: (context, index) {
        final article = search.articles[index];
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