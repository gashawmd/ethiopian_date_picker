import 'package:flutter/material.dart';

import '../theme/picker_theme.dart';

/// A single tappable day cell inside the calendar grid.
class EthiopianDayCell extends StatelessWidget {
  const EthiopianDayCell({
    super.key,
    required this.day,
    required this.theme,
    this.isSelected = false,
    this.isToday = false,
    this.isInRange = false,
    this.isRangeEdge = false,
    this.isDisabled = false,
    this.onTap,
  });

  final int day;
  final EthiopianDatePickerTheme theme;
  final bool isSelected;
  final bool isToday;
  final bool isInRange;
  final bool isRangeEdge;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color background = Colors.transparent;
    Color textColor = theme.dayTextColor;
    Border? border;

    if (isSelected || isRangeEdge) {
      background = theme.selectedColor;
      textColor = Colors.white;
    } else if (isInRange) {
      background = theme.selectedColor.withValues(alpha: 0.15);
      textColor = theme.dayTextColor;
    } else if (isToday) {
      border = Border.all(color: theme.todayColor, width: 1.5);
      textColor = theme.todayColor;
    }

    if (isDisabled) {
      textColor = theme.disabledColor;
    }

    return Semantics(
      label: 'Day $day',
      selected: isSelected,
      button: true,
      enabled: !isDisabled,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            borderRadius: BorderRadius.circular(theme.cellBorderRadius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(theme.cellBorderRadius),
                border: border,
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: theme.dayTextStyle.copyWith(color: textColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
