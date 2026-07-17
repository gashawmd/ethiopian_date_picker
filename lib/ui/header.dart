import 'package:flutter/material.dart';

/// Month/year label with previous/next navigation arrows, styled to
/// match Material's built-in date picker header.
class EthiopianCalendarHeader extends StatelessWidget {
  const EthiopianCalendarHeader({
    super.key,
    required this.year,
    required this.month,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.canGoPrevious = true,
    this.canGoNext = true,
    this.locale,
  });

  final int year;
  final int month;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final bool canGoPrevious;
  final bool canGoNext;

  /// Optional locale code (e.g. `'en'`). Any code not present in
  /// [supportedLocales] - including `null` - silently falls back to
  /// English rather than throwing. Additional locales (Amharic month
  /// names, etc.) land with the full localization layer in a later
  /// phase; this parameter exists now so callers can already pass a
  /// locale without it becoming a breaking API change later.
  final String? locale;

  /// Locale codes with real month-name data today. Kept as a set (not
  /// just "is it 'en'") so adding a second locale later is a one-line
  /// change here rather than a rewrite of the fallback logic.
  static const Set<String> supportedLocales = {'en'};

  /// Resolves an arbitrary/possibly-invalid locale code to one this
  /// widget actually has data for, defaulting safely to English.
  static String resolveLocale(String? locale) {
    if (locale == null || !supportedLocales.contains(locale)) {
      return 'en';
    }
    return locale;
  }

  static const List<String> _monthNamesEn = [
    'Meskerem',
    'Tikimt',
    'Hidar',
    'Tahsas',
    'Tir',
    'Yekatit',
    'Megabit',
    'Miazia',
    'Ginbot',
    'Sene',
    'Hamle',
    'Nehase',
    'Pagume',
  ];

  @override
  Widget build(BuildContext context) {
    // resolveLocale() never throws, regardless of what's passed in -
    // this is what makes an invalid/missing locale a non-issue rather
    // than a crash.
    final String resolved = resolveLocale(locale);
    final String monthName = switch (resolved) {
      'en' => _monthNamesEn[month - 1],
      _ => _monthNamesEn[month - 1], // only English exists today
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: canGoPrevious ? onPreviousMonth : null,
          tooltip: 'Previous month',
        ),
        Text(
          '$monthName $year',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: canGoNext ? onNextMonth : null,
          tooltip: 'Next month',
        ),
      ],
    );
  }
}
