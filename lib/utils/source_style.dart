import 'package:flutter/material.dart';

const List<Color> _sourceColors = [
  Color(0xFF1E88E5),
  Color(0xFF00897B),
  Color(0xFF5E35B1),
  Color(0xFFD81B60),
  Color(0xFFF4511E),
  Color(0xFF43A047),
  Color(0xFF3949AB),
  Color(0xFF6D4C41),
];

const Set<String> _smallWords = {'the', 'of', 'and', 'a', 'an', 'on', 'in'};

/// A fixed color for each news source. The same source always gets
/// the same color, because we add up its letters (no randomness).
Color sourceColor(String sourceName) {
  var total = 0;
  for (final code in sourceName.codeUnits) {
    total += code;
  }
  return _sourceColors[total % _sourceColors.length];
}

/// A short name for a source, shown when a story has no image.
/// "The Wall Street Journal" → "WSJ", "BBC News" → "BBC", "Axios" → "Axios".
String sourceShortName(String sourceName) {
  final words = sourceName
      .split(RegExp(r'[^A-Za-z0-9]+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty || sourceName.toLowerCase() == 'unknown source') {
    return '';
  }
  if (words.length == 1) return words.first;

  for (final word in words) {
    if (word.length >= 2 && word.length <= 4 && word == word.toUpperCase()) {
      return word;
    }
  }

  final initials = words
      .where((word) => !_smallWords.contains(word.toLowerCase()))
      .map((word) => word[0].toUpperCase())
      .take(3)
      .join();
  return initials.isEmpty ? words.first : initials;
}