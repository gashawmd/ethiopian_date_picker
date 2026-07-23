import 'am.dart';
import 'en.dart';
import 'om.dart';
import 'ti.dart';

const int ethiopianMonthCount = 13;
const int weekCount = 7;

enum EthiopianLocale {
  english('en'),
  amharic('am'),
  oromo('om'),
  tigrinya('ti');

  const EthiopianLocale(this.code);
  final String code;

  static EthiopianLocale? fromCode(String? code) {
    for (final EthiopianLocale locale in values) {
      if (locale.code == code) return locale;
    }
    return null;
  }
}

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

  final String languageCode;
  final List<String> monthNames;

  final List<String> weekdayNamesShort;

  final String okLabel;
  final String cancelLabel;
  final String previousMonthTooltip;
  final String nextMonthTooltip;
  final String todayLabel;
}

final Map<String, EthiopianLocaleData> _localeDataRegistry = {
  EthiopianLocale.english.code: enLocaleData,
  EthiopianLocale.amharic.code: amLocaleData,
  EthiopianLocale.oromo.code: omLocaleData,
  EthiopianLocale.tigrinya.code: tiLocaleData,
};

List<String> get supportedEthiopianLocaleCodes =>
    List.unmodifiable(_localeDataRegistry.keys);

EthiopianLocaleData resolveEthiopianLocaleData(String? code) {
  return _localeDataRegistry[code] ?? enLocaleData;
}
