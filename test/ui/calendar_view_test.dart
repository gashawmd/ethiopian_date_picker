import 'package:ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:ethiopian_date_picker/ui/calendar_view.dart';
import 'package:ethiopian_date_picker/ui/day_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps the widget under test in the minimal scaffolding it needs:
/// a MaterialApp (for Theme.of/Navigator) and a Scaffold (for Material
/// ancestor, which InkWell inside EthiopianDayCell requires).
Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('EthiopianCalendarView rendering (Task 2.1 DoD)', () {
    testWidgets('renders 30 day cells for a normal month', (tester) async {
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

      expect(find.byType(EthiopianDayCell), findsNWidgets(30));
    });

    testWidgets('renders 6 day cells for Pagume in a leap year (2016)',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            // 2016 is leap per this package's confirmed rule (year % 4 == 0).
            displayedMonth: EthiopianDate(2016, 13, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 13, 6),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(EthiopianDayCell), findsNWidgets(6));
      // Confirm day 7 never renders - would indicate an off-by-one in
      // the Pagume day count.
      expect(find.text('7'), findsNothing);
    });

    testWidgets('renders 5 day cells for Pagume in a non-leap year (2015)',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2015, 13, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 13, 6),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(EthiopianDayCell), findsNWidgets(5));
      expect(find.text('6'), findsNothing);
    });

    testWidgets('shows correct leading blank cells before day 1',
        (tester) async {
      // Just confirms the grid renders without throwing across every
      // month of the year - leading blanks are empty SizedBox.shrink()
      // widgets, not directly assertable by count, so this is a smoke
      // test for the weekday-offset math rather than a strict count.
      for (var month = 1; month <= 13; month++) {
        await tester.pumpWidget(
          _wrap(
            EthiopianCalendarView(
              displayedMonth: EthiopianDate(2016, month, 1),
              firstDate: EthiopianDate(2000, 1, 1),
              lastDate: EthiopianDate(2020, 13, 6),
              onDateSelected: (_) {},
              onMonthChanged: (_) {},
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('EthiopianCalendarView selection & disabled states (Task 2.1 DoD)', () {
    testWidgets('disabled dates before firstDate are unselectable',
        (tester) async {
      EthiopianDate? tapped;

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2016, 1, 10), // days 1-9 disabled
            lastDate: EthiopianDate(2020, 13, 6),
            onDateSelected: (d) => tapped = d,
            onMonthChanged: (_) {},
          ),
        ),
      );

      // Day 5 should be disabled (before firstDate).
      await tester.tap(find.text('5'));
      await tester.pump();
      expect(tapped, isNull);

      // Day 15 should be selectable (on/after firstDate).
      await tester.tap(find.text('15'));
      await tester.pump();
      expect(tapped, EthiopianDate(2016, 1, 15));
    });

    testWidgets('disabled dates after lastDate are unselectable',
        (tester) async {
      EthiopianDate? tapped;

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2016, 1, 10), // days 11-30 disabled
            onDateSelected: (d) => tapped = d,
            onMonthChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('20'));
      await tester.pump();
      expect(tapped, isNull);

      await tester.tap(find.text('5'));
      await tester.pump();
      expect(tapped, EthiopianDate(2016, 1, 5));
    });

    testWidgets('selecting an in-range day fires onDateSelected exactly once',
        (tester) async {
      final selections = <EthiopianDate>[];

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 13, 6),
            onDateSelected: selections.add,
            onMonthChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('12'));
      await tester.pump();

      expect(selections, [EthiopianDate(2016, 1, 12)]);
    });
  });

  group('EthiopianCalendarView month navigation (Task 2.1 DoD)', () {
    testWidgets('tapping next-month arrow reports the following month',
        (tester) async {
      EthiopianDate? newMonth;

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 13, 6),
            onDateSelected: (_) {},
            onMonthChanged: (d) => newMonth = d,
          ),
        ),
      );

      await tester.tap(find.byTooltip('Next month'));
      await tester.pump();

      expect(newMonth, EthiopianDate(2016, 2, 1));
    });

    testWidgets('tapping previous-month arrow reports the prior month',
        (tester) async {
      EthiopianDate? newMonth;

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 2, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 13, 6),
            onDateSelected: (_) {},
            onMonthChanged: (d) => newMonth = d,
          ),
        ),
      );

      await tester.tap(find.byTooltip('Previous month'));
      await tester.pump();

      expect(newMonth, EthiopianDate(2016, 1, 1));
    });

    testWidgets(
        'previous-month arrow is disabled when it would go before firstDate',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2016, 1, 1), // nothing before this
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
      expect(previousButton.onPressed, isNull);
    });

    testWidgets('next-month arrow is disabled when it would go past lastDate',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2020, 13, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 13, 6), // nothing after this
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final IconButton nextButton = tester.widget(
        find.ancestor(
          of: find.byTooltip('Next month'),
          matching: find.byType(IconButton),
        ),
      );
      expect(nextButton.onPressed, isNull);
    });
  });

  group('EthiopianCalendarView today & selected highlighting (Task 2.1 DoD)',
      () {
    testWidgets('today is highlighted when shown in the displayed month',
        (tester) async {
      final today = EthiopianDate.today();

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(today.year, today.month, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            // Month 12 always has exactly 30 days regardless of leap
            // status, so this is always a valid upper bound.
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
      expect(todayCell.isToday, isTrue);
    });

    testWidgets('selectedDate shows isSelected true on the matching cell',
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
      expect(selectedCell.isSelected, isTrue);

      final EthiopianDayCell otherCell = tester.widget(
        find.byWidgetPredicate(
          (w) => w is EthiopianDayCell && w.day == 21,
        ),
      );
      expect(otherCell.isSelected, isFalse);
    });
  });
}
