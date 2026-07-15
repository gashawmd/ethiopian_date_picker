import 'converter.dart';

/// Pure calendar-math helpers for the Ethiopian calendar: leap years,
/// month lengths, and weekday calculations. Contains no Flutter
/// dependencies so it can be unit tested and reused anywhere.
class EthiopianCalendarLogic {
  const EthiopianCalendarLogic._();

  /// Month names in order, 1-indexed (index 0 is unused placeholder).
  static const List<String> monthNamesEn = <String>[
    '',
    'Meskerem',
    'Tikimt',
    'Hidar',
    'Tahsas',
    'Tir',
    'Yekatit',
    'Megabit',
    'Miazia',
    'Ginbot',
    'Sene',
    'Hamle',
    'Nehase',
    'Pagume',
  ];

  /// Returns true if [year] is an Ethiopian leap year (Pagume has 6 days).
  ///
  /// The Ethiopian calendar follows the same 4-year leap cycle as the
  /// Julian calendar: a year is a leap year when `year % 4 == 3`.
  static bool isLeapYear(int year) => year % 4 == 3;

  /// Number of days in [month] (1-13) for the given Ethiopian [year].
  static int daysInMonth(int year, int month) {
    if (month < 1 || month > 13) {
      throw RangeError.range(month, 1, 13, 'month');
    }
    if (month == 13) {
      return isLeapYear(year) ? 6 : 5;
    }
    return 30;
  }

  /// Validates that year/month/day form a real Ethiopian calendar date.
  static bool isValidDate(int year, int month, int day) {
    if (month < 1 || month > 13) return false;
    if (day < 1) return false;
    return day <= daysInMonth(year, month);
  }

  /// Returns the day of week (0 = Monday .. 6 = Sunday) for the given
  /// Ethiopian date, computed via the underlying Julian Day Number.
  static int weekdayOf(int year, int month, int day) {
    final int jdn = ethiopianToJdn(year, month, day);
    // JDN 0 is a Monday in the proleptic Julian calendar convention used
    // here; (jdn % 7) aligns 0..6 to Mon..Sun.
    return ((jdn % 7) + 7) % 7;
  }

  /// Total number of days in the given Ethiopian [year] (365 or 366).
  static int daysInYear(int year) => isLeapYear(year) ? 366 : 365;
}
