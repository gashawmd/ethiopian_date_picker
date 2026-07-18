import 'package:flutter/material.dart';

import '../theme/picker_theme.dart';

/// A single day cell within the Ethiopian calendar grid.
///
/// Mirrors Material's own date picker day styling: a filled circle for
/// the selected day, an outlined circle for today, and dimmed,
/// non-interactive text for out-of-range days. All colors and text
/// styles come from [theme]; pass one explicitly to override the
/// default look, or omit it to fall back to
/// [EthiopianDatePickerTheme.material3].
///
/// The [InkWell] wrapping each cell provides Material's standard
/// ripple on tap (Task 4.1); its splash/highlight colors are tied to
/// [theme.selectedColor] rather than left at the ambient default, so a
/// themed picker's ripple actually matches its own palette instead of
/// whatever color happens to be ambient in the surrounding app.
class EthiopianDayCell extends StatelessWidget {
  const EthiopianDayCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.onTap,
    this.theme,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;

  /// Null when the day is disabled — used both to style and to prevent
  /// taps, so there's exactly one source of truth for "is this tappable".
  final VoidCallback? onTap;

  /// Optional visual theme. Falls back to
  /// [EthiopianDatePickerTheme.material3] when omitted.
  final EthiopianDatePickerTheme? theme;

  @override
  Widget build(BuildContext context) {
    final EthiopianDatePickerTheme resolvedTheme =
        theme ?? EthiopianDatePickerTheme.material3(context);

    Color backgroundColor = Colors.transparent;
    Color textColor = resolvedTheme.typography.dayStyle.color ??
        Theme.of(context).colorScheme.onSurface;
    Border? border;

    if (isSelected) {
      backgroundColor = resolvedTheme.selectedColor;
      textColor = resolvedTheme.onSelectedColor;
    } else if (isToday) {
      border = Border.all(color: resolvedTheme.todayBorderColor, width: 1.5);
      textColor = resolvedTheme.primaryColor;
    }

    if (isDisabled) {
      textColor = resolvedTheme.disabledColor;
    }

    return Padding(
      padding: EdgeInsets.all(resolvedTheme.spacing.xs / 2),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          splashColor: resolvedTheme.selectedColor.withValues(alpha: 0.24),
          highlightColor: resolvedTheme.selectedColor.withValues(alpha: 0.12),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: border,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: resolvedTheme.typography.dayStyle.copyWith(
                color: textColor,
                fontWeight:
                    isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}