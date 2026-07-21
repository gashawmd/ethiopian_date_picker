import 'package:flutter/material.dart';

import '../theme/picker_theme.dart';

/// Minimum tap target size per WCAG 2.5.5 / Material accessibility
/// guidance. Applied to the cell's hit area regardless of the visual
/// circle's own diameter, so a compact theme never shrinks the actual
/// tappable/focusable region below 48x48.
const double _kMinTapTarget = 48.0;

/// A single day cell within the Ethiopian calendar grid.
///
/// Mirrors Material's own date picker day styling: a filled circle for
/// the selected day, an outlined circle for today, and dimmed,
/// non-interactive text for out-of-range days. All colors and text
/// styles come from [theme]; pass one explicitly to override the
/// default look, or omit it to fall back to
/// [EthiopianDatePickerTheme.material3].
///
/// Accessibility (Task 5.3):
/// - [semanticLabel] is spoken by screen readers in place of the bare
///   visual day number; it's built by the caller
///   ([EthiopianCalendarView]) since only that widget knows the
///   weekday/month/year/today-ness of the cell.
/// - The tappable/focusable region is a fixed [_kMinTapTarget] square
///   regardless of the visual circle's size.
/// - A focused cell gets a visible stroked ring, not just a color
///   change, so it's identifiable without relying on color perception.
/// - [autofocus] lets the caller land initial keyboard/screen-reader
///   focus on a specific cell (selected day, today, or first
///   selectable day) when the grid first appears.
///
/// Range highlighting (Task 4.2): [isRangeStart], [isRangeEnd], and
/// [isInRange] are independent of [isSelected] - a cell used in range
/// mode passes `isSelected: false` and drives its appearance entirely
/// through the range flags instead.
class EthiopianDayCell extends StatefulWidget {
  const EthiopianDayCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.onTap,
    required this.semanticLabel,
    this.theme,
    this.isRangeStart = false,
    this.isRangeEnd = false,
    this.isInRange = false,
    this.autofocus = false,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;

  /// Null when the day is disabled — used both to style and to prevent
  /// taps, so there's exactly one source of truth for "is this tappable".
  final VoidCallback? onTap;

  /// Full spoken label for this day (e.g. "Monday, Meskerem 5, 2018,
  /// Today"). Replaces the bare digit a screen reader would otherwise
  /// read from the visible [Text].
  final String semanticLabel;

  /// Optional visual theme. Falls back to
  /// [EthiopianDatePickerTheme.material3] when omitted.
  final EthiopianDatePickerTheme? theme;

  final bool isRangeStart;
  final bool isRangeEnd;
  final bool isInRange;

  /// Whether this cell should request focus as soon as it's built.
  /// At most one cell in a given grid should set this to true.
  final bool autofocus;

  @override
  State<EthiopianDayCell> createState() => _EthiopianDayCellState();
}

class _EthiopianDayCellState extends State<EthiopianDayCell> {
  bool _isFocused = false;

  void _handleFocusChange(bool focused) {
    if (focused != _isFocused) {
      setState(() => _isFocused = focused);
    }
  }

  @override
  Widget build(BuildContext context) {
    final EthiopianDatePickerTheme resolvedTheme =
        widget.theme ?? EthiopianDatePickerTheme.material3(context);

    final bool showFilledCircle =
        widget.isSelected || widget.isRangeStart || widget.isRangeEnd;

    Color circleColor = Colors.transparent;
    Color textColor = resolvedTheme.typography.dayStyle.color ??
        Theme.of(context).colorScheme.onSurface;
    Border? border;

    if (showFilledCircle) {
      circleColor = resolvedTheme.selectedColor;
      textColor = resolvedTheme.onSelectedColor;
    } else if (widget.isToday) {
      border = Border.all(color: resolvedTheme.todayBorderColor, width: 1.5);
      textColor = resolvedTheme.primaryColor;
    } else if (widget.isInRange) {
      textColor = resolvedTheme.primaryColor;
    }

    if (widget.isDisabled) {
      textColor = resolvedTheme.disabledColor;
    }

    final bool paintLeftBand = widget.isInRange && !widget.isRangeStart;
    final bool paintRightBand = widget.isInRange && !widget.isRangeEnd;
    final Color bandColor = resolvedTheme.selectedColor.withValues(alpha: 0.12);

    // Focus ring takes priority over the "today" outline when both
    // would apply - a focused cell is always visibly identifiable,
    // even if that means today's own outline is briefly superseded
    // while focus sits on it.
    final Border? effectiveBorder = _isFocused
        ? Border.all(color: resolvedTheme.primaryColor, width: 2)
        : border;

    // Cap text scaling within the fixed-size circle so an extreme
    // system font-scale setting can't overflow the 48px cell - while
    // still allowing meaningful growth for low-vision users.
    final TextScaler clampedScaler =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);

    return Padding(
      padding: EdgeInsets.only(
        top: resolvedTheme.spacing.xs / 2,
        bottom: resolvedTheme.spacing.xs / 2,
        left: paintLeftBand ? 0 : resolvedTheme.spacing.xs / 2,
        right: paintRightBand ? 0 : resolvedTheme.spacing.xs / 2,
      ),
      child: Semantics(
        label: widget.semanticLabel,
        button: true,
        enabled: !widget.isDisabled,
        selected: widget.isSelected || widget.isRangeStart || widget.isRangeEnd,
        excludeSemantics: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isInRange)
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
            SizedBox(
              width: _kMinTapTarget,
              height: _kMinTapTarget,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: widget.onTap,
                  onFocusChange: _handleFocusChange,
                  autofocus: widget.autofocus,
                  customBorder: const CircleBorder(),
                  splashColor:
                      resolvedTheme.selectedColor.withValues(alpha: 0.24),
                  highlightColor:
                      resolvedTheme.selectedColor.withValues(alpha: 0.12),
                  // The ring is drawn explicitly below, so the default
                  // color-wash focus highlight is suppressed here.
                  focusColor: Colors.transparent,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: circleColor,
                        border: effectiveBorder,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: clampedScaler),
                        child: Text(
                          '${widget.day}',
                          style: resolvedTheme.typography.dayStyle.copyWith(
                            color: textColor,
                            fontWeight: showFilledCircle || widget.isToday
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
