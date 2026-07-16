import '../../core/ethiopian_date.dart';
import '../../core/jdn_converter.dart';

/// Standalone date-math helpers shared by the core conversion layer and
/// (in later phases) the picker UI. Kept separate from [EthiopianDate] so
/// the UI layer can use them without pulling in anything Flutter-specific
/// on the core layer, and so they're independently unit-testable.
abstract final class EthiopianDateUtils {
  /// Number of days in [month] (1-13) of Ethiopian [year].
  static int daysInMonth(int year, int month) =>
      JdnConverter.daysInEthiopianMonth(year, month);

  /// The ISO-8601 weekday (1 = Monday .. 7 = Sunday) of the 1st day of
  /// [month] in Ethiopian [year].
  ///
  /// Handy for laying out a calendar grid: it tells you how many leading
  /// blank cells to draw before day 1.
  static int firstWeekdayOfMonth(int year, int month) {
    final int jdn = JdnConverter.ethiopianToJdn(year, month, 1);
    // JDN 0 is a Monday: (jdn + 1) % 7 gives 0=Mon .. 6=Sun, so +1 maps
    // that to the ISO convention of 1=Mon .. 7=Sun.
    return (jdn + 1) % 7 + 1;
  }

  /// Number of days between [from] and [to] (positive if [to] is later).
  /// Equivalent to `to.difference(from)` but as a free function for
  /// symmetry with the other utilities here.
  static int daysBetween(EthiopianDate from, EthiopianDate to) =>
      to.julianDayNumber - from.julianDayNumber;

  /// Clamps [date] to lie within [min] and [max] inclusive.
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

  /// Clamps [day] to a valid day number for [year]/[month], e.g. clamping
  /// day 30 down to day 6 (or 5) when [month] is Pagume.
  static int clampDay(int year, int month, int day) {
    final int max = daysInMonth(year, month);
    if (day < 1) return 1;
    if (day > max) return max;
    return day;
  }
}