import 'package:ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:ethiopian_date_picker/ui/date_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal host app with a button that opens the picker and displays
/// whatever it returns, so tests can drive the whole flow end-to-end.
class _TestHost extends StatefulWidget {
  const _TestHost({
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  final EthiopianDate? initialDate;
  final EthiopianDate? firstDate;
  final EthiopianDate? lastDate;

  @override
  State<_TestHost> createState() => _TestHostState();
}

class _TestHostState extends State<_TestHost> {
  EthiopianDate? result;
  bool hasResult = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (innerContext) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showEthiopianDatePicker(
                      context: innerContext,
                      initialDate: widget.initialDate,
                      firstDate: widget.firstDate,
                      lastDate: widget.lastDate,
                    );
                    setState(() {
                      result = picked;
                      hasResult = true;
                    });
                  },
                  child: const Text('Open picker'),
                ),
                if (hasResult)
                  Text(result == null ? 'null result' : result.toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('showEthiopianDatePicker (Task 2.2 DoD)', () {
    testWidgets('one-line call with zero config opens and works',
        (tester) async {
      await tester.pumpWidget(const _TestHost());

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();

      // The dialog should now be showing.
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Defaults to today's date when nothing else is specified.
      expect(find.text(EthiopianDate.today().toString()), findsOneWidget);
    });

    testWidgets('CANCEL returns null', (tester) async {
      await tester.pumpWidget(const _TestHost());

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(find.text('null result'), findsOneWidget);
    });

    testWidgets('dismissing by tapping outside the dialog returns null',
        (tester) async {
      await tester.pumpWidget(const _TestHost());

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();

      // Tap the scrim outside the dialog content.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('null result'), findsOneWidget);
    });

    testWidgets('initialDate seeds the displayed month and selection',
        (tester) async {
      await tester.pumpWidget(
        _TestHost(
          initialDate: EthiopianDate(2016, 5, 12),
          firstDate: EthiopianDate(2000, 1, 1),
          lastDate: EthiopianDate(2020, 12, 30),
        ),
      );

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();

      // Month 5 is Tir.
      expect(find.text('Tir 2016'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text(EthiopianDate(2016, 5, 12).toString()), findsOneWidget);
    });

    testWidgets('selecting a different day and confirming returns that day',
        (tester) async {
      await tester.pumpWidget(
        _TestHost(
          initialDate: EthiopianDate(2016, 5, 12),
          firstDate: EthiopianDate(2000, 1, 1),
          lastDate: EthiopianDate(2020, 12, 30),
        ),
      );

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('20'));
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text(EthiopianDate(2016, 5, 20).toString()), findsOneWidget);
    });

    testWidgets('respects firstDate/lastDate bounds inside the dialog',
        (tester) async {
      await tester.pumpWidget(
        _TestHost(
          initialDate: EthiopianDate(2016, 1, 15),
          firstDate: EthiopianDate(2016, 1, 10), // days 1-9 disabled
          lastDate: EthiopianDate(2016, 1, 20), // days 21-30 disabled
        ),
      );

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();

      // Day 5 is out of range - tapping it should not change the
      // selection, so confirming still returns the seeded initialDate.
      await tester.tap(find.text('5'));
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text(EthiopianDate(2016, 1, 15).toString()), findsOneWidget);
    });

    testWidgets('month navigation works inside the dialog before confirming',
        (tester) async {
      await tester.pumpWidget(
        _TestHost(
          initialDate: EthiopianDate(2016, 1, 15),
          firstDate: EthiopianDate(2000, 1, 1),
          lastDate: EthiopianDate(2020, 12, 30),
        ),
      );

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();

      expect(find.text('Meskerem 2016'), findsOneWidget);

      await tester.tap(find.byTooltip('Next month'));
      // pumpAndSettle (not a single pump()) because Task 4.1 added a
      // real slide/fade transition on month change - a bare pump()
      // would catch the grid mid-transition, where both the outgoing
      // and incoming month's day cells briefly coexist in the tree,
      // making find.text('3') below ambiguous.
      await tester.pumpAndSettle();

      expect(find.text('Tikimt 2016'), findsOneWidget);

      // Selecting a day after navigating should reflect the new month.
      await tester.tap(find.text('3'));
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text(EthiopianDate(2016, 2, 3).toString()), findsOneWidget);
    });
  });

  group('EthiopianDatePickerDialog widget directly (Task 2.2 DoD)', () {
    testWidgets('can be embedded directly without showEthiopianDatePicker',
        (tester) async {
      EthiopianDate? poppedValue;
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  poppedValue = await showDialog<EthiopianDate>(
                    context: context,
                    builder: (context) => EthiopianDatePickerDialog(
                      initialDate: EthiopianDate(2016, 1, 1),
                      firstDate: EthiopianDate(2000, 1, 1),
                      lastDate: EthiopianDate(2020, 12, 30),
                    ),
                  );
                  popped = true;
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(poppedValue, EthiopianDate(2016, 1, 1));
    });
  });
}
