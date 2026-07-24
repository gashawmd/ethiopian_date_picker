import 'ethiopian_date.dart';
import 'ethiopian_date_range.dart';

/// Tracks the tap-start/tap-end interaction state for range selection
/// in the range picker UI.
///
/// This is a small state machine: start empty, [select] once to set a
/// pending start date, [select] again to complete the range (start
/// and end auto-swap if the second tap is before the first). A third
/// [select] call starts a brand-new range rather than extending the
/// old one.
class EthiopianDateRangeSelection {
  const EthiopianDateRangeSelection._({this.pendingStart, this.completedRange});

  /// The initial, empty selection state.
  const EthiopianDateRangeSelection.empty()
      : pendingStart = null,
        completedRange = null;

  /// Creates a selection that is already complete with [range].
  factory EthiopianDateRangeSelection.completed(EthiopianDateRange range) =>
      EthiopianDateRangeSelection._(completedRange: range);

  /// The first tapped date, while waiting for a second tap to
  /// complete the range. `null` once the range is complete or empty.
  final EthiopianDate? pendingStart;

  /// The completed range, once both start and end have been selected.
  final EthiopianDateRange? completedRange;

  /// Whether a full start/end range has been selected.
  bool get isComplete => completedRange != null;

  /// The range to visually display: the completed range if done, a
  /// single-day range around [pendingStart] if mid-selection, or
  /// `null` if nothing has been selected yet.
  EthiopianDateRange? get displayRange {
    final EthiopianDateRange? completed = completedRange;
    if (completed != null) return completed;
    final EthiopianDate? start = pendingStart;
    if (start != null) return EthiopianDateRange.single(start);
    return null;
  }

  /// Advances the selection state machine with a tap on [date].
  ///
  /// Starts a new pending selection if there was none or the previous
  /// selection was already complete; otherwise completes the range,
  /// automatically ordering start/end so `start <= end`.
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

  /// Clears the selection back to [EthiopianDateRangeSelection.empty].
  EthiopianDateRangeSelection reset() =>
      const EthiopianDateRangeSelection.empty();
}
