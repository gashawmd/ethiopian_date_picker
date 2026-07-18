import 'ethiopian_date.dart';
import 'ethiopian_date_range.dart';

/// The in-progress state of a tap-start/tap-end range selection flow.
///
/// Deliberately a plain, immutable, widget-independent class (not tied
/// to any `State` object) so the interaction logic - "first tap sets
/// start, second tap completes the range, tapping again after
/// completion resets" - can be unit-tested directly without pumping
/// any widgets. [EthiopianDateRangePickerDialog] just holds one of
/// these in its state and calls [select] on every tap.
class EthiopianDateRangeSelection {
  const EthiopianDateRangeSelection._({this.pendingStart, this.completedRange});

  /// No date has been tapped yet.
  const EthiopianDateRangeSelection.empty()
      : pendingStart = null,
        completedRange = null;

  /// Starts already "complete" with a known range - used to seed the
  /// selection from an `initialRange` without requiring two taps.
  factory EthiopianDateRangeSelection.completed(EthiopianDateRange range) =>
      EthiopianDateRangeSelection._(completedRange: range);

  /// The first date tapped, while waiting for a second tap to complete
  /// the range. Null once the range is completed (or before any tap).
  final EthiopianDate? pendingStart;

  /// The finished range, once both ends have been tapped. Null while
  /// only a pending start exists (or before any tap).
  final EthiopianDateRange? completedRange;

  /// True once both ends of the range have been picked.
  bool get isComplete => completedRange != null;

  /// The range to render right now:
  /// - the real completed range, if both ends are picked;
  /// - a single-day range at [pendingStart], if only the start has
  ///   been tapped so far (gives immediate visual feedback rather than
  ///   showing nothing until the second tap);
  /// - `null` if nothing has been tapped yet.
  EthiopianDateRange? get displayRange {
    final EthiopianDateRange? completed = completedRange;
    if (completed != null) return completed;
    final EthiopianDate? start = pendingStart;
    if (start != null) return EthiopianDateRange.single(start);
    return null;
  }

  /// Applies a tap on [date], returning the *next* selection state.
  /// This class is immutable, so callers replace their held instance
  /// with the result rather than mutating in place.
  ///
  /// - No prior tap, or a range was already completed -> [date]
  ///   becomes the new pending start (this is what makes "tap again
  ///   after completion" act as a reset rather than getting stuck).
  /// - One pending start already exists -> [date] completes the range.
  ///   If [date] is earlier than the pending start, the two are
  ///   swapped automatically so the result always satisfies
  ///   `start <= end` - the user doesn't have to tap in date order.
  ///   Tapping the same date twice produces a valid single-day range.
  EthiopianDateRangeSelection select(EthiopianDate date) {
    if (completedRange != null || pendingStart == null) {
      return EthiopianDateRangeSelection._(pendingStart: date);
    }

    final EthiopianDate anchor = pendingStart!;
    final EthiopianDate start = date.isBefore(anchor) ? date : anchor;
    final EthiopianDate end = date.isBefore(anchor) ? anchor : date;
    return EthiopianDateRangeSelection._(
      completedRange: EthiopianDateRange(start: start, end: end),
    );
  }

  /// Explicitly clears the selection, regardless of its current state.
  EthiopianDateRangeSelection reset() =>
      const EthiopianDateRangeSelection.empty();
}
