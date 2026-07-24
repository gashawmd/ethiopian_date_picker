import 'am.dart';
import 'en.dart';
import 'om.dart';
import 'ti.dart';

/// The number of months in the Ethiopian calendar, including Pagume.
const int ethiopianMonthCount = 13;

/// The number of days in a week.
const int weekCount = 7;

/// A locale supported by the Ethiopian date picker's UI text.
///
/// Pass a locale's [code] (e.g. `'am'`) to picker functions and
/// widgets. Unsupported or missing codes fall back to English.
enum EthiopianLocale {
  /// English.
  english('en'),

  /// Amharic (አማርኛ).
  amharic('am'),

  /// Afaan Oromo.
  oromo('om'),

  /// Tigrinya (ትግርኛ).
  tigrinya('ti');

  const EthiopianLocale(this.code);

  /// The ISO-style locale code passed to picker functions, e.g. `'am'`.
  final String code;

  /// Looks up the [EthiopianLocale] matching [code], or `null` if no
  /// locale with that code is supported.
  static EthiopianLocale? fromCode(String? code) {
    for (final EthiopianLocale locale in values) {
      if (locale.code == code) return locale;
    }
    return null;
  }
}

/// The translated strings and month/weekday names for a single locale.
class EthiopianLocaleData {
  /// Creates a locale data set. [monthNames] must have exactly
  /// [ethiopianMonthCount] entries and [weekdayNamesShort] must have
  /// exactly [weekCount] entries.
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

  /// The ISO-style language code this data set is for, e.g. `'am'`.
  final String languageCode;

  /// Full Ethiopian month names, Meskerem through Pagume (13 entries).
  final List<String> monthNames;

  /// Short weekday labels, Monday through Sunday (7 entries).
  final List<String> weekdayNamesShort;

  /// Localized label for the picker's confirm button.
  final String okLabel;

  /// Localized label for the picker's cancel button.
  final String cancelLabel;

  /// Localized tooltip for the "previous month" navigation control.
  final String previousMonthTooltip;

  /// Localized tooltip for the "next month" navigation control.
  final String nextMonthTooltip;

  /// Localized label used to mark today's date.
  final String todayLabel;
}

final Map<String, EthiopianLocaleData> _localeDataRegistry = {
  EthiopianLocale.english.code: enLocaleData,
  EthiopianLocale.amharic.code: amLocaleData,
  EthiopianLocale.oromo.code: omLocaleData,
  EthiopianLocale.tigrinya.code: tiLocaleData,
};

/// The locale codes currently supported by the picker, e.g.
/// `['en', 'am', 'om', 'ti']`.
List<String> get supportedEthiopianLocaleCodes =>
    List.unmodifiable(_localeDataRegistry.keys);

/// Resolves [code] to its [EthiopianLocaleData], falling back to
/// English if [code] is `null` or unsupported.
EthiopianLocaleData resolveEthiopianLocaleData(String? code) {
  return _localeDataRegistry[code] ?? enLocaleData;
}
