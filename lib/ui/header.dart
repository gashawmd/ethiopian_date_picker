import 'package:flutter/material.dart';

import '../localization/ethiopian_locale.dart';
import '../theme/picker_theme.dart';

/// Header row showing "Month Year" with previous/next navigation arrows.
class EthiopianCalendarHeader extends StatelessWidget {
  const EthiopianCalendarHeader({
    super.key,
    required this.year,
    required this.month,
    required this.theme,
    required this.locale,
    required this.onPrevious,
    required this.onNext,
    this.onTapTitle,
  });

  final int year;
  final int month;
  final EthiopianDatePickerTheme theme;
  final EthiopianLocaleData locale;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onTapTitle;

  @override
  Widget build(BuildContext context) {
    final monthName = locale.monthNames[month - 1];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(theme.borderRadius),
          topRight: Radius.circular(theme.borderRadius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: theme.headerTextColor),
            tooltip: 'Previous month',
            onPressed: onPrevious,
          ),
          Expanded(
            child: InkWell(
              onTap: onTapTitle,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '$monthName $year',
                  textAlign: TextAlign.center,
                  style: theme.headerTextStyle.copyWith(
                    color: theme.headerTextColor,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: theme.headerTextColor),
            tooltip: 'Next month',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
