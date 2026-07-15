import 'am.dart';
import 'en.dart';
import 'ethiopian_locale_data.dart';

export 'ethiopian_locale_data.dart' show EthiopianLocaleData;

/// Built-in locales shipped with the package.
///
/// `EthiopianLocale.english` is the default fallback used throughout the
/// package. Add more languages by creating your own `EthiopianLocaleData`
/// (see `en.dart` / `am.dart` for the pattern) and passing it directly to
/// `locale:` — you don't need to touch this class to support a language
/// that isn't listed here.
class EthiopianLocale {
  const EthiopianLocale._();

  static const EthiopianLocaleData english = ethiopianLocaleEn;
  static const EthiopianLocaleData amharic = ethiopianLocaleAm;
}
