import 'ethiopian_date.dart';
import 'ethiopian_date_range.dart';

class EthiopianDateRangeSelection {
  const EthiopianDateRangeSelection._({this.pendingStart, this.completedRange});
  const EthiopianDateRangeSelection.empty()
      : pendingStart = null,
        completedRange = null;

  factory EthiopianDateRangeSelection.completed(EthiopianDateRange range) =>
      EthiopianDateRangeSelection._(completedRange: range);

  final EthiopianDate? pendingStart;
  final EthiopianDateRange? completedRange;
  bool get isComplete => completedRange != null;

  EthiopianDateRange? get displayRange {
    final EthiopianDateRange? completed = completedRange;
    if (completed != null) return completed;
    final EthiopianDate? start = pendingStart;
    if (start != null) return EthiopianDateRange.single(start);
    return null;
  }

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

  EthiopianDateRangeSelection reset() =>
      const EthiopianDateRangeSelection.empty();
}
