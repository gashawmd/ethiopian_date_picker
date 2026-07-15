import 'ethiopian_date.dart';

/// A range between two [EthiopianDate]s, inclusive of both ends.
///
/// [start] is always the earlier date and [end] the later one, regardless
/// of the order they were passed in.
class EthiopianDateRange {
  factory EthiopianDateRange({
    required EthiopianDate start,
    required EthiopianDate end,
  }) {
    if (start.isAfter(end)) {
      return EthiopianDateRange._(end, start);
    }
    return EthiopianDateRange._(start, end);
  }

  const EthiopianDateRange._(this.start, this.end);

  final EthiopianDate start;
  final EthiopianDate end;

  /// True if [date] falls within this range, inclusive.
  bool contains(EthiopianDate date) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  @override
  bool operator ==(Object other) {
    return other is EthiopianDateRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start - $end';
}
