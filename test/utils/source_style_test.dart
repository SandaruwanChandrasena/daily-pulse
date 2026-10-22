import 'package:daily_pulse/utils/source_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sourceShortName', () {
    test('makes initials and skips small words like "The"', () {
      expect(sourceShortName('The Wall Street Journal'), 'WSJ');
    });

    test('keeps a short CAPITAL word', () {
      expect(sourceShortName('BBC News'), 'BBC');
    });

    test('keeps a single word as it is', () {
      expect(sourceShortName('Axios'), 'Axios');
    });

    test('uses initials for normal two-word names', () {
      expect(sourceShortName('Page Six'), 'PS');
    });

    test('returns empty text for unknown or empty sources', () {
      expect(sourceShortName('Unknown source'), '');
      expect(sourceShortName(''), '');
    });
  });

  group('sourceColor', () {
    test('the same source always gets the same color', () {
      expect(sourceColor('Reuters'), sourceColor('Reuters'));
    });

    test('different sources can get different colors', () {
      expect(sourceColor('CNN'), isNot(sourceColor('Bloomberg')));
    });
  });
}