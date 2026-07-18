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
/// [theme.selectedColor] rather than left at the ambient default.
///
/// Range highlighting (Task 4.2): [isRangeStart], [isRangeEnd], and
/// [isInRange] are independent of [isSelected] - a cell used in range
/// mode passes `isSelected: false` and drives its appearance entirely
/// through the range flags instead, so the two selection concepts
/// never fight over how a cell looks. A day that is both the range
/// start and end (a single-day range) renders exactly like a plain
/// single-date selection, with no tinted band on either side.
class EthiopianDayCell extends StatelessWidget {
  const EthiopianDayCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.onTap,
    this.theme,
    this.isRangeStart = false,
    this.isRangeEnd = false,
    this.isInRange = false,
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

  /// True if this cell is the start day of an active range selection.
  final bool isRangeStart;

  /// True if this cell is the end day of an active range selection.
  final bool isRangeEnd;

  /// True if this cell falls anywhere within an active range,
  /// inclusive of both [isRangeStart] and [isRangeEnd] days. A day
  /// can be `isInRange` without being a cap - that's what produces
  /// the continuous tinted band between the two endpoints.
  final bool isInRange;

  @override
  Widget build(BuildContext context) {
    final EthiopianDatePickerTheme resolvedTheme =
        theme ?? EthiopianDatePickerTheme.material3(context);

    final bool showFilledCircle = isSelected || isRangeStart || isRangeEnd;

    Color circleColor = Colors.transparent;
    Color textColor = resolvedTheme.typography.dayStyle.color ??
        Theme.of(context).colorScheme.onSurface;
    Border? border;

    if (showFilledCircle) {
      circleColor = resolvedTheme.selectedColor;
      textColor = resolvedTheme.onSelectedColor;
    } else if (isToday) {
      border = Border.all(color: resolvedTheme.todayBorderColor, width: 1.5);
      textColor = resolvedTheme.primaryColor;
    } else if (isInRange) {
      // A day strictly inside the range (not a cap) - tinted band,
      // no filled circle, but text still picks up the accent color
      // so it reads as "part of the selection" rather than a plain day.
      textColor = resolvedTheme.primaryColor;
    }

    if (isDisabled) {
      textColor = resolvedTheme.disabledColor;
    }

    // Which half (or both halves) of this cell paint the tinted band:
    // - strictly-middle day: both halves, so bands touch left/right
    //   neighbors and read as one continuous strip.
    // - range start (not also end): only the right half, so the band
    //   begins at this day and doesn't bleed into the day before it.
    // - range end (not also start): only the left half.
    // - single-day range (start == end): neither half - falls back to
    //   looking like a plain filled selection, matching Material's own
    //   date range picker behavior for a one-day range.
    final bool paintLeftBand = isInRange && !isRangeStart;
    final bool paintRightBand = isInRange && !isRangeEnd;
    final Color bandColor = resolvedTheme.selectedColor.withValues(alpha: 0.12);

    return Padding(
      // Zero padding on whichever side(s) paint a band, so adjacent
      // cells' bands touch edge-to-edge instead of leaving a visible
      // gap - this is what makes the highlight read as one continuous
      // strip across a row rather than a row of separate tinted dots.
      padding: EdgeInsets.only(
        top: resolvedTheme.spacing.xs / 2,
        bottom: resolvedTheme.spacing.xs / 2,
        left: paintLeftBand ? 0 : resolvedTheme.spacing.xs / 2,
        right: paintRightBand ? 0 : resolvedTheme.spacing.xs / 2,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isInRange)
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: paintLeftBand ? bandColor : Colors.transparent,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: paintRightBand ? bandColor : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              splashColor: resolvedTheme.selectedColor.withValues(alpha: 0.24),
              highlightColor:
                  resolvedTheme.selectedColor.withValues(alpha: 0.12),
              child: Container(
                decoration: BoxDecoration(
                  color: circleColor,
                  border: border,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: resolvedTheme.typography.dayStyle.copyWith(
                    color: textColor,
                    fontWeight: showFilledCircle || isToday
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
