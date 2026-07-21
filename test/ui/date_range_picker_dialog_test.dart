import 'package:ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:ethiopian_date_picker/core/ethiopian_date_range.dart';
import 'package:ethiopian_date_picker/ui/date_range_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _dialogHost({
  EthiopianDateRange? initialRange,
  EthiopianDate? firstDate,
  EthiopianDate? lastDate,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showEthiopianDateRangePicker(
              context: context,
              initialRange: initialRange,
              firstDate: firstDate,
              lastDate: lastDate,
            ),
            child: const Text('Open range picker'),
          ),
        ),
      ),
    ),
  );
}

/// The dialog opens on today's real-world date clamped into
/// [firstDate, lastDate], NOT on firstDate's month - so tests that
/// need a known starting month (to make hardcoded day-taps land on
/// predictable dates) navigate there explicitly rather than assuming
/// where the dialog happens to open. Taps "Previous month" until it's
/// disabled, which deterministically lands on firstDate's month
/// regardless of what today's date is when the test suite runs.
Future<void> _navigateToFirstDateMonth(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    final Finder tooltipFinder = find.byTooltip('Previous month');
    final IconButton button = tester.widget<IconButton>(
      find.ancestor(of: tooltipFinder, matching: find.byType(IconButton)),
    );
    if (button.onPressed == null) break;
    await tester.tap(tooltipFinder);
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  group('showEthiopianDateRangePicker (Task 4.2 DoD)', () {
    testWidgets('one-line call with zero config opens the dialog',
        (tester) async {
      await tester.pumpWidget(_dialogHost());

      await tester.tap(find.text('Open range picker'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('OK is disabled until both start and end are tapped',
        (tester) async {
      await tester.pumpWidget(
        _dialogHost(
          firstDate: EthiopianDate(2016, 1, 1),
          lastDate: EthiopianDate(2016, 12, 30),
        ),
      );

      await tester.tap(find.text('Open range picker'));
      await tester.pumpAndSettle();

      // Before any tap: OK disabled.
      TextButton okButton =
          tester.widget(find.widgetWithText(TextButton, 'OK'));
      expect(okButton.onPressed, isNull);

      // After only the first tap (pending start, no end yet): still disabled.
      await tester.tap(find.text('10'));
      await tester.pump();
      okButton = tester.widget(find.widgetWithText(TextButton, 'OK'));
      expect(okButton.onPressed, isNull);

      // After the second tap (range complete): enabled.
      await tester.tap(find.text('20'));
      await tester.pump();
      okButton = tester.widget(find.widgetWithText(TextButton, 'OK'));
      expect(okButton.onPressed, isNotNull);
    });

    testWidgets('tap start then tap end returns the completed range',
        (tester) async {
      EthiopianDateRange? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    result = await showEthiopianDateRangePicker(
                      context: context,
                      firstDate: EthiopianDate(2016, 1, 1),
                      lastDate: EthiopianDate(2016, 12, 30),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await _navigateToFirstDateMonth(tester);

      await tester.tap(find.text('10')); // tap start
      await tester.pump();
      await tester.tap(find.text('20')); // tap end
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(
        result,
        EthiopianDateRange(
          start: EthiopianDate(2016, 1, 10),
          end: EthiopianDate(2016, 1, 20),
        ),
      );
    });

    testWidgets(
        'tapping end before start (out of order) still returns a correctly ordered range',
        (tester) async {
      EthiopianDateRange? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    result = await showEthiopianDateRangePicker(
                      context: context,
                      firstDate: EthiopianDate(2016, 1, 1),
                      lastDate: EthiopianDate(2016, 12, 30),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await _navigateToFirstDateMonth(tester);

      // Tap the LATER date first, then the earlier one.
      await tester.tap(find.text('20'));
      await tester.pump();
      await tester.tap(find.text('10'));
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(
        result,
        EthiopianDateRange(
          start: EthiopianDate(2016, 1, 10),
          end: EthiopianDate(2016, 1, 20),
        ),
      );
    });

    testWidgets(
        're-tapping after a completed range resets and starts a new selection',
        (tester) async {
      EthiopianDateRange? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    result = await showEthiopianDateRangePicker(
                      context: context,
                      firstDate: EthiopianDate(2016, 1, 1),
                      lastDate: EthiopianDate(2016, 12, 30),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await _navigateToFirstDateMonth(tester);

      // First complete cycle: 5 -> 15.
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('15'));
      await tester.pump();

      // Re-tap: this should RESET, not extend the previous range.
      await tester.tap(find.text('25'));
      await tester.pump();

      // OK should be disabled again - only a new pending start exists.
      final TextButton okAfterReset =
          tester.widget(find.widgetWithText(TextButton, 'OK'));
      expect(okAfterReset.onPressed, isNull);

      // Complete the SECOND cycle: 25 -> ... tap a day in the next
      // month to also exercise cross-month completion after a reset.
      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3'));
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(
        result,
        EthiopianDateRange(
          start: EthiopianDate(2016, 1, 25),
          end: EthiopianDate(2016, 2, 3),
        ),
      );
    });

    testWidgets('CANCEL returns null', (tester) async {
      EthiopianDateRange? result;
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    result =
                        await showEthiopianDateRangePicker(context: context);
                    completed = true;
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(result, isNull);
    });

    testWidgets('initialRange seeds a pre-completed selection', (tester) async {
      await tester.pumpWidget(
        _dialogHost(
          initialRange: EthiopianDateRange(
            start: EthiopianDate(2016, 3, 5),
            end: EthiopianDate(2016, 3, 15),
          ),
          firstDate: EthiopianDate(2000, 1, 1),
          lastDate: EthiopianDate(2020, 12, 30),
        ),
      );

      await tester.tap(find.text('Open range picker'));
      await tester.pumpAndSettle();

      // Displayed month should already be Hidar (month 3) 2016 - the
      // start's month - with no taps needed.
      expect(find.text('Hidar 2016'), findsOneWidget);

      // OK should already be enabled since the range is pre-completed.
      final TextButton okButton =
          tester.widget(find.widgetWithText(TextButton, 'OK'));
      expect(okButton.onPressed, isNotNull);
    });

    test('firstDate > lastDate throws a clear assertion error', () {
      expect(
        () => EthiopianDateRangePickerDialog(
          firstDate: EthiopianDate(2020, 1, 1),
          lastDate: EthiopianDate(2016, 1, 1),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('disabled days outside firstDate/lastDate are unselectable',
        (tester) async {
      await tester.pumpWidget(
        _dialogHost(
          firstDate: EthiopianDate(2016, 1, 10),
          lastDate: EthiopianDate(2016, 1, 20),
        ),
      );

      await tester.tap(find.text('Open range picker'));
      await tester.pumpAndSettle();

      // Day 5 is before firstDate - tapping it should not set a
      // pending start (OK should remain disabled with no visible
      // change to selection state).
      await tester.tap(find.text('5'));
      await tester.pump();

      final TextButton okButton =
          tester.widget(find.widgetWithText(TextButton, 'OK'));
      expect(okButton.onPressed, isNull);
      expect(tester.takeException(), isNull);
    });
  });
}
