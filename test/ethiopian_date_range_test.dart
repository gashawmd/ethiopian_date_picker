import 'dart:convert';

import 'package:flutter_ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:flutter_ethiopian_date_picker/core/ethiopian_date_arithmetic.dart';
import 'package:flutter_ethiopian_date_picker/core/ethiopian_date_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EthiopianDateRange construction (Task 4.2 DoD)', () {
    test('start before end constructs normally', () {
      final range = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 1),
        end: EthiopianDate(2016, 1, 10),
      );
      expect(range.start, EthiopianDate(2016, 1, 1));
      expect(range.end, EthiopianDate(2016, 1, 10));
    });

    test('start equal to end constructs a valid single-day range', () {
      final date = EthiopianDate(2016, 1, 1);
      final range = EthiopianDateRange(start: date, end: date);
      expect(range.isSingleDay, isTrue);
      expect(range.dayCount, 1);
    });

    test('end before start throws InvalidDateRangeException', () {
      expect(
        () => EthiopianDateRange(
          start: EthiopianDate(2016, 1, 10),
          end: EthiopianDate(2016, 1, 1),
        ),
        throwsA(isA<InvalidDateRangeException>()),
      );
    });

    test('EthiopianDateRange.single creates a same-day range', () {
      final date = EthiopianDate(2016, 5, 5);
      final range = EthiopianDateRange.single(date);
      expect(range.start, date);
      expect(range.end, date);
      expect(range.isSingleDay, isTrue);
    });
  });

  group(
      'EthiopianDateRange.dayCount (Task 4.2 DoD: same-day/cross-month/cross-year)',
      () {
    test('same-day range has a day count of 1', () {
      final date = EthiopianDate(2016, 3, 15);
      final range = EthiopianDateRange(start: date, end: date);
      expect(range.dayCount, 1);
    });

    test('same-month range counts inclusively', () {
      final range = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 1),
        end: EthiopianDate(2016, 1, 10),
      );
      expect(range.dayCount, 10);
    });

    test('cross-month range counts correctly', () {
      final range = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 25),
        end: EthiopianDate(2016, 2, 5),
      );
      expect(range.dayCount, 11);
    });

    test('cross-year range spanning Pagume counts correctly', () {
      final range = EthiopianDateRange(
        start: EthiopianDate(2016, 13, 4),
        end: EthiopianDate(2017, 1, 3),
      );
      expect(range.dayCount, 6);
    });

    test('multi-year range counts correctly', () {
      final range = EthiopianDateRange(
        start: EthiopianDate(2010, 1, 1),
        end: EthiopianDate(2016, 1, 1),
      );
      final expected = EthiopianDate(2016, 1, 1).julianDayNumber -
          EthiopianDate(2010, 1, 1).julianDayNumber +
          1;
      expect(range.dayCount, expected);
    });
  });

  group('EthiopianDateRange.contains (Task 4.2 DoD)', () {
    final range = EthiopianDateRange(
      start: EthiopianDate(2016, 1, 10),
      end: EthiopianDate(2016, 1, 20),
    );

    test('a date inside the range is contained', () {
      expect(range.contains(EthiopianDate(2016, 1, 15)), isTrue);
    });

    test('the start date itself is contained (inclusive)', () {
      expect(range.contains(range.start), isTrue);
    });

    test('the end date itself is contained (inclusive)', () {
      expect(range.contains(range.end), isTrue);
    });

    test('a date before the range is not contained', () {
      expect(range.contains(EthiopianDate(2016, 1, 5)), isFalse);
    });

    test('a date after the range is not contained', () {
      expect(range.contains(EthiopianDate(2016, 1, 25)), isFalse);
    });

    test('a single-day range contains only that day', () {
      final date = EthiopianDate(2016, 1, 1);
      final single = EthiopianDateRange.single(date);
      expect(single.contains(date), isTrue);
      expect(single.contains(date.addDays(1)), isFalse);
    });
  });

  group('EthiopianDateRange.overlaps', () {
    test('two ranges sharing a day overlap', () {
      final a = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 1),
        end: EthiopianDate(2016, 1, 10),
      );
      final b = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 10),
        end: EthiopianDate(2016, 1, 20),
      );
      expect(a.overlaps(b), isTrue);
      expect(b.overlaps(a), isTrue);
    });

    test('two ranges with a gap between them do not overlap', () {
      final a = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 1),
        end: EthiopianDate(2016, 1, 10),
      );
      final b = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 12),
        end: EthiopianDate(2016, 1, 20),
      );
      expect(a.overlaps(b), isFalse);
      expect(b.overlaps(a), isFalse);
    });

    test('a range fully contained within another overlaps', () {
      final outer = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 1),
        end: EthiopianDate(2016, 1, 30),
      );
      final inner = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 10),
        end: EthiopianDate(2016, 1, 15),
      );
      expect(outer.overlaps(inner), isTrue);
      expect(inner.overlaps(outer), isTrue);
    });
  });

  group('EthiopianDateRange equality & copyWith', () {
    test('equality is structural', () {
      final a = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 1),
        end: EthiopianDate(2016, 1, 10),
      );
      final b = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 1),
        end: EthiopianDate(2016, 1, 10),
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different start or end breaks equality', () {
      final a = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 1),
        end: EthiopianDate(2016, 1, 10),
      );
      final differentEnd = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 1),
        end: EthiopianDate(2016, 1, 11),
      );
      expect(a == differentEnd, isFalse);
    });

    test('copyWith overrides only the specified field', () {
      final original = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 1),
        end: EthiopianDate(2016, 1, 10),
      );
      final moved = original.copyWith(end: EthiopianDate(2016, 1, 20));
      expect(moved.start, original.start);
      expect(moved.end, EthiopianDate(2016, 1, 20));
    });

    test('copyWith still enforces start <= end', () {
      final original = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 10),
        end: EthiopianDate(2016, 1, 20),
      );
      expect(
        () => original.copyWith(end: EthiopianDate(2016, 1, 5)),
        throwsA(isA<InvalidDateRangeException>()),
      );
    });
  });

  group('EthiopianDateRange serialization', () {
    test('toJson/fromJson round-trips', () {
      final range = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 1),
        end: EthiopianDate(2016, 1, 10),
      );
      final restored = EthiopianDateRange.fromJson(
        jsonDecode(jsonEncode(range.toJson())) as Map<String, dynamic>,
      );
      expect(restored, range);
    });

    test('fromJson throws on malformed input', () {
      expect(
        () => EthiopianDateRange.fromJson(
          {'start': 'not a map', 'end': <String, dynamic>{}},
        ),
        throwsA(isA<InvalidDateRangeException>()),
      );
    });
  });
}
