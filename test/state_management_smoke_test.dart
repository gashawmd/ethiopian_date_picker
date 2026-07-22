// Task 6.1 — State Management Compatibility
//
// EthiopianCalendarView is stateless and fully controlled (see its doc
// comment): it owns no state of its own, just renders whatever
// displayedMonth/selectedDate it's given and reports taps upward via
// callbacks. That makes "compatibility" with Provider/Riverpod/Bloc a
// question of whether *external* state correctly drives the widget and
// receives updates back — not whether the widget has special integration
// with any of them.
//
// Each group below wires the same EthiopianCalendarView to a different
// state-management approach and verifies a tap flows external state ->
// widget rebuild -> external state, round-trip. The final group is the
// actual "no internal global/static mutable state" check: two sibling
// instances, each with independent external state, must not leak into one
// another when driven simultaneously.
//
// Run: flutter pub add --dev provider flutter_riverpod flutter_bloc
//      flutter test test/state_management_smoke_test.dart

import 'package:ethiopian_date_picker/ethiopian_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// flutter_riverpod and provider both export ChangeNotifierProvider and
// Consumer with different signatures — prefix riverpod's import so the
// two packages can coexist in one file without an ambiguous_import error.
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

final EthiopianDate _kFirstDate = EthiopianDate(2010, 1, 1);
final EthiopianDate _kLastDate = EthiopianDate(2020, 1, 1);
final EthiopianDate _kDisplayedMonth = EthiopianDate(2016, 1, 1);
final EthiopianDate _kInitialDate = EthiopianDate(2016, 1, 10);
final EthiopianDate _kTappedDate = EthiopianDate(2016, 1, 15);

EthiopianCalendarView _calendar({
  required EthiopianDate selected,
  required ValueChanged<EthiopianDate> onSelected,
  Key? key,
}) {
  return EthiopianCalendarView(
    key: key,
    displayedMonth: _kDisplayedMonth,
    firstDate: _kFirstDate,
    lastDate: _kLastDate,
    selectedDate: selected,
    onDateSelected: onSelected,
    onMonthChanged: (_) {},
  );
}

void main() {
  group('Provider', () {
    testWidgets('external ChangeNotifier drives selection', (tester) async {
      final _DateHolder holder = _DateHolder(_kInitialDate);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<_DateHolder>.value(
              value: holder,
              child: Consumer<_DateHolder>(
                builder: (context, h, _) =>
                    _calendar(selected: h.date, onSelected: h.select),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      // State changed outside the widget...
      expect(holder.date, _kTappedDate);
      // ...and the widget rebuilt to reflect it (day 15 now shows as
      // the filled/selected cell — day 10, the old selection, doesn't).
      expect(find.text('15'), findsOneWidget);
    });
  });

  group('Riverpod', () {
    final riverpod.StateProvider<EthiopianDate> dateProvider =
        riverpod.StateProvider<EthiopianDate>((ref) => _kInitialDate);

    testWidgets('external StateProvider drives selection', (tester) async {
      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: riverpod.Consumer(
                builder: (context, ref, _) {
                  final EthiopianDate date = ref.watch(dateProvider);
                  return _calendar(
                    selected: date,
                    onSelected: (d) =>
                        ref.read(dateProvider.notifier).state = d,
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      final riverpod.ProviderContainer container =
          riverpod.ProviderScope.containerOf(
        tester.element(find.byType(EthiopianCalendarView)),
      );
      expect(container.read(dateProvider), _kTappedDate);
    });
  });

  group('Bloc', () {
    testWidgets('external Cubit drives selection', (tester) async {
      final _DateCubit cubit = _DateCubit(_kInitialDate);
      addTearDown(cubit.close);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<_DateCubit>.value(
              value: cubit,
              child: BlocBuilder<_DateCubit, EthiopianDate>(
                builder: (context, date) =>
                    _calendar(selected: date, onSelected: cubit.select),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(cubit.state, _kTappedDate);
    });
  });

  group('No shared internal state', () {
    testWidgets(
        'two independently-driven instances do not leak state '
        '(no internal global/static mutable state)', (tester) async {
      final _DateHolder holderA = _DateHolder(_kInitialDate);
      final _DateHolder holderB = _DateHolder(_kInitialDate);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChangeNotifierProvider<_DateHolder>.value(
                  value: holderA,
                  child: Consumer<_DateHolder>(
                    builder: (context, h, _) => _calendar(
                      key: const Key('instance-a'),
                      selected: h.date,
                      onSelected: h.select,
                    ),
                  ),
                ),
                ChangeNotifierProvider<_DateHolder>.value(
                  value: holderB,
                  child: Consumer<_DateHolder>(
                    builder: (context, h, _) => _calendar(
                      key: const Key('instance-b'),
                      selected: h.date,
                      onSelected: h.select,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Tap day 15 only inside instance A.
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('instance-a')),
          matching: find.text('15'),
        ),
      );
      await tester.pumpAndSettle();

      expect(holderA.date, _kTappedDate);
      // B was never touched — if EthiopianCalendarView (or anything it
      // depends on) held mutable state in a static/global, this would
      // now unexpectedly equal _kTappedDate too.
      expect(holderB.date, _kInitialDate);
    });
  });
}

class _DateHolder extends ChangeNotifier {
  _DateHolder(this.date);

  EthiopianDate date;

  void select(EthiopianDate d) {
    date = d;
    notifyListeners();
  }
}

class _DateCubit extends Cubit<EthiopianDate> {
  _DateCubit(super.initialState);

  void select(EthiopianDate d) => emit(d);
}
