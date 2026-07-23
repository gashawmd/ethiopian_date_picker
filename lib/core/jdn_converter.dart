library;

class InvalidCalendarDateException implements Exception {
  InvalidCalendarDateException(this.message);

  final String message;

  @override
  String toString() => 'InvalidCalendarDateException: $message';
}

class YMD {
  const YMD(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;
}

abstract final class JdnConverter {
  static const int _ameteMihretEpochJdn = 1724221;
  static bool isEthiopianLeapYear(int year) => year % 4 == 0;
  static int newYearJdn(int year) =>
      _ameteMihretEpochJdn + 365 * (year - 1) + ((year - 1) ~/ 4);
  static int daysInEthiopianYear(int year) =>
      newYearJdn(year + 1) - newYearJdn(year);

  static int daysInEthiopianMonth(int year, int month) {
    if (month < 1 || month > 13) {
      throw InvalidCalendarDateException(
        'Ethiopian month must be 1-13, got $month.',
      );
    }
    if (month <= 12) return 30;
    return isEthiopianLeapYear(year) ? 6 : 5;
  }

  static int ethiopianToJdn(int year, int month, int day) =>
      newYearJdn(year) + (month - 1) * 30 + (day - 1);

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
