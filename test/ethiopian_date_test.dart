import 'package:ethiopian_date_picker/ethiopian_date_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EthiopianDate validation (Task 1.1 DoD)', () {
    test('valid dates construct without error', () {
      expect(() => EthiopianDate(2018, 1, 1), returnsNormally);
      expect(() => EthiopianDate(2018, 12, 30), returnsNormally);
      expect(() => EthiopianDate(2015, 13, 5), returnsNormally); // non-leap
      expect(() => EthiopianDate(2016, 13, 6), returnsNormally); // leap
    });

    test('invalid month throws', () {
      expect(
        () => EthiopianDate(2018, 0, 1),
        throwsA(isA<InvalidCalendarDateException>()),
      );
      expect(
        () => EthiopianDate(2018, 14, 1),
        throwsA(isA<InvalidCalendarDateException>()),
      );
    });

    test('invalid day throws, including Pagume bounds', () {
      expect(
        () => EthiopianDate(2018, 1, 0),
        throwsA(isA<InvalidCalendarDateException>()),
      );
      expect(
        () => EthiopianDate(2018, 1, 31),
        throwsA(isA<InvalidCalendarDateException>()),
      );
      // 2015 is not a leap year -> Pagume only has 5 days.
      expect(
        () => EthiopianDate(2015, 13, 6),
        throwsA(isA<InvalidCalendarDateException>()),
      );
      // 2016 is a leap year -> Pagume day 6 is valid, day 7 is not.
      expect(
        () => EthiopianDate(2016, 13, 7),
        throwsA(isA<InvalidCalendarDateException>()),
      );
    });

    test('today() returns a valid, self-consistent date', () {
      final EthiopianDate today = EthiopianDate.today();
      expect(today.month, inInclusiveRange(1, 13));
      expect(today.toGregorian().day, DateTime.now().day);
    });
  });

  group('EthiopianDate equality & comparison (Task 1.1 DoD)', () {
    test('equality is structural', () {
      expect(EthiopianDate(2018, 1, 1), EthiopianDate(2018, 1, 1));
      expect(
        EthiopianDate(2018, 1, 1).hashCode,
        EthiopianDate(2018, 1, 1).hashCode,
      );
      expect(EthiopianDate(2018, 1, 1) == EthiopianDate(2018, 1, 2), isFalse);
    });

    test('compareTo / isBefore / isAfter / isAtSameMomentAs', () {
      final EthiopianDate a = EthiopianDate(2018, 1, 1);
      final EthiopianDate b = EthiopianDate(2018, 1, 2);
      expect(a.compareTo(b), lessThan(0));
      expect(b.compareTo(a), greaterThan(0));
      expect(a.compareTo(a), 0);
      expect(a.isBefore(b), isTrue);
      expect(b.isAfter(a), isTrue);
      expect(a.isAtSameMomentAs(EthiopianDate(2018, 1, 1)), isTrue);
    });

    test('operators < <= > >= match compareTo', () {
      final EthiopianDate a = EthiopianDate(2018, 1, 1);
      final EthiopianDate b = EthiopianDate(2018, 1, 2);
      expect(a < b, isTrue);
      expect(b > a, isTrue);
      expect(a <= a, isTrue);
      expect(a >= a, isTrue);
    });

    test('sorting a list of dates works via Comparable', () {
      final List<EthiopianDate> dates = [
        EthiopianDate(2018, 5, 10),
        EthiopianDate(2015, 13, 5),
        EthiopianDate(2018, 1, 1),
      ]..sort();
      expect(dates, [
        EthiopianDate(2015, 13, 5),
        EthiopianDate(2018, 1, 1),
        EthiopianDate(2018, 5, 10),
      ]);
    });
  });

  group('EthiopianDate <-> Gregorian conversion', () {
    test('fromGregorian / toGregorian round-trip', () {
      final DateTime g = DateTime(2023, 9, 11);
      final EthiopianDate e = EthiopianDate.fromGregorian(g);
      expect(e, EthiopianDate(2016, 1, 1));
      expect(e.toGregorian(), g);
    });
  });
}