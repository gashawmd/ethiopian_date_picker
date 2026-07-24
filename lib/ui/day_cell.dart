import 'package:flutter/material.dart';

import '../theme/picker_theme.dart';

const double _kMinTapTarget = 48.0;

/// A single tappable day cell in an [EthiopianCalendarView] grid.
///
/// Renders as a circular tap target at least 48px in size, with
/// visual states for selected, today, disabled, and range
/// start/end/middle. Most users won't construct this directly — it's
/// built internally by [EthiopianCalendarView].
class EthiopianDayCell extends StatefulWidget {
  /// Creates a day cell for the given [day] number and visual state.
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

  /// The day-of-month number displayed in the cell.
  final int day;

  /// Whether this cell represents the single currently-selected date.
  final bool isSelected;

  /// Whether this cell represents today's date.
  final bool isToday;

  /// Whether this cell falls outside the selectable range and cannot
  /// be tapped.
  final bool isDisabled;

  /// Called when the cell is tapped, unless [isDisabled] is true.
  final VoidCallback? onTap;

  /// The spoken accessibility label announced by screen readers.
  final String semanticLabel;

  /// Optional visual theme. Falls back to
  /// [EthiopianDatePickerTheme.material3] when unset.
  final EthiopianDatePickerTheme? theme;

  /// Whether this cell is the first day of a selected range.
  final bool isRangeStart;

  /// Whether this cell is the last day of a selected range.
  final bool isRangeEnd;

  /// Whether this cell falls within (but is not the endpoint of) a
  /// selected range.
  final bool isInRange;

  /// Whether this cell should request focus automatically when built.
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

    final Border? effectiveBorder = _isFocused
        ? Border.all(color: resolvedTheme.primaryColor, width: 2)
        : border;

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
