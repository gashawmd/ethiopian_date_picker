import 'package:ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:ethiopian_date_picker/core/ethiopian_date_range.dart';
import 'package:ethiopian_date_picker/core/ethiopian_date_range_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EthiopianDateRangeSelection.empty (Task 4.2 DoD)', () {
    test('starts with no pending start and no completed range', () {
      const selection = EthiopianDateRangeSelection.empty();
      expect(selection.pendingStart, isNull);
      expect(selection.completedRange, isNull);
      expect(selection.displayRange, isNull);
      expect(selection.isComplete, isFalse);
    });
  });

  group('First tap sets the pending start (Task 4.2 DoD: tap start)', () {
    test('a single tap sets pendingStart and displays a single-day range', () {
      const selection = EthiopianDateRangeSelection.empty();
      final afterFirstTap = selection.select(EthiopianDate(2016, 1, 10));

      expect(afterFirstTap.pendingStart, EthiopianDate(2016, 1, 10));
      expect(afterFirstTap.completedRange, isNull);
      expect(afterFirstTap.isComplete, isFalse);
      expect(
        afterFirstTap.displayRange,
        EthiopianDateRange.single(EthiopianDate(2016, 1, 10)),
      );
    });
  });

  group('Second tap completes the range (Task 4.2 DoD: tap end)', () {
    test('tapping a later date completes start -> end in order', () {
      final afterFirstTap = const EthiopianDateRangeSelection.empty()
          .select(EthiopianDate(2016, 1, 10));
      final completed = afterFirstTap.select(EthiopianDate(2016, 1, 20));

      expect(completed.isComplete, isTrue);
      expect(completed.pendingStart, isNull);
      expect(
        completed.completedRange,
        EthiopianDateRange(
          start: EthiopianDate(2016, 1, 10),
          end: EthiopianDate(2016, 1, 20),
        ),
      );
    });

    test('tapping an earlier date auto-swaps into correct start<=end order',
        () {
      final afterFirstTap = const EthiopianDateRangeSelection.empty()
          .select(EthiopianDate(2016, 1, 20));
      // Second tap is BEFORE the first - user tapped out of order.
      final completed = afterFirstTap.select(EthiopianDate(2016, 1, 10));

      expect(completed.isComplete, isTrue);
      expect(
        completed.completedRange,
        EthiopianDateRange(
          start: EthiopianDate(2016, 1, 10),
          end: EthiopianDate(2016, 1, 20),
        ),
      );
    });

    test('tapping the same date twice produces a valid single-day range', () {
      final date = EthiopianDate(2016, 1, 10);
      final afterFirstTap =
          const EthiopianDateRangeSelection.empty().select(date);
      final completed = afterFirstTap.select(date);

      expect(completed.isComplete, isTrue);
      expect(completed.completedRange, EthiopianDateRange.single(date));
    });

    test('a cross-month completion works the same as same-month', () {
      final afterFirstTap = const EthiopianDateRangeSelection.empty()
          .select(EthiopianDate(2016, 1, 25));
      final completed = afterFirstTap.select(EthiopianDate(2016, 2, 5));

      expect(
        completed.completedRange,
        EthiopianDateRange(
          start: EthiopianDate(2016, 1, 25),
          end: EthiopianDate(2016, 2, 5),
        ),
      );
    });

    test('a cross-year completion (spanning Pagume) works correctly', () {
      final afterFirstTap = const EthiopianDateRangeSelection.empty()
          .select(EthiopianDate(2016, 13, 4));
      final completed = afterFirstTap.select(EthiopianDate(2017, 1, 3));

      expect(
        completed.completedRange,
        EthiopianDateRange(
          start: EthiopianDate(2016, 13, 4),
          end: EthiopianDate(2017, 1, 3),
        ),
      );
    });
  });

  group('Re-tap after completion resets (Task 4.2 DoD: re-tap to reset)', () {
    test(
        'tapping again after a completed range starts a brand new pending start',
        () {
      final completed = const EthiopianDateRangeSelection.empty()
          .select(EthiopianDate(2016, 1, 10))
          .select(EthiopianDate(2016, 1, 20));
      expect(completed.isComplete, isTrue);

      final afterResetTap = completed.select(EthiopianDate(2016, 3, 1));

      expect(afterResetTap.isComplete, isFalse);
      expect(afterResetTap.pendingStart, EthiopianDate(2016, 3, 1));
      expect(afterResetTap.completedRange, isNull);
      expect(
        afterResetTap.displayRange,
        EthiopianDateRange.single(EthiopianDate(2016, 3, 1)),
      );
    });

    test('a full second cycle after reset completes a brand new range', () {
      final firstRange = const EthiopianDateRangeSelection.empty()
          .select(EthiopianDate(2016, 1, 10))
          .select(EthiopianDate(2016, 1, 20));

      final secondCycle = firstRange
          .select(EthiopianDate(2016, 5, 1))
          .select(EthiopianDate(2016, 5, 10));

      expect(secondCycle.isComplete, isTrue);
      expect(
        secondCycle.completedRange,
        EthiopianDateRange(
          start: EthiopianDate(2016, 5, 1),
          end: EthiopianDate(2016, 5, 10),
        ),
      );
      // The first range is fully gone, not merged or remembered.
      expect(secondCycle.completedRange, isNot(firstRange.completedRange));
    });

    test('reset() explicitly clears regardless of current state', () {
      final midSelection = const EthiopianDateRangeSelection.empty()
          .select(EthiopianDate(2016, 1, 10));
      expect(midSelection.reset(), const EthiopianDateRangeSelection.empty());

      final completed = midSelection.select(EthiopianDate(2016, 1, 20));
      expect(completed.reset().pendingStart, isNull);
      expect(completed.reset().completedRange, isNull);
    });
  });

  group('EthiopianDateRangeSelection.completed factory', () {
    test('seeds an already-complete selection from an existing range', () {
      final range = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 1),
        end: EthiopianDate(2016, 1, 10),
      );
      final selection = EthiopianDateRangeSelection.completed(range);

      expect(selection.isComplete, isTrue);
      expect(selection.completedRange, range);
      expect(selection.displayRange, range);
    });

    test('a seeded completed selection resets normally on next tap', () {
      final range = EthiopianDateRange(
        start: EthiopianDate(2016, 1, 1),
        end: EthiopianDate(2016, 1, 10),
      );
      final selection = EthiopianDateRangeSelection.completed(range);
      final afterTap = selection.select(EthiopianDate(2016, 6, 1));

      expect(afterTap.isComplete, isFalse);
      expect(afterTap.pendingStart, EthiopianDate(2016, 6, 1));
    });
  });
}
