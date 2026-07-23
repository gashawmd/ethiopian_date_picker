import 'ethiopian_date.dart';
import 'jdn_converter.dart';

extension EthiopianDateArithmetic on EthiopianDate {
  EthiopianDate addDays(int days) {
    final YMD ymd = JdnConverter.jdnToEthiopian(julianDayNumber + days);
    return EthiopianDate(ymd.year, ymd.month, ymd.day);
  }

  EthiopianDate addMonths(int months) {
    final int totalMonths = (year * 13 + (month - 1)) + months;
    final int newYear = totalMonths ~/ 13;
    final int newMonth = totalMonths % 13 + 1;
    final int maxDay = JdnConverter.daysInEthiopianMonth(newYear, newMonth);
    final int newDay = day > maxDay ? maxDay : day;
    return EthiopianDate(newYear, newMonth, newDay);
  }

  EthiopianDate addYears(int years) {
    final int newYear = year + years;
    final int maxDay = JdnConverter.daysInEthiopianMonth(newYear, month);
    final int newDay = day > maxDay ? maxDay : day;
    return EthiopianDate(newYear, month, newDay);
  }

  int difference(EthiopianDate other) =>
      other.julianDayNumber - julianDayNumber;
}
