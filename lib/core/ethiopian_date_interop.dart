import 'ethiopian_date.dart';

/// Adds Ethiopian-calendar conversion directly onto `DateTime`, so callers
/// working with plain Gregorian dates don't have to reach for
/// `EthiopianDate.fromGregorian(...)` explicitly.
extension EthiopianDateTimeX on DateTime {
  /// This `DateTime`, expressed as an [EthiopianDate]. Time-of-day is
  /// ignored — only year/month/day are converted.
  EthiopianDate toEthiopianDate() => EthiopianDate.fromGregorian(this);
}

/// Formatting for [EthiopianDate].
///
/// Deliberately dependency-free (no `intl`) at this layer — Phase 1 is
/// pure Dart with no external packages. Supported pattern tokens:
///
/// | Token  | Meaning                          | Example |
/// |--------|-----------------------------------|---------|
/// | `yyyy` | 4-digit year, zero-padded         | `2018`  |
/// | `yy`   | 2-digit year                      | `18`    |
/// | `MM`   | 2-digit month, zero-padded         | `03`    |
/// | `M`    | month, no padding                 | `3`     |
/// | `dd`   | 2-digit day, zero-padded           | `07`    |
/// | `d`    | day, no padding                   | `7`     |
///
/// Month/weekday *names* (Amharic/English) are intentionally left to the
/// localization layer (Task 1.4 hands off to Phase 1's `localization/`
/// work), since names depend on locale and this formatter doesn't.
extension EthiopianDateFormatting on EthiopianDate {
  /// Formats this date using [pattern] (default `'yyyy-MM-dd'`, matching
  /// [EthiopianDate.toString]).
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