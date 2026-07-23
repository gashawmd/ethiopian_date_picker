import '../../core/ethiopian_date.dart';
import '../../core/jdn_converter.dart';

abstract final class EthiopianDateUtils {
  /// Number of days in [month] (1-13) of Ethiopian [year].
  static int daysInMonth(int year, int month) =>
      JdnConverter.daysInEthiopianMonth(year, month);

  static int firstWeekdayOfMonth(int year, int month) {
    final int jdn = JdnConverter.ethiopianToJdn(year, month, 1);

    return (jdn + 1) % 7 + 1;
  }

  static int daysBetween(EthiopianDate from, EthiopianDate to) =>
      to.julianDayNumber - from.julianDayNumber;

  static EthiopianDate clamp(
    EthiopianDate date, {
    required EthiopianDate min,
    required EthiopianDate max,
  }) {
    assert(!min.isAfter(max), 'min ($min) must not be after max ($max)');
    if (date.isBefore(min)) return min;
    if (date.isAfter(max)) return max;
    return date;
  }

  static int clampDay(int year, int month, int day) {
    final int max = daysInMonth(year, month);
    if (day < 1) return 1;
    if (day > max) return max;
    return day;
  }
}
