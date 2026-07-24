library;

/// Exception thrown when an invalid calendar date is provided during conversion or calculation.
class InvalidCalendarDateException implements Exception {
  /// Creates an exception with the provided error [message].
  InvalidCalendarDateException(this.message);

  /// The error message describing why the calendar date is invalid.
  final String message;

  @override
  String toString() => 'InvalidCalendarDateException: $message';
}

/// A lightweight data class representing a Year-Month-Day tuple.
class YMD {
  /// Creates an immutable [YMD] tuple for a calendar date.
  const YMD(this.year, this.month, this.day);

  /// The calendar year component.
  final int year;

  /// The calendar month component.
  final int month;

  /// The calendar day component.
  final int day;
}

/// Low-level utility for converting dates between the Ethiopian and Gregorian
/// calendars using Julian Day Numbers (JDN).
abstract final class JdnConverter {
  static const int _ameteMihretEpochJdn = 1724221;

  /// Returns `true` if the given Ethiopian [year] is a leap year (Pagume has 6 days).
  static bool isEthiopianLeapYear(int year) => year % 4 == 0;

  /// Calculates the Julian Day Number for New Year's Day (1st of Meskerem) of the given Ethiopian [year].
  static int newYearJdn(int year) =>
      _ameteMihretEpochJdn + 365 * (year - 1) + ((year - 1) ~/ 4);

  /// Returns the total number of days in the given Ethiopian [year] (365 in common years, 366 in leap years).
  static int daysInEthiopianYear(int year) =>
      newYearJdn(year + 1) - newYearJdn(year);

  /// Returns the number of days in a specific Ethiopian [month] and [year].
  ///
  /// Throws an [InvalidCalendarDateException] if [month] is outside the range 1–13.
  static int daysInEthiopianMonth(int year, int month) {
    if (month < 1 || month > 13) {
      throw InvalidCalendarDateException(
        'Ethiopian month must be 1-13, got $month.',
      );
    }
    if (month <= 12) return 30;
    return isEthiopianLeapYear(year) ? 6 : 5;
  }

  /// Converts an Ethiopian [year], [month], and [day] into its corresponding Julian Day Number.
  static int ethiopianToJdn(int year, int month, int day) =>
      newYearJdn(year) + (month - 1) * 30 + (day - 1);

  /// Converts a Julian Day Number [jdn] into an Ethiopian date represented as a [YMD] tuple.
  static YMD jdnToEthiopian(int jdn) {
    var year = ((jdn - _ameteMihretEpochJdn) * 4) ~/ 1461 + 1;
    while (newYearJdn(year + 1) <= jdn) {
      year += 1;
    }
    while (newYearJdn(year) > jdn) {
      year -= 1;
    }
    final int dayOfYear = jdn - newYearJdn(year) + 1;
    final int month = (dayOfYear - 1) ~/ 30 + 1;
    final int day = dayOfYear - (month - 1) * 30;
    return YMD(year, month, day);
  }

  /// Converts a Gregorian [year], [month], and [day] into its corresponding Julian Day Number.
  static int gregorianToJdn(int year, int month, int day) {
    final int a = (14 - month) ~/ 12;
    final int y = year + 4800 - a;
    final int m = month + 12 * a - 3;
    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }

  /// Converts a Julian Day Number [jdn] into a Gregorian date represented as a [YMD] tuple.
  static YMD jdnToGregorian(int jdn) {
    final int a = jdn + 32044;
    final int b = (4 * a + 3) ~/ 146097;
    final int c = a - (146097 * b) ~/ 4;
    final int d = (4 * c + 3) ~/ 1461;
    final int e = c - (1461 * d) ~/ 4;
    final int m = (5 * e + 2) ~/ 153;
    final int day = e - (153 * m + 2) ~/ 5 + 1;
    final int month = m + 3 - 12 * (m ~/ 10);
    final int year = 100 * b + d - 4800 + m ~/ 10;
    return YMD(year, month, day);
  }
}
