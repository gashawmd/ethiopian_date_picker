import 'package:flutter/material.dart';

import '../localization/ethiopian_locale.dart';
import '../theme/picker_theme.dart';

/// A header widget displaying the current month/year title and navigation
/// controls for moving between months in an Ethiopian calendar.
class EthiopianCalendarHeader extends StatelessWidget {
  /// Creates a calendar header for the specified [year] and [month].
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

  /// The Ethiopian year currently displayed in the header.
  final int year;

  /// The 1-based index of the Ethiopian month (1–13) currently displayed.
  final int month;

  /// Callback fired when the user taps the previous month navigation button.
  final VoidCallback onPreviousMonth;

  /// Callback fired when the user taps the next month navigation button.
  final VoidCallback onNextMonth;

  /// Whether navigating to the previous month is enabled.
  final bool canGoPrevious;

  /// Whether navigating to the next month is enabled.
  final bool canGoNext;

  /// Locale code used for month and tooltip localization.
  final String? locale;

  /// Optional visual theme overrides for header colors and typography.
  final EthiopianDatePickerTheme? theme;

  static const BoxConstraints _navButtonConstraints =
      BoxConstraints(minWidth: 48, minHeight: 48);

  /// Returns the set of supported locale codes for this header component.
  static Set<String> get supportedLocales =>
      supportedEthiopianLocaleCodes.toSet();

  /// Resolves a given [locale] code to a valid language code, falling back
  /// to the default if unsupported or null.
  static String resolveLocale(String? locale) =>
      resolveEthiopianLocaleData(locale).languageCode;

  @override
  Widget build(BuildContext context) {
    final EthiopianDatePickerTheme resolvedTheme =
        theme ?? EthiopianDatePickerTheme.material3(context);
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
