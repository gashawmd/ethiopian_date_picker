import 'ethiopian_date.dart';

/// Thrown when constructing an [EthiopianDateRange] whose `end` is
/// before its `start`. Kept separate from [InvalidCalendarDateException]
/// since this is a different kind of problem - both dates are
/// individually valid, it's their relationship that's invalid.
class InvalidDateRangeException implements Exception {
  const InvalidDateRangeException(this.message);

  final String message;

  @override
  String toString() => 'InvalidDateRangeException: $message';
}

/// An inclusive range of Ethiopian dates, from [start] to [end].
///
/// Mirrors Flutter's own `DateTimeRange`: both endpoints are inclusive,
/// and a range may span a single day (`start == end`). Construction
/// enforces `start <= end` as an invariant - once you hold an
/// [EthiopianDateRange], you can rely on it being well-formed without
/// re-checking, the same guarantee [EthiopianDate] itself gives for
/// individual dates.
class EthiopianDateRange {
  factory EthiopianDateRange({
    required EthiopianDate start,
    required EthiopianDate end,
  }) {
    if (end.isBefore(start)) {
      throw InvalidDateRangeException(
        'EthiopianDateRange: end ($end) must not be before start ($start).',
      );
    }
    return EthiopianDateRange._(start, end);
  }

  const EthiopianDateRange._(this.start, this.end);

  /// A single-day range where [start] and [end] are the same date.
  factory EthiopianDateRange.single(EthiopianDate date) =>
      EthiopianDateRange._(date, date);

  final EthiopianDate start;
  final EthiopianDate end;

  /// True if this range spans exactly one day (`start == end`).
  bool get isSingleDay => start == end;

  /// Number of days spanned, inclusive of both [start] and [end]. A
  /// single-day range has a [dayCount] of 1, matching how a calendar
  /// UI would describe "just today" rather than "zero days."
  int get dayCount => end.julianDayNumber - start.julianDayNumber + 1;

  /// True if [date] falls within this range, inclusive of both ends.
  bool contains(EthiopianDate date) =>
      !date.isBefore(start) && !date.isAfter(end);

  /// True if this range shares at least one day with [other].
  bool overlaps(EthiopianDateRange other) =>
      !(other.end.isBefore(start) || other.start.isAfter(end));

  EthiopianDateRange copyWith({EthiopianDate? start, EthiopianDate? end}) {
    return EthiopianDateRange(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  Map<String, Map<String, int>> toJson() => {
        'start': start.toJson(),
        'end': end.toJson(),
      };

  factory EthiopianDateRange.fromJson(Map<String, dynamic> json) {
    final Object? startJson = json['start'];
    final Object? endJson = json['end'];
    if (startJson is! Map<String, dynamic> || endJson is! Map<String, dynamic>) {
      throw InvalidDateRangeException(
        'EthiopianDateRange.fromJson expects "start" and "end" objects, '
        'got $json.',
      );
    }
    return EthiopianDateRange(
      start: EthiopianDate.fromJson(startJson),
      end: EthiopianDate.fromJson(endJson),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is EthiopianDateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start - $end';
}