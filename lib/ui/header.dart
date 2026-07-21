import 'package:flutter/material.dart';

import '../localization/ethiopian_locale.dart';
import '../theme/picker_theme.dart';

/// Month/year label with previous/next navigation arrows, styled to
/// match Material's built-in date picker header. Colors and text style
/// come from [theme]; omit it to fall back to
/// [EthiopianDatePickerTheme.material3]. Month name and navigation
/// tooltips come from [locale]'s translation data (Task 5.1); omit it
/// to fall back to English.
///
/// Accessibility (Task 5.3): both nav [IconButton]s are given an
/// explicit 48x48 minimum constraint - Material's own default for
/// `IconButton` is 40px, below the WCAG 2.5.5 / Material minimum tap
/// target size.
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
    this.theme,
  });

  final int year;
  final int month;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final bool canGoPrevious;
  final bool canGoNext;

  /// Optional locale code (e.g. `'am'`). Any code without translation
  /// data - including `null` - silently falls back to English rather
  /// than throwing or showing a missing-key error.
  final String? locale;

  /// Optional visual theme. Falls back to
  /// [EthiopianDatePickerTheme.material3] when omitted.
  final EthiopianDatePickerTheme? theme;

  /// Minimum tap target for the nav arrows, per WCAG 2.5.5 / Material
  /// accessibility guidance.
  static const BoxConstraints _navButtonConstraints =
      BoxConstraints(minWidth: 48, minHeight: 48);

  /// Locale codes with real translation data today. Kept as a public
  /// static member for backward compatibility with earlier phases;
  /// delegates to the localization registry (Task 5.1) rather than
  /// hardcoding a set here.
  static Set<String> get supportedLocales =>
      supportedEthiopianLocaleCodes.toSet();

  /// Resolves an arbitrary/possibly-invalid locale code to one this
  /// package actually has data for, defaulting safely to English.
  static String resolveLocale(String? locale) =>
      resolveEthiopianLocaleData(locale).languageCode;

  @override
  Widget build(BuildContext context) {
    final EthiopianDatePickerTheme resolvedTheme =
        theme ?? EthiopianDatePickerTheme.material3(context);

    // resolveEthiopianLocaleData() never throws and never returns a
    // partial result, regardless of what's passed in - this is what
    // makes an invalid/missing locale a non-issue rather than a crash
    // or a missing-key fallback error.
    final EthiopianLocaleData localeData = resolveEthiopianLocaleData(locale);
    final String monthName = localeData.monthNames[month - 1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          color: resolvedTheme.primaryColor,
          onPressed: canGoPrevious ? onPreviousMonth : null,
          tooltip: localeData.previousMonthTooltip,
          constraints: _navButtonConstraints,
        ),
        // Expanded + ellipsis/scaling means an unusually large custom
        // headerStyle, or a long localized month name, shrinks or
        // truncates gracefully instead of overflowing the fixed-width
        // header row.
        Expanded(
          child: Text(
            '$monthName $year',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: resolvedTheme.typography.headerStyle,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          color: resolvedTheme.primaryColor,
          onPressed: canGoNext ? onNextMonth : null,
          tooltip: localeData.nextMonthTooltip,
          constraints: _navButtonConstraints,
        ),
      ],
    );
  }
}
