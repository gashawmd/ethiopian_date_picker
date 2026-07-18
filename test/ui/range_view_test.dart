import 'package:ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:ethiopian_date_picker/core/ethiopian_date_range.dart';
import 'package:ethiopian_date_picker/ui/calendar_view.dart';
import 'package:ethiopian_date_picker/ui/day_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

EthiopianDayCell _cellForDay(WidgetTester tester, int day) {
  return tester.widget<EthiopianDayCell>(
    find.byWidgetPredicate((w) => w is EthiopianDayCell && w.day == day),
  );
}

void main() {
  group('Range flags within a single month (Task 4.2 DoD)', () {
    testWidgets('start day is flagged as range start, not in-range-only',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            selectedRange: EthiopianDateRange(
              start: EthiopianDate(2016, 1, 5),
              end: EthiopianDate(2016, 1, 15),
            ),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final cell = _cellForDay(tester, 5);
      expect(cell.isRangeStart, isTrue);
      expect(cell.isRangeEnd, isFalse);
      expect(cell.isInRange, isTrue);
    });

    testWidgets('end day is flagged as range end, not in-range-only',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            selectedRange: EthiopianDateRange(
              start: EthiopianDate(2016, 1, 5),
              end: EthiopianDate(2016, 1, 15),
            ),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final cell = _cellForDay(tester, 15);
      expect(cell.isRangeEnd, isTrue);
      expect(cell.isRangeStart, isFalse);
      expect(cell.isInRange, isTrue);
    });

    testWidgets('a day strictly between start and end is in-range only',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            selectedRange: EthiopianDateRange(
              start: EthiopianDate(2016, 1, 5),
              end: EthiopianDate(2016, 1, 15),
            ),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final cell = _cellForDay(tester, 10);
      expect(cell.isInRange, isTrue);
      expect(cell.isRangeStart, isFalse);
      expect(cell.isRangeEnd, isFalse);
    });

    testWidgets('days outside the range are not flagged at all',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            selectedRange: EthiopianDateRange(
              start: EthiopianDate(2016, 1, 5),
              end: EthiopianDate(2016, 1, 15),
            ),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final before = _cellForDay(tester, 1);
      expect(before.isInRange, isFalse);
      expect(before.isRangeStart, isFalse);
      expect(before.isRangeEnd, isFalse);

      final after = _cellForDay(tester, 20);
      expect(after.isInRange, isFalse);
    });

    testWidgets('a single-day range flags that day as both start and end',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            selectedRange: EthiopianDateRange.single(EthiopianDate(2016, 1, 8)),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final cell = _cellForDay(tester, 8);
      expect(cell.isRangeStart, isTrue);
      expect(cell.isRangeEnd, isTrue);
      expect(cell.isInRange, isTrue);
    });
  });

  group('Cross-month range highlighting (Task 4.2 DoD)', () {
    final crossMonthRange = EthiopianDateRange(
      start: EthiopianDate(2016, 1, 25), // Meskerem 25
      end: EthiopianDate(2016, 2, 5), // Tikimt 5
    );

    testWidgets(
        'viewing the start month: days after start through month-end are in-range, no false end cap',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            selectedRange: crossMonthRange,
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final startCell = _cellForDay(tester, 25);
      expect(startCell.isRangeStart, isTrue);
      expect(startCell.isRangeEnd, isFalse);

      // Meskerem 30 (last day of the month) is mid-range - it should
      // be in-range but NOT flagged as the end, since the actual end
      // (Tikimt 5) lives in the next month. This is what produces an
      // uncapped band that visually continues off the right edge.
      final lastDayOfMonth = _cellForDay(tester, 30);
      expect(lastDayOfMonth.isInRange, isTrue);
      expect(lastDayOfMonth.isRangeEnd, isFalse);
      expect(lastDayOfMonth.isRangeStart, isFalse);
    });

    testWidgets(
        'viewing the end month: days from month-start through end are in-range, no false start cap',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 2, 1), // Tikimt
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            selectedRange: crossMonthRange,
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      // Tikimt 1 (first day of the month) is mid-range - in-range but
      // NOT flagged as start, since the actual start (Meskerem 25)
      // lives in the previous month.
      final firstDayOfMonth = _cellForDay(tester, 1);
      expect(firstDayOfMonth.isInRange, isTrue);
      expect(firstDayOfMonth.isRangeStart, isFalse);
      expect(firstDayOfMonth.isRangeEnd, isFalse);

      final endCell = _cellForDay(tester, 5);
      expect(endCell.isRangeEnd, isTrue);
      expect(endCell.isRangeStart, isFalse);
    });

    testWidgets('a month entirely outside the range shows no range flags',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 5, 1), // Tir - unrelated
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            selectedRange: crossMonthRange,
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      for (final day in [1, 10, 20, 30]) {
        final cell = _cellForDay(tester, day);
        expect(cell.isInRange, isFalse,
            reason: 'day $day should not be in range');
      }
    });
  });

  group('Cross-year range highlighting (Task 4.2 DoD)', () {
    // 2016 is leap -> Pagume 2016 has 6 days. Range spans New Year.
    final crossYearRange = EthiopianDateRange(
      start: EthiopianDate(2016, 13, 4), // Pagume 4, 2016
      end: EthiopianDate(2017, 1, 3), // Meskerem 3, 2017
    );

    testWidgets('viewing Pagume 2016: days 4-6 are in-range, day 4 is start',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 13, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            selectedRange: crossYearRange,
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final startCell = _cellForDay(tester, 4);
      expect(startCell.isRangeStart, isTrue);

      // Day 6 is Pagume's last day in this leap year - mid-range, no
      // end cap, since the range continues into 2017's Meskerem.
      final lastPagumeDay = _cellForDay(tester, 6);
      expect(lastPagumeDay.isInRange, isTrue);
      expect(lastPagumeDay.isRangeEnd, isFalse);

      // Day 1-3 of Pagume are before the range starts.
      final beforeStart = _cellForDay(tester, 1);
      expect(beforeStart.isInRange, isFalse);
    });

    testWidgets('viewing Meskerem 2017: days 1-3 are in-range, day 3 is end',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2017, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            selectedRange: crossYearRange,
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final firstDay = _cellForDay(tester, 1);
      expect(firstDay.isInRange, isTrue);
      expect(firstDay.isRangeStart, isFalse);

      final endCell = _cellForDay(tester, 3);
      expect(endCell.isRangeEnd, isTrue);

      final afterEnd = _cellForDay(tester, 5);
      expect(afterEnd.isInRange, isFalse);
    });
  });

  group('selectedRange vs selectedDate priority (Task 4.2 DoD)', () {
    testWidgets('selectedRange takes priority when both are provided',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            selectedDate: EthiopianDate(2016, 1, 20), // should be ignored
            selectedRange: EthiopianDateRange(
              start: EthiopianDate(2016, 1, 5),
              end: EthiopianDate(2016, 1, 15),
            ),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      // day 20 (selectedDate) should NOT show as selected, since
      // selectedRange is active.
      final ignoredSelectedDate = _cellForDay(tester, 20);
      expect(ignoredSelectedDate.isSelected, isFalse);

      // The range's own start/end still render correctly.
      final startCell = _cellForDay(tester, 5);
      expect(startCell.isRangeStart, isTrue);
    });

    testWidgets(
        'omitting selectedRange leaves single-date mode fully unaffected',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            selectedDate: EthiopianDate(2016, 1, 20),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final cell = _cellForDay(tester, 20);
      expect(cell.isSelected, isTrue);
      expect(cell.isRangeStart, isFalse);
      expect(cell.isRangeEnd, isFalse);
      expect(cell.isInRange, isFalse);
    });
  });

  group('Range mode does not break tap-through (Task 4.2 DoD)', () {
    testWidgets('tapping a day in range mode still fires onDateSelected',
        (tester) async {
      EthiopianDate? tapped;

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            selectedRange: EthiopianDateRange(
              start: EthiopianDate(2016, 1, 5),
              end: EthiopianDate(2016, 1, 15),
            ),
            onDateSelected: (d) => tapped = d,
            onMonthChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('10'));
      await tester.pump();

      expect(tapped, EthiopianDate(2016, 1, 10));
      expect(tester.takeException(), isNull);
    });
  });
}
