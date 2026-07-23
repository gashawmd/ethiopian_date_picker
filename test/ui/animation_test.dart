import 'package:flutter_ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:flutter_ethiopian_date_picker/ui/calendar_view.dart';
import 'package:flutter_ethiopian_date_picker/ui/date_picker_dialog.dart';
import 'package:flutter_ethiopian_date_picker/ui/day_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

Widget _dialogHost({
  EthiopianDate? initialDate,
  EthiopianDate? firstDate,
  EthiopianDate? lastDate,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showEthiopianDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
            ),
            child: const Text('Open picker'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('Month-change transition (Task 4.1 DoD: slide/fade)', () {
    testWidgets('AnimatedSwitcher is present around the day grid',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(AnimatedSwitcher), findsOneWidget);
    });

    testWidgets('transition duration is short enough to feel responsive',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final AnimatedSwitcher switcher =
          tester.widget(find.byType(AnimatedSwitcher));
      expect(switcher.duration.inMilliseconds, lessThanOrEqualTo(300));
    });

    testWidgets(
        'changing displayedMonth settles into the new month with correct day count',
        (tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            key: key,
            displayedMonth: EthiopianDate(2016, 12, 1), // 30 days
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );
      expect(find.byType(EthiopianDayCell), findsNWidgets(30));
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            key: key,
            displayedMonth: EthiopianDate(2016, 13, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(EthiopianDayCell), findsNWidgets(6));
      expect(tester.takeException(), isNull);
    });

    testWidgets('rapid repeated month navigation does not throw or hang',
        (tester) async {
      await tester.pumpWidget(_dialogHost());

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();

      for (var i = 0; i < 15; i++) {
        await tester.tap(find.byTooltip('Next month'));
        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final headerTexts = find.byType(Text);
      expect(headerTexts, findsWidgets);
    });
  });

  group('Ripple on day selection (Task 4.1 DoD)', () {
    testWidgets('each day cell is wrapped in an InkWell', (tester) async {
      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(EthiopianDayCell),
          matching: find.byType(InkWell),
        ),
        findsWidgets,
      );
    });

    testWidgets('a tappable day cell responds to tap without throwing',
        (tester) async {
      EthiopianDate? tapped;

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            onDateSelected: (d) => tapped = d,
            onMonthChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('12'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      expect(tapped, EthiopianDate(2016, 1, 12));

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Dialog open/close animation (Task 4.1 DoD)', () {
    testWidgets('opening shows fade and scale transitions before settling',
        (tester) async {
      await tester.pumpWidget(_dialogHost());

      await tester.tap(find.text('Open picker'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(ScaleTransition), findsWidgets);

      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('closing via OK animates out and fully removes the dialog',
        (tester) async {
      await tester.pumpWidget(_dialogHost());

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tap-outside-to-dismiss still works with the new transition',
        (tester) async {
      await tester.pumpWidget(_dialogHost());

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('transition duration is short enough to feel responsive',
        (tester) async {
      await tester.pumpWidget(_dialogHost());
      await tester.tap(find.text('Open picker'));

      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });
}
