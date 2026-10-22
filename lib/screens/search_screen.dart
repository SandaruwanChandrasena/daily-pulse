import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/topics.dart';
import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../providers/news_provider.dart';
import '../providers/search_provider.dart';
import '../utils/search_suggestions.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/load_more_footer.dart';
import '../widgets/news_list_tile.dart';
import '../widgets/page_title.dart';
import '../widgets/recent_searches.dart';
import '../widgets/search_field.dart';
import '../widgets/section_title.dart';
import '../widgets/suggestion_tile.dart';
import '../widgets/topic_chips.dart';
import 'news_details_screen.dart';

/// Search tab: big title, rounded search box, then ideas or results below.
/// While typing, it shows live suggestions and matching loaded news.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static final List<String> _allTopics = {
    ...Topics.trending,
    ...Topics.popular,
  }.toList();

  late final SearchProvider _search;
  late final TextEditingController _textController;
  bool _isTyping = false;

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
      if (mounted && _isTyping) setState(() => _isTyping = false);
    }
  }

  /// Live mode is on while the box has text that is not searched yet.
  void _onTyping(String text) {
    setState(() => _isTyping = text.trim().isNotEmpty);
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isTyping = false);
    _search.search(text);
  }

  /// The ↖ button: puts the word in the box so the user can keep typing.
  void _fillBox(String text) {
    _textController.value = TextEditingValue(
      text: '$text ',
      selection: TextSelection.collapsed(offset: text.length + 1),
    );
    setState(() => _isTyping = true);
  }

  void _searchWord(String word) {
    _textController.text = word;
    _submit(word);
  }

  void _clear() {
    _textController.clear();
    setState(() => _isTyping = false);
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
              onChanged: _onTyping,
              onClear: _clear,
            ),
          ),
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, search, child) =>
                  _isTyping ? _buildLiveView(search) : _buildBody(search),
            ),
          ),
        ],
      ),
    );
  }

  /// All news on the phone: every category, last results and saved news.
  /// listen: false = read once (this runs on every key press anyway).
  List<Article> _loadedNews(SearchProvider search) {
    final seenUrls = <String>{};
    return [
      for (final article in [
        ...Provider.of<NewsProvider>(context, listen: false).allArticles,
        ...search.articles,
        ...Provider.of<BookmarkProvider>(context, listen: false).saved,
      ])
        if (seenUrls.add(article.url)) article,
    ];
  }

  /// While typing: "search online" row, suggestions, then matching news.
  Widget _buildLiveView(SearchProvider search) {
    final typed = _textController.text.trim();
    final loadedNews = _loadedNews(search);
    final suggestions = buildSuggestions(
      query: typed,
      history: search.history,
      topics: _allTopics,
      articles: loadedNews,
    );
    final matches = findInTitles(typed, loadedNews);
    final colors = Theme.of(context).colorScheme;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        ListTile(
          leading: Icon(Icons.travel_explore, color: colors.primary),
          title: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Search online for '),
                TextSpan(
                  text: '"$typed"',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          onTap: () => _submit(typed),
        ),
        for (final suggestion in suggestions)
          SuggestionTile(
            suggestion: suggestion,
            query: typed,
            onTap: () => _searchWord(suggestion.text),
            onFill: () => _fillBox(suggestion.text),
          ),
        if (matches.isNotEmpty) ...[
          SectionTitle(text: 'In loaded news (${matches.length})'),
          for (final article in matches)
            NewsListTile(
              article: article,
              onTap: () =>
                  NewsDetailsScreen.open(context, article, related: matches),
            ),
        ],
      ],
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
      return EmptyView(
        icon: Icons.search_off,
        title: 'No results',
        message: 'No news found for "${search.query}". Try another word.',
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

  /// Title row, the results, then the load-more footer at the end.
  Widget _buildResults(SearchProvider search) {
    final articles = search.articles;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (LoadMoreFooter.isNearEnd(notification)) search.loadMore();
        return false;
      },
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: articles.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return SectionTitle(
              text: 'Search Results (${articles.length})',
              actionLabel: 'Clear',
              onAction: _clear,
            );
          }
          if (index == articles.length + 1) {
            return LoadMoreFooter(
              isLoadingMore: search.isLoadingMore,
              hasMore: search.hasMore,
              error: search.loadMoreError,
              onRetry: search.loadMore,
            );
          }
          final article = articles[index - 1];
          return NewsListTile(
            article: article,
            onTap: () => _openDetails(article),
          );
        },
      ),
    );
  }
}