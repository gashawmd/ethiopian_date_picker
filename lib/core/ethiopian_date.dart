import 'jdn_converter.dart';

class EthiopianDate implements Comparable<EthiopianDate> {
  factory EthiopianDate(int year, int month, int day) {
    _validate(year, month, day);
    return EthiopianDate._(year, month, day);
  }

  const EthiopianDate._(this.year, this.month, this.day);

  factory EthiopianDate.fromGregorian(DateTime dateTime) {
    final int jdn = JdnConverter.gregorianToJdn(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
    final YMD ymd = JdnConverter.jdnToEthiopian(jdn);
    return EthiopianDate._(ymd.year, ymd.month, ymd.day);
  }

  factory EthiopianDate.today() => EthiopianDate.fromGregorian(DateTime.now());

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

  final int year;
  final int month;
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

  static bool isLeapYear(int year) => JdnConverter.isEthiopianLeapYear(year);
  DateTime toGregorian() {
    final int jdn = JdnConverter.ethiopianToJdn(year, month, day);
    final YMD ymd = JdnConverter.jdnToGregorian(jdn);
    return DateTime(ymd.year, ymd.month, ymd.day);
  }

  Map<String, int> toJson() => {'year': year, 'month': month, 'day': day};

  int get julianDayNumber => JdnConverter.ethiopianToJdn(year, month, day);

  EthiopianDate copyWith({int? year, int? month, int? day}) {
    return EthiopianDate(
        year ?? this.year, month ?? this.month, day ?? this.day);
  }

  @override
  int compareTo(EthiopianDate other) =>
      julianDayNumber.compareTo(other.julianDayNumber);

  /// True if this date is strictly before [other].
  bool isBefore(EthiopianDate other) => compareTo(other) < 0;

  /// True if this date is strictly after [other].
  bool isAfter(EthiopianDate other) => compareTo(other) > 0;

  /// True if this date represents the same day as [other]. Equivalent to
  /// `==` for [EthiopianDate], provided for symmetry with `DateTime`'s API.
  bool isAtSameMomentAs(EthiopianDate other) => compareTo(other) == 0;

  @override
  bool operator ==(Object other) =>
      other is EthiopianDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  bool operator <(EthiopianDate other) => compareTo(other) < 0;

  bool operator <=(EthiopianDate other) => compareTo(other) <= 0;

  bool operator >(EthiopianDate other) => compareTo(other) > 0;

  bool operator >=(EthiopianDate other) => compareTo(other) >= 0;

  @override
  String toString() => '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
