import 'dart:convert';

import 'package:ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:ethiopian_date_picker/core/ethiopian_date_interop.dart';
import 'package:ethiopian_date_picker/core/jdn_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EthiopianDateTimeX extension (Task 1.4 DoD)', () {
    test('toEthiopianDate() is callable on an arbitrary DateTime', () {
      final gregorian = DateTime(2023, 9, 12);
      final eth = gregorian.toEthiopianDate();
      expect(eth, isA<EthiopianDate>());
      // Confirmed against actual implementation: Sept 12, 2023 -> Meskerem 2, 2016.
      expect(eth, EthiopianDate(2016, 1, 2));
    });

    test('toEthiopianDate() ignores time-of-day', () {
      final morning = DateTime(2023, 9, 12, 3, 0);
      final night = DateTime(2023, 9, 12, 23, 59);
      expect(morning.toEthiopianDate(), night.toEthiopianDate());
    });

    test('works on DateTime.now() without throwing', () {
      expect(() => DateTime.now().toEthiopianDate(), returnsNormally);
    });

    test('round-trips back through EthiopianDate.toGregorian()', () {
      final gregorian = DateTime(2023, 9, 12);
      final restored = gregorian.toEthiopianDate().toGregorian();
      expect(restored, gregorian);
    });
  });

  group('EthiopianDateFormatting.format (Task 1.4 DoD)', () {
    final date = EthiopianDate(2016, 3, 7);

    test('default pattern is yyyy-MM-dd', () {
      expect(date.format(), '2016-03-07');
    });

    test('zero-pads month and day with MM/dd', () {
      expect(date.format('MM/dd/yyyy'), '03/07/2016');
    });

    test('no-padding tokens M/d omit leading zero', () {
      expect(date.format('M/d/yyyy'), '3/7/2016');
    });

    test('yy gives last two digits of the year', () {
      expect(date.format('yy-MM-dd'), '16-03-07');
    });

    test('changing the pattern changes the output', () {
      final iso = date.format('yyyy-MM-dd');
      final us = date.format('MM/dd/yyyy');
      expect(iso, isNot(equals(us)));
    });

    test('single-digit year still pads to 4 digits', () {
      final earlyDate = EthiopianDate(7, 1, 1);
      expect(earlyDate.format('yyyy'), '0007');
    });
  });

  group('EthiopianDate toJson/fromJson (Task 1.4 DoD)', () {
    test('toJson produces the expected map shape', () {
      final date = EthiopianDate(2016, 3, 7);
      expect(date.toJson(), {'year': 2016, 'month': 3, 'day': 7});
    });

    test('fromJson round-trips through toJson', () {
      final date = EthiopianDate(2016, 3, 7);
      final restored = EthiopianDate.fromJson(date.toJson());
      expect(restored, date);
    });

    test('round-trips through actual jsonEncode/jsonDecode', () {
      // 2016 is leap -> Pagume day 6 is valid.
      final date = EthiopianDate(2016, 13, 6);
      final encoded = jsonEncode(date.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final restored = EthiopianDate.fromJson(decoded);
      expect(restored, date);
    });

    test('fromJson throws on missing keys', () {
      expect(
        () => EthiopianDate.fromJson({'year': 2016, 'month': 3}),
        throwsA(isA<InvalidCalendarDateException>()),
      );
    });

    test('fromJson throws on wrong value types', () {
      expect(
        () => EthiopianDate.fromJson(
          {'year': '2016', 'month': 3, 'day': 7},
        ),
        throwsA(isA<InvalidCalendarDateException>()),
      );
    });

    test('fromJson still enforces calendar validation', () {
      // month 14 is invalid regardless of JSON shape being correct.
      expect(
        () => EthiopianDate.fromJson({'year': 2016, 'month': 14, 'day': 1}),
        throwsA(isA<InvalidCalendarDateException>()),
      );
    });
  });
}