// Task 6.2 — Golden Tests
//
// Screenshots EthiopianCalendarView across theme variants (Material 3
// light, Material 3 dark, a fully custom EthiopianDatePickerTheme) and
// every locale the package actually ships translation data for
// (read from supportedEthiopianLocaleCodes, so a new locale file is
// automatically covered without touching this test).
//
// First run generates the baselines:
//   flutter test --update-goldens test/golden_calendar_test.dart
// Subsequent runs compare against them:
//   flutter test test/golden_calendar_test.dart
//
// CAUTION (read before wiring into CI): Flutter's golden image
// comparison is sensitive to the OS/Skia/font-rendering stack that
// generated the baseline. Goldens generated on a dev machine (macOS/
// Windows/Linux) will very likely fail on CI's Linux runner even
// though nothing is actually wrong. Generate the committed baselines
// *inside* the same container/image your CI job uses (e.g. run the
// `--update-goldens` pass as a CI job itself, or in the same Docker
// image locally via `docker run ... flutter test --update-goldens`),
// not on a local dev machine.

import 'package:flutter_ethiopian_date_picker/flutter_ethiopian_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

final EthiopianDate _kFirstDate = EthiopianDate(2010, 1, 1);
final EthiopianDate _kLastDate = EthiopianDate(2020, 1, 1);
final EthiopianDate _kDisplayedMonth = EthiopianDate(2016, 1, 1);
final EthiopianDate _kSelectedDate = EthiopianDate(2016, 1, 12);

const EthiopianDatePickerTheme _kCustomTheme = EthiopianDatePickerTheme(
  primaryColor: Color(0xFF078930), // Ethiopian flag green
  selectedColor: Color(0xFF078930),
  backgroundColor: Colors.white,
  onSelectedColor: Colors.white,
  todayBorderColor: Color(0xFFFCDD09), // flag yellow
  disabledColor: Colors.black26,
  spacing: EthiopianDatePickerSpacing(),
  typography: EthiopianDatePickerTypography(
    headerStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    dayStyle: TextStyle(fontSize: 14),
    weekdayLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
  ),
);

Widget _harness({
  ThemeData? appTheme,
  EthiopianDatePickerTheme? pickerTheme,
  String? locale,
}) {
  return MaterialApp(
    theme: appTheme,
    home: Scaffold(
      body: Center(
        child: EthiopianCalendarView(
          displayedMonth: _kDisplayedMonth,
          firstDate: _kFirstDate,
          lastDate: _kLastDate,
          selectedDate: _kSelectedDate,
          locale: locale,
          theme: pickerTheme,
          onDateSelected: (_) {},
          onMonthChanged: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  group('Theme goldens', () {
    testGoldens('material3 light', (tester) async {
      await tester.pumpWidgetBuilder(
        _harness(appTheme: ThemeData(useMaterial3: true, brightness: Brightness.light)),
        surfaceSize: const Size(420, 520),
      );
      await screenMatchesGolden(tester, 'calendar_theme_material3_light');
    });

    testGoldens('material3 dark', (tester) async {
      await tester.pumpWidgetBuilder(
        _harness(appTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark)),
        surfaceSize: const Size(420, 520),
      );
      await screenMatchesGolden(tester, 'calendar_theme_material3_dark');
    });

    testGoldens('custom theme', (tester) async {
      await tester.pumpWidgetBuilder(
        _harness(pickerTheme: _kCustomTheme),
        surfaceSize: const Size(420, 520),
      );
      await screenMatchesGolden(tester, 'calendar_theme_custom');
    });
  });

  group('Locale goldens', () {
    // Iterates every locale the package actually has EthiopianLocaleData
    // for, rather than a hardcoded list — new locale file, automatic
    // golden coverage.
    for (final String code in supportedEthiopianLocaleCodes) {
      testGoldens('locale "$code"', (tester) async {
        await tester.pumpWidgetBuilder(
          _harness(locale: code),
          surfaceSize: const Size(420, 520),
        );
        await screenMatchesGolden(tester, 'calendar_locale_$code');
      });
    }
  });
}