import 'ethiopian_date.dart';

/// Thrown when an [EthiopianDateRange] is constructed with an end date
/// before its start date.
class InvalidDateRangeException implements Exception {
  /// Creates an exception with the given [message].
  const InvalidDateRangeException(this.message);

  /// A human-readable description of what went wrong.
  final String message;

  @override
  String toString() => 'InvalidDateRangeException: $message';
}

/// An inclusive range between two [EthiopianDate]s, used by
/// `showEthiopianDateRangePicker` and range-selection UI.
class EthiopianDateRange {
  /// Creates a range from [start] to [end], inclusive.
  ///
  /// Throws [InvalidDateRangeException] if [end] is before [start].
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

  /// Creates a single-day range where [start] and [end] are both [date].
  factory EthiopianDateRange.single(EthiopianDate date) =>
      EthiopianDateRange._(date, date);

  /// The first date in the range.
  final EthiopianDate start;

  /// The last date in the range.
  final EthiopianDate end;

  /// Whether this range spans a single day (`start == end`).
  bool get isSingleDay => start == end;

  /// The number of days spanned by this range, inclusive of both ends.
  int get dayCount => end.julianDayNumber - start.julianDayNumber + 1;

  /// Whether [date] falls within this range, inclusive of both ends.
  bool contains(EthiopianDate date) =>
      !date.isBefore(start) && !date.isAfter(end);

  /// Whether this range shares any days with [other].
  bool overlaps(EthiopianDateRange other) =>
      !(other.end.isBefore(start) || other.start.isAfter(end));

  /// Returns a copy of this range with the given fields replaced.
  EthiopianDateRange copyWith({EthiopianDate? start, EthiopianDate? end}) {
    return EthiopianDateRange(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  /// Serializes this range to a `{"start", "end"}` map of JSON date
  /// objects. Use [EthiopianDateRange.fromJson] to reverse this.
  Map<String, Map<String, int>> toJson() => {
        'start': start.toJson(),
        'end': end.toJson(),
      };

  /// Creates an [EthiopianDateRange] from a JSON map produced by [toJson].
  ///
  /// Throws [InvalidDateRangeException] if `"start"` or `"end"` are
  /// missing or malformed.
  factory EthiopianDateRange.fromJson(Map<String, dynamic> json) {
    final Object? startJson = json['start'];
    final Object? endJson = json['end'];
    if (startJson is! Map<String, dynamic> ||
        endJson is! Map<String, dynamic>) {
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
