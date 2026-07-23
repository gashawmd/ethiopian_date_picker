import 'package:flutter_ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:flutter_ethiopian_date_picker/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EthiopianDateUtils.daysInMonth (Task 1.3 DoD)', () {
    test('months 1-12 always have 30 days', () {
      for (var month = 1; month <= 12; month++) {
        expect(EthiopianDateUtils.daysInMonth(2016, month), 30);
        expect(EthiopianDateUtils.daysInMonth(2017, month), 30);
      }
    });

    test('Pagume (month 13) has 6 days in a leap year', () {
      expect(EthiopianDateUtils.daysInMonth(2016, 13), 6);
    });

    test('Pagume (month 13) has 5 days in a non-leap year', () {
      expect(EthiopianDateUtils.daysInMonth(2015, 13), 5);
      expect(EthiopianDateUtils.daysInMonth(2017, 13), 5);
      expect(EthiopianDateUtils.daysInMonth(2018, 13), 5);
    });
  });

  group('EthiopianDateUtils.firstWeekdayOfMonth (Task 1.3 DoD)', () {
    test('returns a value in the valid ISO range 1-7', () {
      for (var month = 1; month <= 13; month++) {
        final weekday = EthiopianDateUtils.firstWeekdayOfMonth(2016, month);
        expect(weekday, inInclusiveRange(1, 7));
      }
    });

    test('is deterministic for the same year/month', () {
      final a = EthiopianDateUtils.firstWeekdayOfMonth(2016, 1);
      final b = EthiopianDateUtils.firstWeekdayOfMonth(2016, 1);
      expect(a, b);
    });
  });

  group('EthiopianDateUtils.daysBetween (Task 1.3 DoD)', () {
    test('same month, different days', () {
      final from = EthiopianDate(2016, 1, 1);
      final to = EthiopianDate(2016, 1, 15);
      expect(EthiopianDateUtils.daysBetween(from, to), 14);
    });

    test('negative when "to" is earlier than "from"', () {
      final from = EthiopianDate(2016, 1, 15);
      final to = EthiopianDate(2016, 1, 1);
      expect(EthiopianDateUtils.daysBetween(from, to), -14);
    });

    test('crosses a year boundary correctly', () {
      final from = EthiopianDate(2015, 13, 1);
      final to = EthiopianDate(2016, 1, 1);
      expect(EthiopianDateUtils.daysBetween(from, to), 5);
    });

    test('is symmetric with EthiopianDate comparison', () {
      final a = EthiopianDate(2016, 5, 10);
      final b = EthiopianDate(2016, 8, 20);
      final forward = EthiopianDateUtils.daysBetween(a, b);
      final backward = EthiopianDateUtils.daysBetween(b, a);
      expect(forward, -backward);
      expect(forward, greaterThan(0));
    });
  });

  group('EthiopianDateUtils.clamp (Task 1.3 DoD)', () {
    final min = EthiopianDate(2016, 1, 1);
    final max = EthiopianDate(2016, 12, 30);

    test('returns date unchanged when within range', () {
      final date = EthiopianDate(2016, 6, 15);
      expect(EthiopianDateUtils.clamp(date, min: min, max: max), date);
    });

    test('clamps down to min when date is before it', () {
      final date = EthiopianDate(2015, 13, 1);
      expect(EthiopianDateUtils.clamp(date, min: min, max: max), min);
    });

    test('clamps up to max when date is after it', () {
      final date = EthiopianDate(2017, 1, 1);
      expect(EthiopianDateUtils.clamp(date, min: min, max: max), max);
    });

    test('returns min itself when date equals min', () {
      expect(EthiopianDateUtils.clamp(min, min: min, max: max), min);
    });
  });

  group('EthiopianDateUtils.clampDay (Task 1.3 DoD)', () {
    test('leaves valid day unchanged', () {
      expect(EthiopianDateUtils.clampDay(2016, 3, 15), 15);
    });

    test('clamps day 30 down to 5 for Pagume in a non-leap year', () {
      expect(EthiopianDateUtils.clampDay(2015, 13, 30), 5);
    });

    test('clamps day 30 down to 6 for Pagume in a leap year', () {
      expect(EthiopianDateUtils.clampDay(2016, 13, 30), 6);
    });

    test('clamps day below 1 up to 1', () {
      expect(EthiopianDateUtils.clampDay(2016, 5, 0), 1);
      expect(EthiopianDateUtils.clampDay(2016, 5, -5), 1);
    });

    test('leaves day 30 unchanged for a normal 30-day month', () {
      expect(EthiopianDateUtils.clampDay(2016, 5, 30), 30);
    });
  });
}
