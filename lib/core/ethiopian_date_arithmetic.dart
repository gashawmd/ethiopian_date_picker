import 'ethiopian_date.dart';
import 'jdn_converter.dart';

/// Date arithmetic helpers for [EthiopianDate].
extension EthiopianDateArithmetic on EthiopianDate {
  /// Returns a new date [days] days after this one (negative to go
  /// backwards).
  EthiopianDate addDays(int days) {
    final YMD ymd = JdnConverter.jdnToEthiopian(julianDayNumber + days);
    return EthiopianDate(ymd.year, ymd.month, ymd.day);
  }

  /// Returns a new date [months] months after this one, clamping the
  /// day to the target month's length if needed.
  EthiopianDate addMonths(int months) {
    final int totalMonths = (year * 13 + (month - 1)) + months;
    final int newYear = totalMonths ~/ 13;
    final int newMonth = totalMonths % 13 + 1;
    final int maxDay = JdnConverter.daysInEthiopianMonth(newYear, newMonth);
    final int newDay = day > maxDay ? maxDay : day;
    return EthiopianDate(newYear, newMonth, newDay);
  }

  /// Returns a new date [years] years after this one, clamping the
  /// day if the target year's Pagume is a different length.
  EthiopianDate addYears(int years) {
    final int newYear = year + years;
    final int maxDay = JdnConverter.daysInEthiopianMonth(newYear, month);
    final int newDay = day > maxDay ? maxDay : day;
    return EthiopianDate(newYear, month, newDay);
  }

  /// The number of days between this date and [other] (positive if
  /// [other] is later).
  int difference(EthiopianDate other) =>
      other.julianDayNumber - julianDayNumber;
}
