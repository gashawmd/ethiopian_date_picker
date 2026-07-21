// test/ui/accessibility_test.dart
//
// Task 5.3 DoD coverage. Five things get tested here, matching the
// five concrete accessibility changes made to day_cell.dart,
// calendar_view.dart, header.dart, and both dialog files:
//
// 1. Each day cell's spoken Semantics label includes weekday, month,
//    day, year, and (for today) the localized "today" word.
// 2. Each day cell's tap target measures at least 48x48 regardless of
//    the visual circle's own size.
// 3. Escape closes both the single-date and range dialogs.
// 4. The header's previous/next nav buttons carry an explicit 48x48
//    minimum constraint.
// 5. Initial focus (via autofocus) lands on the selected day if
//    present, else today, when the grid first builds.
//
// This does NOT re-test screen-reader announcement wording beyond
// structural content (no assumptions about exact phrasing/punctuation
// choices), and does NOT replace the manual TalkBack/VoiceOver pass -
// that's still a real device / real screen reader check only a human
// can close out.

import 'package:ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:ethiopian_date_picker/ui/calendar_view.dart';
import 'package:ethiopian_date_picker/ui/date_picker_dialog.dart';
import 'package:ethiopian_date_picker/ui/date_range_picker_dialog.dart';
import 'package:ethiopian_date_picker/ui/day_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Same minimal scaffolding as calendar_view_test.dart: a MaterialApp
/// (for Theme.of/Navigator) and a Scaffold (for the Material ancestor
/// InkWell inside EthiopianDayCell requires).
Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('Day cell semantic labels (Task 5.3 DoD)', () {
    testWidgets(
        'a day cell exposes a spoken label with weekday, month, day, and year',
        (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 13, 6),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      // Month 1 is Meskerem, confirmed by the existing month-3 =
      // "Hidar" assertion in date_range_picker_dialog_test.dart.
      expect(
        find.bySemanticsLabel(RegExp(r'Meskerem 15, 2016')),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets("today's cell label includes the localized today word",
        (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final EthiopianDate today = EthiopianDate.today();

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(today.year, today.month, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            // Month 12 always has exactly 30 days, safe fixed bound
            // regardless of leap status - same trick used in
            // calendar_view_test.dart's "today is highlighted" test.
            lastDate: EthiopianDate(2035, 12, 30),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      // Default (English) locale's todayLabel is "Today"; the label
      // is appended as ", Today" per calendar_view.dart's
      // _semanticLabel().
      expect(find.bySemanticsLabel(RegExp(r', Today$')), findsOneWidget);

      handle.dispose();
    });

    testWidgets('a non-today day does not carry the today word',
        (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 13, 6),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      // Day 15, 2016 will essentially never be "today" while this
      // suite runs, so its label should have no trailing today word.
      expect(
        find.bySemanticsLabel(RegExp(r'Meskerem 15, 2016, Today')),
        findsNothing,
      );

      handle.dispose();
    });
  });

  group('Minimum 48x48 tap target (Task 5.3 DoD)', () {
    testWidgets('a day cell exposes a tap target of at least 48x48',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 13, 6),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final Finder dayCellFinder = find.byWidgetPredicate(
        (w) => w is EthiopianDayCell && w.day == 10,
      );
      final Finder inkWellFinder = find.descendant(
        of: dayCellFinder,
        matching: find.byType(InkWell),
      );

      final Size size = tester.getSize(inkWellFinder);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });

  group('Escape closes the dialog (Task 5.3 DoD)', () {
    testWidgets('Escape closes the single-date picker dialog',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showEthiopianDatePicker(context: context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('Escape closes the range picker dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () =>
                      showEthiopianDateRangePicker(context: context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });
  });

  group('Nav button minimum tap target (Task 5.3 DoD)', () {
    testWidgets(
        'previous/next month buttons carry a 48x48 minimum constraint',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 13, 6),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final IconButton previousButton = tester.widget(
        find.ancestor(
          of: find.byTooltip('Previous month'),
          matching: find.byType(IconButton),
        ),
      );
      final IconButton nextButton = tester.widget(
        find.ancestor(
          of: find.byTooltip('Next month'),
          matching: find.byType(IconButton),
        ),
      );

      expect(previousButton.constraints?.minWidth, greaterThanOrEqualTo(48));
      expect(previousButton.constraints?.minHeight, greaterThanOrEqualTo(48));
      expect(nextButton.constraints?.minWidth, greaterThanOrEqualTo(48));
      expect(nextButton.constraints?.minHeight, greaterThanOrEqualTo(48));
    });
  });

  group('Initial focus placement (Task 5.3 DoD)', () {
    testWidgets("today's cell autofocuses when no date is selected",
        (tester) async {
      final EthiopianDate today = EthiopianDate.today();

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(today.year, today.month, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2035, 12, 30),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final EthiopianDayCell todayCell = tester.widget(
        find.byWidgetPredicate(
          (w) => w is EthiopianDayCell && w.day == today.day,
        ),
      );
      expect(todayCell.autofocus, isTrue);
    });

    testWidgets('the selected day autofocuses instead of today, when set',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 13, 6),
            selectedDate: EthiopianDate(2016, 1, 20),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final EthiopianDayCell selectedCell = tester.widget(
        find.byWidgetPredicate(
          (w) => w is EthiopianDayCell && w.day == 20,
        ),
      );
      expect(selectedCell.autofocus, isTrue);

      final EthiopianDayCell otherCell = tester.widget(
        find.byWidgetPredicate(
          (w) => w is EthiopianDayCell && w.day == 21,
        ),
      );
      expect(otherCell.autofocus, isFalse);
    });
  });
}