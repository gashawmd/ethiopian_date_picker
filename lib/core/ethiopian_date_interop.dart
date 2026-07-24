import 'ethiopian_date.dart';

/// Converts a [DateTime] to the Ethiopian calendar.
extension EthiopianDateTimeX on DateTime {
  /// Equivalent to `EthiopianDate.fromGregorian(this)`.
  EthiopianDate toEthiopianDate() => EthiopianDate.fromGregorian(this);
}

/// Formatting helpers for [EthiopianDate].
extension EthiopianDateFormatting on EthiopianDate {
  /// Formats this date using [pattern], where `yyyy`/`yy`, `MM`/`M`,
  /// and `dd`/`d` are replaced with the zero-padded (or unpadded)
  /// year, month, and day. Defaults to `'yyyy-MM-dd'`.
  String format([String pattern = 'yyyy-MM-dd']) {
    final String yyyy = year.toString().padLeft(4, '0');
    final String yy = yyyy.substring(yyyy.length - 2);
    final String mm = month.toString().padLeft(2, '0');
    final String dd = day.toString().padLeft(2, '0');

    return pattern
        .replaceAll('yyyy', yyyy)
        .replaceAll('yy', yy)
        .replaceAll('MM', mm)
        .replaceAll('M', month.toString())
        .replaceAll('dd', dd)
        .replaceAll('d', day.toString());
  }
}
