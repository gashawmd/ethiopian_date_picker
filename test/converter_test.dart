import 'package:flutter_test/flutter_test.dart';
import 'package:ethiopian_date_picker/ethiopian_date_picker.dart';

void main() {
  group('Anchor date (Ethiopian Millennium)', () {
    test('2007-09-11 Gregorian == 2000-01-01 Ethiopian', () {
      final eth = EthiopianDate.fromGregorian(DateTime(2007, 9, 11));
      expect(eth.year, 2000);
      expect(eth.month, 1);
      expect(eth.day, 1);

      final greg = EthiopianDate(2000, 1, 1).toGregorian();
      expect(greg, DateTime(2007, 9, 11));
    });
  });

  group('Round-trip conversion accuracy (100+ pairs)', () {
    test('round-trips 500 pseudo-random Gregorian dates exactly', () {
      final random = List.generate(500, (i) => i);
      for (final seed in random) {
        final year = 1900 + (seed * 37) % 200;
        final month = 1 + (seed * 7) % 12;
        final day = 1 + (seed * 13) % 28;
        final original = DateTime(year, month, day);

        final eth = EthiopianDate.fromGregorian(original);
        final backToGregorian = eth.toGregorian();

        expect(
          backToGregorian,
          original,
          reason: 'Failed round-trip for $original -> $eth -> $backToGregorian',
        );
      }
    });

    test('round-trips 100+ known distinct calendar dates', () {
      final knownDates = <DateTime>[
        for (int y = 1920; y <= 2026; y += 1) DateTime(y, 9, 15),
      ];
      expect(knownDates.length, greaterThanOrEqualTo(100));

      for (final date in knownDates) {
        final eth = EthiopianDate.fromGregorian(date);
        final back = eth.toGregorian();
        expect(back, date);
      }
    });
  });

  group('Pagume (13th month) handling', () {
    test('leap year Pagume has 6 days', () {
      // 2015 is an Ethiopian leap year (2015 % 4 == 3).
      expect(EthiopianCalendarLogic.isLeapYear(2015), isTrue);
      expect(EthiopianCalendarLogic.daysInMonth(2015, 13), 6);
      expect(EthiopianCalendarLogic.isValidDate(2015, 13, 6), isTrue);
    });

    test('non-leap year Pagume has only 5 days', () {
      expect(EthiopianCalendarLogic.isLeapYear(2016), isFalse);
      expect(EthiopianCalendarLogic.daysInMonth(2016, 13), 5);
      expect(EthiopianCalendarLogic.isValidDate(2016, 13, 6), isFalse);
    });

    test('constructing Pagume 6 in a non-leap year throws', () {
      expect(() => EthiopianDate(2016, 13, 6), throwsArgumentError);
    });
  });

  group('Leap year transitions', () {
    test('leap years follow the year % 4 == 3 rule', () {
      for (final y in [2003, 2007, 2011, 2015, 2019, 2023]) {
        expect(EthiopianCalendarLogic.isLeapYear(y), isTrue, reason: '$y should be leap');
      }
      for (final y in [2001, 2002, 2004, 2016, 2017, 2018]) {
        expect(EthiopianCalendarLogic.isLeapYear(y), isFalse, reason: '$y should not be leap');
      }
    });

    test('day after Pagume rolls over into next year Meskerem 1', () {
      const leapYear = 2015;
      final lastDayOfYear = EthiopianDate(leapYear, 13, 6);
      final nextDay = EthiopianDate.fromGregorian(
        lastDayOfYear.toGregorian().add(const Duration(days: 1)),
      );
      expect(nextDay.year, leapYear + 1);
      expect(nextDay.month, 1);
      expect(nextDay.day, 1);
    });
  });

  group('Year boundaries', () {
    test('last day of month 12 rolls into month 13 (Pagume)', () {
      final date = EthiopianDate(2016, 12, 30);
      final next = date.addMonths(1);
      expect(next.year, 2016);
      expect(next.month, 13);
    });

    test('last day of Pagume rolls into next year month 1', () {
      final date = EthiopianDate(2016, 13, 5); // non-leap, 5 days
      final next = date.addMonths(1);
      expect(next.year, 2017);
      expect(next.month, 1);
    });
  });

  group('Validation / error handling', () {
    test('invalid month throws ArgumentError', () {
      expect(() => EthiopianDate(2016, 14, 1), throwsArgumentError);
      expect(() => EthiopianDate(2016, 0, 1), throwsArgumentError);
    });

    test('invalid day throws ArgumentError', () {
      expect(() => EthiopianDate(2016, 1, 31), throwsArgumentError);
      expect(() => EthiopianDate(2016, 1, 0), throwsArgumentError);
    });
  });

  group('Comparison and ranges', () {
    test('compareTo / isBefore / isAfter work correctly', () {
      final a = EthiopianDate(2016, 1, 1);
      final b = EthiopianDate(2016, 1, 2);
      expect(a.isBefore(b), isTrue);
      expect(b.isAfter(a), isTrue);
      expect(a.compareTo(a), 0);
    });

    test('EthiopianDateRange normalizes start/end order', () {
      final range = EthiopianDateRange(
        start: EthiopianDate(2016, 2, 10),
        end: EthiopianDate(2016, 1, 1),
      );
      expect(range.start, EthiopianDate(2016, 1, 1));
      expect(range.end, EthiopianDate(2016, 2, 10));
    });

    test('EthiopianDateRange.contains works inclusively', () {
      final range = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 1),
        end: EthiopianDate(2016, 1, 10),
      );
      expect(range.contains(EthiopianDate(2016, 1, 1)), isTrue);
      expect(range.contains(EthiopianDate(2016, 1, 10)), isTrue);
      expect(range.contains(EthiopianDate(2016, 1, 5)), isTrue);
      expect(range.contains(EthiopianDate(2016, 1, 11)), isFalse);
    });
  });

  group('Weekday calculation', () {
    test('known weekday: Meskerem 1, 2000 (2007-09-11) was a Tuesday', () {
      // weekday: 0=Monday ... 6=Sunday
      final date = EthiopianDate(2000, 1, 1);
      expect(date.weekday, 1); // Tuesday
    });
  });
}
