import 'package:daily_pulse/utils/date_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatDate', () {
    test('shows day, short month and year', () {
      expect(formatDate(DateTime(2026, 10, 18)), '18 Oct 2026');
      expect(formatDate(DateTime(2026, 1, 5)), '5 Jan 2026');
    });
  });

  group('timeAgo', () {
    DateTime ago(Duration duration) => DateTime.now().subtract(duration);

    test('less than a minute is "just now"', () {
      expect(timeAgo(ago(const Duration(seconds: 20))), 'just now');
    });

    test('minutes', () {
      expect(timeAgo(ago(const Duration(minutes: 5))), '5 min ago');
    });

    test('one hour and many hours', () {
      expect(timeAgo(ago(const Duration(hours: 1))), '1 hour ago');
      expect(timeAgo(ago(const Duration(hours: 3))), '3 hours ago');
    });

    test('one day and many days', () {
      expect(timeAgo(ago(const Duration(days: 1))), '1 day ago');
      expect(timeAgo(ago(const Duration(days: 3))), '3 days ago');
    });

    test('7 days or more shows the date', () {
      final date = ago(const Duration(days: 10));
      expect(timeAgo(date), formatDate(date));
    });
  });
}