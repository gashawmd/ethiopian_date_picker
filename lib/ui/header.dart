import 'package:flutter/material.dart';

import '../localization/ethiopian_locale.dart';
import '../theme/picker_theme.dart';

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
  final String? locale;
  final EthiopianDatePickerTheme? theme;
  static const BoxConstraints _navButtonConstraints =
      BoxConstraints(minWidth: 48, minHeight: 48);
  static Set<String> get supportedLocales =>
      supportedEthiopianLocaleCodes.toSet();
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
