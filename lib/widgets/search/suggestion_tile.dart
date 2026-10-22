import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/suggestion.dart';

/// One suggestion row. The part you typed is bold.
/// The "guessed" rest of the word has a blue background.
/// Tap = search now. ↖ = put the word in the box, keep typing.
class SuggestionTile extends StatelessWidget {
  final Suggestion suggestion;
  final String query;
  final VoidCallback onTap;
  final VoidCallback onFill;

  const SuggestionTile({
    super.key,
    required this.suggestion,
    required this.query,
    required this.onTap,
    required this.onFill,
  });

  IconData get _icon {
    switch (suggestion.type) {
      case SuggestionType.recent:
        return Icons.history;
      case SuggestionType.topic:
        return Icons.trending_up;
      case SuggestionType.word:
        return Icons.search;
    }
  }

  /// Splits the text into: before, the typed part (bold), the guess (blue).
  TextSpan _highlightedText(Color textColor) {
    final text = suggestion.text;
    final typed = query.trim();
    final start = text.toLowerCase().indexOf(typed.toLowerCase());
    if (typed.isEmpty || start == -1) return TextSpan(text: text);

    final end = start + typed.length;
    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, start)),
        TextSpan(
          text: text.substring(start, end),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        TextSpan(
          text: text.substring(end),
          style: TextStyle(
            color: textColor,
            backgroundColor: AppTheme.highlightBlue.withValues(alpha: 0.22),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Icon(_icon, color: colors.onSurfaceVariant),
      titleTextStyle: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(fontSize: 15),
      title: Text.rich(_highlightedText(colors.onSurface)),
      trailing: IconButton(
        icon: const Icon(Icons.north_west, size: 20),
        tooltip: 'Use this word',
        color: colors.onSurfaceVariant,
        onPressed: onFill,
      ),
      onTap: onTap,
    );
  }
}