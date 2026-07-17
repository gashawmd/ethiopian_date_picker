import 'package:flutter/material.dart';

/// A single day cell within the Ethiopian calendar grid.
///
/// Mirrors Material's own date picker day styling: a filled circle for
/// the selected day, an outlined circle for today, and dimmed,
/// non-interactive text for out-of-range days.
class EthiopianDayCell extends StatelessWidget {
  const EthiopianDayCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;

  /// Null when the day is disabled — used both to style and to prevent
  /// taps, so there's exactly one source of truth for "is this tappable".
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    Color backgroundColor = Colors.transparent;
    Color textColor = colors.onSurface;
    Border? border;

    if (isSelected) {
      backgroundColor = colors.primary;
      textColor = colors.onPrimary;
    } else if (isToday) {
      border = Border.all(color: colors.primary, width: 1.5);
      textColor = colors.primary;
    }

    if (isDisabled) {
      textColor = colors.onSurface.withValues(alpha: 0.38);
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: border,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
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
