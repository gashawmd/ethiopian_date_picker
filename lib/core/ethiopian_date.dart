import 'jdn_converter.dart';

/// A date in the Ethiopian (Ge'ez) calendar.
///
/// Ethiopian years have 13 months: 12 months of 30 days each, plus a
/// short 13th month, Pagume, with 5 days (6 in an Ethiopian leap year).
/// Use [fromGregorian] to convert from a standard [DateTime], or
/// [today] for the current date. Instances are immutable and support
/// full ordering via [compareTo] and the comparison operators.
class EthiopianDate implements Comparable<EthiopianDate> {
  /// Creates an [EthiopianDate] for the given [year], [month], and [day].
  ///
  /// Throws [InvalidCalendarDateException] if [month] is not between 1
  /// and 13, or if [day] is out of range for that year/month (accounting
  /// for Pagume's 5- or 6-day length).
  factory EthiopianDate(int year, int month, int day) {
    _validate(year, month, day);
    return EthiopianDate._(year, month, day);
  }

  const EthiopianDate._(this.year, this.month, this.day);

  /// Converts a Gregorian [dateTime] to the equivalent [EthiopianDate].
  factory EthiopianDate.fromGregorian(DateTime dateTime) {
    final int jdn = JdnConverter.gregorianToJdn(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
    final YMD ymd = JdnConverter.jdnToEthiopian(jdn);
    return EthiopianDate._(ymd.year, ymd.month, ymd.day);
  }

  /// The current date, converted to the Ethiopian calendar.
  factory EthiopianDate.today() => EthiopianDate.fromGregorian(DateTime.now());

  /// Creates an [EthiopianDate] from a JSON map produced by [toJson].
  ///
  /// Expects integer `"year"`, `"month"`, and `"day"` keys. Throws
  /// [InvalidCalendarDateException] if any key is missing or not an int.
  factory EthiopianDate.fromJson(Map<String, dynamic> json) {
    final Object? y = json['year'];
    final Object? m = json['month'];
    final Object? d = json['day'];
    if (y is! int || m is! int || d is! int) {
      throw InvalidCalendarDateException(
        'EthiopianDate.fromJson expects int "year", "month", "day" keys, '
        'got $json.',
      );
    }
    return EthiopianDate(y, m, d);
  }

  /// The Ethiopian calendar year.
  final int year;

  /// The Ethiopian calendar month, from 1 to 13 (13 is Pagume).
  final int month;

  /// The day of the month, starting at 1.
  final int day;

  static void _validate(int year, int month, int day) {
    if (month < 1 || month > 13) {
      throw InvalidCalendarDateException(
        'Ethiopian month must be between 1 and 13, got $month.',
      );
    }
    final int maxDay = JdnConverter.daysInEthiopianMonth(year, month);
    if (day < 1 || day > maxDay) {
      throw InvalidCalendarDateException(
        'Ethiopian day must be between 1 and $maxDay for '
        '$year-$month, got $day.',
      );
    }
  }

  /// Whether [year] is an Ethiopian leap year (Pagume has 6 days).
  static bool isLeapYear(int year) => JdnConverter.isEthiopianLeapYear(year);

  /// Converts this date to the equivalent Gregorian [DateTime].
  DateTime toGregorian() {
    final int jdn = JdnConverter.ethiopianToJdn(year, month, day);
    final YMD ymd = JdnConverter.jdnToGregorian(jdn);
    return DateTime(ymd.year, ymd.month, ymd.day);
  }

  /// Serializes this date to a `{"year", "month", "day"}` map, suitable
  /// for JSON encoding. Use [EthiopianDate.fromJson] to reverse this.
  Map<String, int> toJson() => {'year': year, 'month': month, 'day': day};

  /// This date's Julian Day Number, used internally for comparisons
  /// and calendar conversions.
  int get julianDayNumber => JdnConverter.ethiopianToJdn(year, month, day);

  /// Returns a copy of this date with the given fields replaced.
  EthiopianDate copyWith({int? year, int? month, int? day}) {
    return EthiopianDate(
        year ?? this.year, month ?? this.month, day ?? this.day);
  }

  @override
  int compareTo(EthiopianDate other) =>
      julianDayNumber.compareTo(other.julianDayNumber);

  /// Whether this date is chronologically before [other].
  bool isBefore(EthiopianDate other) => compareTo(other) < 0;

  /// Whether this date is chronologically after [other].
  bool isAfter(EthiopianDate other) => compareTo(other) > 0;

  /// Whether this date represents the same day as [other].
  bool isAtSameMomentAs(EthiopianDate other) => compareTo(other) == 0;

  @override
  bool operator ==(Object other) =>
      other is EthiopianDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// Whether this date is chronologically before [other].
  bool operator <(EthiopianDate other) => compareTo(other) < 0;

  /// Whether this date is on or before [other].
  bool operator <=(EthiopianDate other) => compareTo(other) <= 0;

  /// Whether this date is chronologically after [other].
  bool operator >(EthiopianDate other) => compareTo(other) > 0;

  /// Whether this date is on or after [other].
  bool operator >=(EthiopianDate other) => compareTo(other) >= 0;

  @override
  String toString() => '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
