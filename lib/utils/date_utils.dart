import '../../core/ethiopian_date.dart';
import '../../core/jdn_converter.dart';

/// Utility functions for Ethiopian date calculations, boundary clamping,
/// and calendar metrics.
abstract final class EthiopianDateUtils {
  /// Number of days in [month] (1-13) of Ethiopian [year].
  static int daysInMonth(int year, int month) =>
      JdnConverter.daysInEthiopianMonth(year, month);

  /// Returns the 1-based weekday index (1 = Monday, 7 = Sunday) for the first
  /// day of the given Ethiopian [month] and [year].
  static int firstWeekdayOfMonth(int year, int month) {
    final int jdn = JdnConverter.ethiopianToJdn(year, month, 1);

    return (jdn + 1) % 7 + 1;
  }

  /// Calculates the number of days between [from] and [to] (positive if [to]
  /// is after [from]).
  static int daysBetween(EthiopianDate from, EthiopianDate to) =>
      to.julianDayNumber - from.julianDayNumber;

  /// Clamps [date] to be within the range bounded by [min] and [max].
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

  /// Clamps a 1-based [day] number to fall within the valid day range (1 to max days)
  /// for the specified Ethiopian [year] and [month].
  static int clampDay(int year, int month, int day) {
    final int max = daysInMonth(year, month);
    if (day < 1) return 1;
    if (day > max) return max;
    return day;
  }
}
