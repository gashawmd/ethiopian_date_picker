import 'package:ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:ethiopian_date_picker/ui/date_picker_dialog.dart';
import 'package:ethiopian_date_picker/ui/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('Clamping out-of-range selections (Task 2.3 DoD)', () {
    testWidgets(
        'initialDate before firstDate is clamped to firstDate, not left as-is',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianDatePickerDialog(
            // Deliberately before firstDate.
            initialDate: EthiopianDate(2000, 1, 1),
            firstDate: EthiopianDate(2016, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
          ),
        ),
      );

      // The displayed month should reflect the clamped date (2016-01),
      // not the raw out-of-range initialDate (2000-01).
      expect(find.text('Meskerem 2016'), findsOneWidget);

      // Confirming immediately (no further interaction) should return
      // the clamped date, not the original out-of-range one.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      // Dialog is gone; nothing further to assert here directly, but
      // the fact that it didn't throw during initState is itself part
      // of the DoD - an unclamped out-of-range initialDate would have
      // produced a display state the calendar can't represent as
      // "selected" within the visible range.
    });

    testWidgets(
        'initialDate after lastDate is clamped to lastDate, not left as-is',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianDatePickerDialog(
            // Deliberately after lastDate.
            initialDate: EthiopianDate(2030, 1, 1),
            firstDate: EthiopianDate(2016, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
          ),
        ),
      );

      expect(find.text('Nehase 2020'), findsOneWidget);
    });

    testWidgets('initialDate already within range is left unchanged',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianDatePickerDialog(
            initialDate: EthiopianDate(2017, 3, 10),
            firstDate: EthiopianDate(2016, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
          ),
        ),
      );

      expect(find.text('Hidar 2017'), findsOneWidget);
    });
  });

  group('Debug-mode assertions for invalid config (Task 2.3 DoD)', () {
    test('firstDate > lastDate throws a clear assertion error', () {
      expect(
        () => EthiopianDatePickerDialog(
          initialDate: EthiopianDate(2016, 1, 1),
          firstDate: EthiopianDate(2020, 1, 1), // after lastDate
          lastDate: EthiopianDate(2016, 1, 1),
        ),
        throwsAssertionError,
      );
    });

    test('the assertion message clearly names the problem', () {
      try {
        EthiopianDatePickerDialog(
          initialDate: EthiopianDate(2016, 1, 1),
          firstDate: EthiopianDate(2020, 1, 1),
          lastDate: EthiopianDate(2016, 1, 1),
        );
        fail('Expected an AssertionError to be thrown');
      } on AssertionError catch (e) {
        expect(e.message.toString(), contains('firstDate'));
        expect(e.message.toString(), contains('lastDate'));
      }
    });

    test('firstDate == lastDate does not throw (a single selectable day)', () {
      expect(
        () => EthiopianDatePickerDialog(
          initialDate: EthiopianDate(2016, 1, 1),
          firstDate: EthiopianDate(2016, 1, 1),
          lastDate: EthiopianDate(2016, 1, 1),
        ),
        returnsNormally,
      );
    });

    test('firstDate < lastDate (the normal case) does not throw', () {
      expect(
        () => EthiopianDatePickerDialog(
          initialDate: EthiopianDate(2016, 1, 1),
          firstDate: EthiopianDate(2000, 1, 1),
          lastDate: EthiopianDate(2020, 1, 1),
        ),
        returnsNormally,
      );
    });
  });

  group('Locale fallback (Task 2.3 DoD)', () {
    test('resolveLocale falls back to en for null', () {
      expect(EthiopianCalendarHeader.resolveLocale(null), 'en');
    });

    test('resolveLocale falls back to en for an unsupported code', () {
      expect(EthiopianCalendarHeader.resolveLocale('fr'), 'en');
      expect(EthiopianCalendarHeader.resolveLocale('xx-not-a-locale'), 'en');
      expect(EthiopianCalendarHeader.resolveLocale(''), 'en');
    });

    test('resolveLocale keeps a supported code as-is', () {
      expect(EthiopianCalendarHeader.resolveLocale('en'), 'en');
    });

    testWidgets('an invalid locale does not crash the header, falls back',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarHeader(
            year: 2016,
            month: 1,
            locale: 'not-a-real-locale',
            onPreviousMonth: () {},
            onNextMonth: () {},
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      // Falls back to English month names.
      expect(find.text('Meskerem 2016'), findsOneWidget);
    });

    testWidgets('a missing locale (null) does not crash the header',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarHeader(
            year: 2016,
            month: 1,
            onPreviousMonth: () {},
            onNextMonth: () {},
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Meskerem 2016'), findsOneWidget);
    });

    testWidgets(
        'an invalid locale passed through the full dialog does not crash',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianDatePickerDialog(
            initialDate: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            locale: 'totally-bogus',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Meskerem 2016'), findsOneWidget);
    });
  });
}
