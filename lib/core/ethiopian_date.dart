import 'calendar_logic.dart';
import 'converter.dart';

/// An immutable representation of a date on the Ethiopian (Ge'ez) calendar.
///
/// Month is 1-13 (13 = Pagumē, the short 13th month). Day is 1-30 for
/// months 1-12, and 1-5 (or 1-6 in a leap year) for month 13.
class EthiopianDate implements Comparable<EthiopianDate> {
  /// Creates an Ethiopian date. Throws [ArgumentError] if the
  /// year/month/day combination is not a valid Ethiopian calendar date.
  EthiopianDate(this.year, this.month, this.day) {
    if (!EthiopianCalendarLogic.isValidDate(year, month, day)) {
      throw ArgumentError(
        'Invalid Ethiopian date: $year-$month-$day. '
        'Month must be 1-13 and day must fit within that month '
        '(Pagume has ${EthiopianCalendarLogic.isLeapYear(year) ? 6 : 5} '
        'days for year $year).',
      );
    }
  }

  /// Internal constructor that skips validation, used only for values we
  /// already know are correct (e.g. derived from JDN math).
  const EthiopianDate._unchecked(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  /// Builds an [EthiopianDate] from a Gregorian [DateTime].
  factory EthiopianDate.fromGregorian(DateTime dateTime) {
    final int jdn = gregorianToJdn(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
    final result = jdnToEthiopian(jdn);
    return EthiopianDate._unchecked(result.year, result.month, result.day);
  }

  /// Returns today's date, converted to the Ethiopian calendar.
  factory EthiopianDate.today() => EthiopianDate.fromGregorian(DateTime.now());

  /// Converts this Ethiopian date to the equivalent Gregorian [DateTime].
  DateTime toGregorian() {
    final int jdn = ethiopianToJdn(year, month, day);
    final result = jdnToGregorian(jdn);
    return DateTime(result.year, result.month, result.day);
  }

  /// Number of days in this date's month.
  int get daysInMonth => EthiopianCalendarLogic.daysInMonth(year, month);

  /// True if this date falls in an Ethiopian leap year (Pagume has 6 days).
  bool get isLeapYear => EthiopianCalendarLogic.isLeapYear(year);

  /// Day of week: 0 = Monday .. 6 = Sunday.
  int get weekday => EthiopianCalendarLogic.weekdayOf(year, month, day);

  /// Returns a copy of this date with the given fields replaced.
  EthiopianDate copyWith({int? year, int? month, int? day}) {
    return EthiopianDate(year ?? this.year, month ?? this.month, day ?? this.day);
  }

  /// Returns a new date representing the first day of this date's month.
  EthiopianDate get firstDayOfMonth => EthiopianDate._unchecked(year, month, 1);

  /// Returns a new date advanced or rewound by [months] months, clamping
  /// the day if the target month is shorter (e.g. moving into Pagume).
  EthiopianDate addMonths(int months) {
    final int totalMonths = (year * 13) + (month - 1) + months;
    final int newYear = totalMonths ~/ 13;
    int newMonth = totalMonths % 13;
    if (newMonth < 0) {
      newMonth += 13;
    }
    newMonth += 1;
    final int maxDay = EthiopianCalendarLogic.daysInMonth(newYear, newMonth);
    final int newDay = day > maxDay ? maxDay : day;
    return EthiopianDate._unchecked(newYear, newMonth, newDay);
  }

  bool isBefore(EthiopianDate other) => compareTo(other) < 0;
  bool isAfter(EthiopianDate other) => compareTo(other) > 0;
  bool isAtSameMomentAs(EthiopianDate other) => compareTo(other) == 0;

  @override
  int compareTo(EthiopianDate other) {
    return ethiopianToJdn(
      year,
      month,
      day,
    ).compareTo(ethiopianToJdn(other.year, other.month, other.day));
  }

  @override
  bool operator ==(Object other) {
    return other is EthiopianDate &&
        other.year == year &&
        other.month == month &&
        other.day == day;
  }

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() {
    final monthName = EthiopianCalendarLogic.monthNamesEn[month];
    return '$monthName $day, $year';
  }
}
