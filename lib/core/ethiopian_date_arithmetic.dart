import 'ethiopian_date.dart';
import 'jdn_converter.dart';

/// Date-arithmetic operations for [EthiopianDate].
///
/// Split out as an extension (rather than living directly on the class)
/// to keep `ethiopian_date.dart` focused on the model + validation, and
/// this file focused on math. Both are exported together from the
/// package's public API, so callers don't notice the split.
extension EthiopianDateArithmetic on EthiopianDate {
  /// Returns a new date [days] after this one (or before, if negative).
  /// Pure JDN addition, so it's correct across month/year/Pagume
  /// boundaries by construction.
  EthiopianDate addDays(int days) {
    final YMD ymd = JdnConverter.jdnToEthiopian(julianDayNumber + days);
    return EthiopianDate(ymd.year, ymd.month, ymd.day);
  }

  /// Returns a new date [months] after this one (or before, if negative).
  ///
  /// Because months in the Ethiopian calendar don't all have the same
  /// length (Pagume is short), the day is clamped to the last valid day
  /// of the resulting month rather than overflowing — e.g. Pagume 5 + 1
  /// month lands on Meskerem 5, but if you instead add a month that would
  /// land past Pagume's day count, it's clamped down to Pagume's last day.
  EthiopianDate addMonths(int months) {
    final int totalMonths = (year * 13 + (month - 1)) + months;
    final int newYear = totalMonths ~/ 13;
    final int newMonth = totalMonths % 13 + 1;
    final int maxDay = JdnConverter.daysInEthiopianMonth(newYear, newMonth);
    final int newDay = day > maxDay ? maxDay : day;
    return EthiopianDate(newYear, newMonth, newDay);
  }

  /// Returns a new date [years] after this one (or before, if negative).
  /// Handles the Pagume 6th day gracefully by clamping into a non-leap
  /// target year (mirrors `DateTime`'s Feb 29 -> Feb 28 behavior).
  EthiopianDate addYears(int years) {
    final int newYear = year + years;
    final int maxDay = JdnConverter.daysInEthiopianMonth(newYear, month);
    final int newDay = day > maxDay ? maxDay : day;
    return EthiopianDate(newYear, month, newDay);
  }

  /// Number of days between this date and [other]. Positive if [other] is
  /// later than this date, negative if earlier.
  int difference(EthiopianDate other) =>
      other.julianDayNumber - julianDayNumber;
}
