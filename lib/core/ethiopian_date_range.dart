import 'ethiopian_date.dart';

class InvalidDateRangeException implements Exception {
  const InvalidDateRangeException(this.message);

  final String message;

  @override
  String toString() => 'InvalidDateRangeException: $message';
}

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

  factory EthiopianDateRange.single(EthiopianDate date) =>
      EthiopianDateRange._(date, date);

  final EthiopianDate start;
  final EthiopianDate end;
  bool get isSingleDay => start == end;
  int get dayCount => end.julianDayNumber - start.julianDayNumber + 1;
  bool contains(EthiopianDate date) =>
      !date.isBefore(start) && !date.isAfter(end);
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
