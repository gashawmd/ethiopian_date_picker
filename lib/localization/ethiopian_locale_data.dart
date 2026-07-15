/// Text bundle for the Ethiopian date picker in a single language.
///
/// To add a new language, create a file in `lib/localization/` (e.g.
/// `tigrinya.dart`) that exports a `const EthiopianLocaleData` following
/// the pattern in `en.dart` and `am.dart`, then reference it wherever you
/// pass a `locale:` argument — no changes to the package internals needed.
class EthiopianLocaleData {
  const EthiopianLocaleData({
    required this.monthNames,
    required this.weekdayShortNames,
    required this.today,
    required this.ok,
    required this.cancel,
  });

  /// 13 month names, in order. Access via `monthNames[month - 1]`.
  final List<String> monthNames;

  /// 7 short weekday labels, Monday first: [Mon, Tue, Wed, Thu, Fri, Sat, Sun].
  final List<String> weekdayShortNames;

  final String today;
  final String ok;
  final String cancel;
}
