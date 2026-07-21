import 'ethiopian_locale.dart';

/// Afaan Oromo translation data.
///
/// Oromo month names for the Ethiopian calendar follow the
/// conventional Gregorian-correspondence set used in Oromo-language
/// media (Fulbaana=Sept-ish, Onkoloolessa=Oct-ish, etc.), sourced from
/// published references (Horn Affairs' Oromo calendar month list) and
/// cross-checked against community sources. Confidence: reasonably
/// solid for 12 of the 13 months.
///
/// The 13th month (Pagume, the short epagomenal month) is the weakest
/// link here - it only turned up in a single, lower-quality source
/// during research, unlike the other 12 which had multiple
/// independent confirmations. **This one specifically should get a
/// native-speaker review before shipping** - treat "Qaammee" as a
/// placeholder pending confirmation, not a verified translation like
/// the rest of this file.
///
/// Weekday names are sourced from a dedicated Oromo weekday reference
/// and are on firmer footing than the 13th month.
///
/// `okLabel`/`cancelLabel` are best-effort common Oromo UI terms, not
/// independently sourced - flag for native-speaker review same as the
/// other locales.
final EthiopianLocaleData omLocaleData = EthiopianLocaleData(
  languageCode: 'om',
  monthNames: [
    'Fulbaana', // Meskerem
    'Onkoloolessa', // Tikimt
    'Sadaasa', // Hidar
    'Mudde', // Tahsas
    'Amajjii', // Tir
    'Guraandhala', // Yekatit
    'Bitootessa', // Megabit
    'Ebla', // Miazia
    'Caamsaa', // Ginbot
    'Waxabajjii', // Sene
    'Adoolessa', // Hamle
    'Hagayya', // Nehase
    'Qaammee', // Pagume - lowest-confidence entry, see note above
  ],
  weekdayNamesShort: [
    'Wiix', // Wiixata (Monday)
    'Qibx', // Qibxata (Tuesday)
    'Roob', // Roobii (Wednesday)
    'Kami', // Kamiisa (Thursday)
    'Jima', // Jimaata (Friday)
    'Sanb', // Sanbata (Saturday)
    'Dilb', // Dilbata (Sunday)
  ],
  okLabel: 'Tole',
  cancelLabel: 'Dhiisi',
  previousMonthTooltip: 'Ji\'a darbe',
  nextMonthTooltip: 'Ji\'a itti aanu',
  todayLabel: 'Har\'a',
);
