import '../core/ethiopian_date.dart';
import '../localization/ethiopian_locale.dart';

/// Formatting helpers for [EthiopianDate].
class EthiopianDateUtils {
  const EthiopianDateUtils._();

  /// Formats as "Month Day, Year", e.g. "Meskerem 1, 2016".
  static String format(
    EthiopianDate date, {
    EthiopianLocaleData locale = EthiopianLocale.english,
  }) {
    final monthName = locale.monthNames[date.month - 1];
    return '$monthName ${date.day}, ${date.year}';
  }

  /// Formats as zero-padded "YYYY-MM-DD", e.g. "2016-01-01".
  static String formatIso(EthiopianDate date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  /// Clamps [date] into the inclusive range [firstDate]..[lastDate].
  /// If either bound is null, that side is left unclamped.
  static EthiopianDate clamp(
    EthiopianDate date, {
    EthiopianDate? firstDate,
    EthiopianDate? lastDate,
  }) {
    if (firstDate != null && date.isBefore(firstDate)) return firstDate;
    if (lastDate != null && date.isAfter(lastDate)) return lastDate;
    return date;
  }
}
