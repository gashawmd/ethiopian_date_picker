import 'package:flutter_ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:flutter_ethiopian_date_picker/ui/calendar_view.dart';
import 'package:flutter_ethiopian_date_picker/ui/date_picker_dialog.dart';
import 'package:flutter_ethiopian_date_picker/ui/date_range_picker_dialog.dart';
import 'package:flutter_ethiopian_date_picker/ui/day_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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
            lastDate: EthiopianDate(2035, 12, 30),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

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
    testWidgets('Escape closes the single-date picker dialog', (tester) async {
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
    testWidgets('previous/next month buttons carry a 48x48 minimum constraint',
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
