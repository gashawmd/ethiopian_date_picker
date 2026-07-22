import 'ethiopian_locale.dart';

/// Afaan Oromo localization data for the Ethiopian calendar.
///
/// Month and weekday names follow commonly used Afaan Oromo calendar
/// terminology. The 13th month (Pagume) may vary between sources;
/// `Qaammee` is used here and may require native-speaker validation.
final EthiopianLocaleData omLocaleData = EthiopianLocaleData(
  languageCode: 'om',
  monthNames: [
    'Fulbaana',
    'Onkoloolessa',
    'Sadaasa',
    'Mudde',
    'Amajjii',
    'Guraandhala',
    'Bitootessa',
    'Ebla',
    'Caamsaa',
    'Waxabajjii',
    'Adoolessa',
    'Hagayya',
    'Qaammee',
  ],
  weekdayNamesShort: [
    'Wiix',
    'Kibx',
    'Roob',
    'Kami',
    'Jima',
    'Sanb',
    'Dilb',
  ],
  okLabel: 'Tole',
  cancelLabel: 'Dhiisi',
  previousMonthTooltip: 'Ji’a darbe',
  nextMonthTooltip: 'Ji’a itti aanu',
  todayLabel: 'Har’a',
);
