import 'package:flutter_ethiopian_date_picker/flutter_ethiopian_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

      expect(holder.date, _kTappedDate);
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

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('instance-a')),
          matching: find.text('15'),
        ),
      );
      await tester.pumpAndSettle();

      expect(holderA.date, _kTappedDate);
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
