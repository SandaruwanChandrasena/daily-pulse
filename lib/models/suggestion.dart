/// Where a search suggestion comes from. It decides the icon we show.
enum SuggestionType { recent, topic, word }

/// One live search suggestion, like "Cricket" (a topic).
class Suggestion {
  final String text;
  final SuggestionType type;

  const Suggestion(this.text, this.type);
}