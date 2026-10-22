import 'package:daily_pulse/models/news_category.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _ids(List<NewsCategory> categories) {
  return categories.map((category) => category.id).toList();
}

void main() {
  group('NewsCategory.choosable', () {
    test('has every category except General', () {
      final ids = _ids(NewsCategory.choosable);

      expect(ids, isNot(contains('general')));
      expect(ids.length, NewsCategory.all.length - 1);
    });
  });

  group('NewsCategory.ordered', () {
    test('no interests keeps the normal order', () {
      expect(_ids(NewsCategory.ordered([])), _ids(NewsCategory.all));
    });

    test('General first, then picks, then the rest', () {
      final ids = _ids(NewsCategory.ordered(['sports', 'srilanka']));

      expect(ids.take(3), ['general', 'srilanka', 'sports']);
      expect(ids.length, NewsCategory.all.length);
    });

    test('ignores unknown ids', () {
      final ids = _ids(NewsCategory.ordered(['cooking', 'science']));

      expect(ids.take(2), ['general', 'science']);
      expect(ids.length, NewsCategory.all.length);
    });
  });
}