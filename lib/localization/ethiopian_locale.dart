import 'am.dart';
import 'en.dart';
import 'om.dart';
import 'ti.dart';

/// Ethiopian calendar month order: Meskerem is month 1, Pagume is
/// month 13. All locale data below lists month names in this order.
const int ethiopianMonthCount = 13;

/// ISO weekday order used throughout this package: Monday is index 0,
/// Sunday is index 6 (matches [EthiopianDateUtils.firstWeekdayOfMonth]'s
/// 1=Mon..7=Sun convention, offset by one for zero-indexed list access).
const int weekCount = 7;

/// A supported UI language for the picker. [code] is the locale code
/// callers pass via the `locale` parameter threaded through every
/// widget in this package (e.g. `EthiopianCalendarView(locale: 'am')`).
enum EthiopianLocale {
  english('en'),
  amharic('am'),
  oromo('om'),
  tigrinya('ti');

  const EthiopianLocale(this.code);

  /// The locale code used in the public `locale` parameter API.
  final String code;

  /// Resolves a raw code to a known [EthiopianLocale], or `null` if
  /// unrecognized. Callers wanting a guaranteed non-null result should
  /// use [resolveEthiopianLocaleData] instead, which falls back to
  /// English rather than returning null.
  static EthiopianLocale? fromCode(String? code) {
    for (final EthiopianLocale locale in values) {
      if (locale.code == code) return locale;
    }
    return null;
  }
}

/// All translated strings and names needed to render the picker UI in
/// one language. Every field is required at construction, and
/// [monthNames]/[weekdayNamesShort] are length-asserted - this is what
/// makes "missing key" fallback errors structurally impossible: there
/// is no code path that reads a key that doesn't exist, because
/// there's no map of optional keys in the first place, just a fully
/// populated, validated object per locale.
class EthiopianLocaleData {
  const EthiopianLocaleData({
    required this.languageCode,
    required this.monthNames,
    required this.weekdayNamesShort,
    required this.okLabel,
    required this.cancelLabel,
    required this.previousMonthTooltip,
    required this.nextMonthTooltip,
    required this.todayLabel,
  })  : assert(
          monthNames.length == ethiopianMonthCount,
          'monthNames must have exactly $ethiopianMonthCount entries '
          '(Meskerem..Pagume), got ${monthNames.length}.',
        ),
        assert(
          weekdayNamesShort.length == weekCount,
          'weekdayNamesShort must have exactly $weekCount entries '
          '(Monday..Sunday), got ${weekdayNamesShort.length}.',
        );

  /// The locale code this data is for (e.g. `'am'`).
  final String languageCode;

  /// 13 entries, Meskerem through Pagume, in that order.
  final List<String> monthNames;

  /// 7 entries, Monday through Sunday, in that order (matching the
  /// ISO weekday convention used by [EthiopianDateUtils]).
  final List<String> weekdayNamesShort;

  final String okLabel;
  final String cancelLabel;
  final String previousMonthTooltip;
  final String nextMonthTooltip;

  /// Word for "Today", appended to a day cell's semantic label when
  /// that cell represents the current date (Task 5.3). Announced by
  /// screen readers alongside the full date, e.g. "Monday, Meskerem
  /// 5, 2016, Today".
  final String todayLabel;
}

/// Every locale this package has real translation data for. Adding a
/// new supported language is a two-step change: create its data file,
/// then add one entry here - the rest of the package (header, weekday
/// row, dialog buttons) all read through [resolveEthiopianLocaleData],
/// so nothing else needs to change.
final Map<String, EthiopianLocaleData> _localeDataRegistry = {
  EthiopianLocale.english.code: enLocaleData,
  EthiopianLocale.amharic.code: amLocaleData,
  EthiopianLocale.oromo.code: omLocaleData,
  EthiopianLocale.tigrinya.code: tiLocaleData,
};

/// Locale codes with real translation data today.
List<String> get supportedEthiopianLocaleCodes =>
    List.unmodifiable(_localeDataRegistry.keys);

/// Resolves a locale code to its full translation data, falling back
/// to English for `null` or any code without data. Never throws and
/// never returns a partially-populated result - the DoD requirement
/// "no missing-key fallback errors" holds by construction, since
/// [EthiopianLocaleData] can't exist without every field populated.
EthiopianLocaleData resolveEthiopianLocaleData(String? code) {
  return _localeDataRegistry[code] ?? enLocaleData;
}
