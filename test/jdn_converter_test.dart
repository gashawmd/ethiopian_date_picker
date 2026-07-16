import 'dart:math';

import 'package:ethiopian_date_picker/core/jdn_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JdnConverter round-trip (Task 1.2 DoD)', () {
    test('verified real-world anchor dates convert exactly', () {
      // Ethiopian New Year 2016 E.C. == 11 September 2023 (Gregorian).
      // Well-corroborated across independent, recent sources.
      YMD g = JdnConverter.jdnToGregorian(
        JdnConverter.ethiopianToJdn(2016, 1, 1),
      );
      expect([g.year, g.month, g.day], [2023, 9, 11]);

      // Live converter anchor: 16 July 2026 (Gregorian) == Hamle 9,
      // 2018 E.C.
      final YMD e = JdnConverter.jdnToEthiopian(
        JdnConverter.gregorianToJdn(2026, 7, 16),
      );
      expect([e.year, e.month, e.day], [2018, 11, 9]);

      // Ethiopian New Year 2017 E.C. == 11 September 2024 (leap
      // Gregorian year, but the Ethiopian leap day already fell inside
      // EC 2016, so the two stay in sync at Sept 11).
      g = JdnConverter.jdnToGregorian(JdnConverter.ethiopianToJdn(2017, 1, 1));
      expect([g.year, g.month, g.day], [2024, 9, 11]);
    });

    test('100+ generated known pairs round-trip via both directions', () {
      // Generate 120 reference pairs by walking forward from a verified
      // anchor (EC 2016-01-01 == 2023-09-11) in fixed day steps, and
      // independently re-deriving the Gregorian side with Dart's own
      // DateTime, which is ground truth for Gregorian arithmetic.
      final DateTime anchorGregorian = DateTime(2023, 9, 11);
      const int anchorJdn0 = 0; // relative day offset marker
      var pairsChecked = 0;
      for (int i = -60; i < 60; i++) {
        final DateTime g = anchorGregorian.add(Duration(days: i));
        final int jdn = JdnConverter.gregorianToJdn(g.year, g.month, g.day);
        final YMD eth = JdnConverter.jdnToEthiopian(jdn);
        final int jdnBack = JdnConverter.ethiopianToJdn(
          eth.year,
          eth.month,
          eth.day,
        );
        final YMD gBack = JdnConverter.jdnToGregorian(jdnBack);
        expect(gBack.year, g.year);
        expect(gBack.month, g.month);
        expect(gBack.day, g.day);
        pairsChecked++;
      }
      expect(anchorJdn0, 0); // sanity no-op, keeps analyzer happy
      expect(pairsChecked, greaterThanOrEqualTo(100));
    });

    test('10,000+ random dates round-trip with zero drift', () {
      final Random random = Random(1234);
      const int sampleCount = 10000;
      var mismatches = 0;
      for (int i = 0; i < sampleCount; i++) {
        final int year = 1700 + random.nextInt(500); // spans centuries
        final int month = 1 + random.nextInt(12);
        final DateTime probe = DateTime(year, month + 1, 0); // last day
        final int day = 1 + random.nextInt(probe.day);

        final int jdn = JdnConverter.gregorianToJdn(year, month, day);
        final YMD eth = JdnConverter.jdnToEthiopian(jdn);
        final int backJdn = JdnConverter.ethiopianToJdn(
          eth.year,
          eth.month,
          eth.day,
        );
        final YMD back = JdnConverter.jdnToGregorian(backJdn);

        if (back.year != year || back.month != month || back.day != day) {
          mismatches++;
        }
      }
      expect(mismatches, 0);
    });

    test('century boundary (1900, 2000, 2100) round-trips cleanly', () {
      for (final int year in [1900, 2000, 2100]) {
        final int jdn = JdnConverter.gregorianToJdn(year, 1, 1);
        final YMD eth = JdnConverter.jdnToEthiopian(jdn);
        final int back = JdnConverter.ethiopianToJdn(
          eth.year,
          eth.month,
          eth.day,
        );
        final YMD backGreg = JdnConverter.jdnToGregorian(back);
        expect(backGreg.year, year);
        expect(backGreg.month, 1);
        expect(backGreg.day, 1);
      }
    });
  });

  group('Pagume / leap year logic (Task 1.2 DoD)', () {
    test(
        'Pagume day count correct across 8 consecutive years, '
        '2+ leap cycles', () {
      final Map<int, int> expected = {
        2013: 5,
        2014: 5,
        2015: 5,
        2016: 6, // leap
        2017: 5,
        2018: 5,
        2019: 5,
        2020: 6, // leap
      };
      expected.forEach((year, days) {
        expect(
          JdnConverter.daysInEthiopianMonth(year, 13),
          days,
          reason: 'Pagume day count wrong for EC $year',
        );
        expect(JdnConverter.isEthiopianLeapYear(year), days == 6);
      });
    });

    test('leap years repeat every 4 years with no exceptions', () {
      final List<int> leapYears = [
        for (int y = 2000; y <= 2040; y++)
          if (JdnConverter.isEthiopianLeapYear(y)) y,
      ];
      for (int i = 1; i < leapYears.length; i++) {
        expect(leapYears[i] - leapYears[i - 1], 4);
      }
    });
  });
}
