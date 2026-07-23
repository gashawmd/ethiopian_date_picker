import 'package:flutter_ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:flutter_ethiopian_date_picker/core/ethiopian_date_arithmetic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EthiopianDateArithmetic.addDays', () {
    test('adds within the same month', () {
      final date = EthiopianDate(2016, 1, 1);
      expect(date.addDays(5), EthiopianDate(2016, 1, 6));
    });

    test('rolls over into the next month', () {
      final date = EthiopianDate(2016, 1, 28);
      expect(date.addDays(5), EthiopianDate(2016, 2, 3));
    });

    test('rolls over Pagume into next year (non-leap)', () {
      final date = EthiopianDate(2015, 13, 3);
      expect(date.addDays(3), EthiopianDate(2016, 1, 1));
    });

    test('negative days moves backward across a year boundary', () {
      final date = EthiopianDate(2016, 1, 1);
      expect(date.addDays(-1), EthiopianDate(2015, 13, 5));
    });
  });

  group('EthiopianDateArithmetic.addMonths', () {
    test('adds within the same year', () {
      final date = EthiopianDate(2016, 1, 15);
      expect(date.addMonths(2), EthiopianDate(2016, 3, 15));
    });

    test('rolls over into Pagume within the same year', () {
      final date = EthiopianDate(2016, 12, 10);
      expect(date.addMonths(1), EthiopianDate(2016, 13, 6));
    });

    test('clamps day when landing on a shorter month (Pagume, non-leap)', () {
      final date = EthiopianDate(2015, 12, 30);
      final result = date.addMonths(1);
      expect(result.month, 13);
      expect(result.day, 5);
    });

    test('negative months moves backward across a year boundary', () {
      final date = EthiopianDate(2016, 1, 10);
      final result = date.addMonths(-1);
      expect(result.year, 2015);
      expect(result.month, 13);
    });
  });

  group('EthiopianDateArithmetic.addYears', () {
    test('adds years, same month/day', () {
      final date = EthiopianDate(2016, 5, 10);
      expect(date.addYears(1), EthiopianDate(2017, 5, 10));
    });

    test('clamps Pagume day 6 down when landing in a non-leap year', () {
      final date = EthiopianDate(2016, 13, 6);
      final result = date.addYears(1);
      expect(result.year, 2017);
      expect(result.month, 13);
      expect(result.day, 5);
    });

    test('negative years moves backward', () {
      final date = EthiopianDate(2016, 5, 10);
      expect(date.addYears(-1), EthiopianDate(2015, 5, 10));
    });
  });

  group('EthiopianDateArithmetic.difference', () {
    test('positive when other is later', () {
      final a = EthiopianDate(2016, 1, 1);
      final b = EthiopianDate(2016, 1, 10);
      expect(a.difference(b), 9);
    });

    test('negative when other is earlier', () {
      final a = EthiopianDate(2016, 1, 10);
      final b = EthiopianDate(2016, 1, 1);
      expect(a.difference(b), -9);
    });

    test('zero for the same date', () {
      final a = EthiopianDate(2016, 1, 1);
      expect(a.difference(a), 0);
    });
  });
}
