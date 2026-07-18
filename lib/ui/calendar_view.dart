import 'package:flutter/material.dart';

import '../core/ethiopian_date.dart';
import '../core/ethiopian_date_range.dart';
import '../theme/picker_theme.dart';
import '../utils/date_utils.dart';
import 'day_cell.dart';
import 'header.dart';

/// Renders a single Ethiopian month as a 7-column grid, with a weekday
/// header row and a navigable month/year header above it.
///
/// Stateless and fully controlled: the caller owns [displayedMonth]
/// (which year/month is currently shown) and either [selectedDate] or
/// [selectedRange], and reacts to [onDateSelected] / [onMonthChanged].
/// A tap always calls [onDateSelected] with the tapped date regardless
/// of which mode is active - this widget does not implement the
/// "tap start, tap end, re-tap to reset" state machine itself (Task
/// 4.2's interaction flow); that logic belongs to whatever holds the
/// state and decides what a given tap means. This widget's only job is
/// rendering whatever selection it's told about.
///
/// Rendered at a fixed intrinsic width (matching the footprint of
/// Material's own date picker) so it behaves predictably regardless of
/// how much space its parent offers - without this, an unconstrained
/// parent causes the grid to stretch to fill available width, producing
/// oversized cells and vertical overflow.
///
/// Resolves [theme] once via [EthiopianDatePickerTheme.material3] when
/// omitted, then passes that single resolved instance down to every
/// child cell and the header, so the whole grid stays visually
/// consistent even though each child could theoretically resolve its
/// own default independently.
///
/// The day grid cross-fades and slides slightly when [displayedMonth]
/// changes (Task 4.1), keyed on year/month so Flutter treats each
/// month as a distinct subtree rather than patching cell-by-cell.
class EthiopianCalendarView extends StatelessWidget {
  const EthiopianCalendarView({
    super.key,
    required this.displayedMonth,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
    required this.onMonthChanged,
    this.selectedDate,
    this.selectedRange,
    this.locale,
    this.theme,
  });

  /// Any date within the month currently being displayed. Only its
  /// year/month are read; the day is ignored.
  final EthiopianDate displayedMonth;

  /// The earliest selectable date (inclusive).
  final EthiopianDate firstDate;

  /// The latest selectable date (inclusive).
  final EthiopianDate lastDate;

  /// The currently selected date in single-date mode. Ignored whenever
  /// [selectedRange] is non-null - the two are mutually exclusive, and
  /// range mode always takes priority when both happen to be set.
  final EthiopianDate? selectedDate;

  /// The currently selected range, if range mode is active. When set,
  /// each day cell renders as a range start/end cap or an in-between
  /// band day rather than a plain single selection (Task 4.2).
  final EthiopianDateRange? selectedRange;

  /// Called when the user taps a selectable day.
  final ValueChanged<EthiopianDate> onDateSelected;

  /// Called with the new displayed month when the user taps the
  /// previous/next arrows in the header.
  final ValueChanged<EthiopianDate> onMonthChanged;

  /// Optional locale code, forwarded to [EthiopianCalendarHeader]. See
  /// [EthiopianCalendarHeader.resolveLocale] for fallback behavior.
  final String? locale;

  /// Optional visual theme. Falls back to
  /// [EthiopianDatePickerTheme.material3] when omitted.
  final EthiopianDatePickerTheme? theme;

  /// Fixed width for the whole widget, matching Material's own date
  /// picker footprint. 7 columns at ~46px each plus minor padding.
  static const double _width = 328;

  /// Duration for the month-change slide/fade. Kept short (well under
  /// the ~300ms threshold where a transition starts to feel laggy
  /// rather than snappy) so rapid next/next/next taps don't queue up
  /// a visibly sluggish backlog of animations.
  static const Duration _monthTransitionDuration = Duration(milliseconds: 220);

  static const List<String> _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final EthiopianDatePickerTheme resolvedTheme =
        theme ?? EthiopianDatePickerTheme.material3(context);

    final int year = displayedMonth.year;
    final int month = displayedMonth.month;
    final int daysInMonth = EthiopianDateUtils.daysInMonth(year, month);
    final int leadingBlanks =
        EthiopianDateUtils.firstWeekdayOfMonth(year, month) - 1;

    final EthiopianDate today = EthiopianDate.today();
    final EthiopianDate previousMonth = _shiftMonth(year, month, -1);
    final EthiopianDate nextMonth = _shiftMonth(year, month, 1);
    final EthiopianDate previousMonthLastDay = EthiopianDate(
      previousMonth.year,
      previousMonth.month,
      EthiopianDateUtils.daysInMonth(previousMonth.year, previousMonth.month),
    );

    return Container(
      width: _width,
      color: resolvedTheme.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EthiopianCalendarHeader(
            year: year,
            month: month,
            locale: locale,
            theme: resolvedTheme,
            onPreviousMonth: () => onMonthChanged(previousMonth),
            onNextMonth: () => onMonthChanged(nextMonth),
            canGoPrevious: !previousMonthLastDay.isBefore(firstDate),
            canGoNext: !nextMonth.isAfter(lastDate),
          ),
          SizedBox(height: resolvedTheme.spacing.sm),
          Row(
            children: _weekdayLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: resolvedTheme.typography.weekdayLabelStyle,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: resolvedTheme.spacing.xs),
          AnimatedSwitcher(
            duration: _monthTransitionDuration,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              final Animation<Offset> slide = Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: GridView.count(
              key: ValueKey<String>('$year-$month'),
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.0,
              children: [
                for (int i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
                for (int day = 1; day <= daysInMonth; day++)
                  _buildDayCell(year, month, day, today, resolvedTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    int year,
    int month,
    int day,
    EthiopianDate today,
    EthiopianDatePickerTheme resolvedTheme,
  ) {
    final EthiopianDate date = EthiopianDate(year, month, day);
    final bool isDisabled = date.isBefore(firstDate) || date.isAfter(lastDate);
    final bool isToday = date == today;

    // Range mode takes priority over single-date mode whenever both
    // happen to be set - selectedDate is only consulted when
    // selectedRange is null, so the two never fight over a cell.
    final bool isSelected =
        selectedRange == null && selectedDate != null && date == selectedDate;

    bool isRangeStart = false;
    bool isRangeEnd = false;
    bool isInRange = false;
    final EthiopianDateRange? range = selectedRange;
    if (range != null) {
      isRangeStart = date == range.start;
      isRangeEnd = date == range.end;
      isInRange = range.contains(date);
    }

    return EthiopianDayCell(
      day: day,
      isSelected: isSelected,
      isToday: isToday,
      isDisabled: isDisabled,
      theme: resolvedTheme,
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
      isInRange: isInRange,
      onTap: isDisabled ? null : () => onDateSelected(date),
    );
  }

  /// Returns the 1st day of the month [delta] steps away from
  /// [year]/[month] (delta = -1 for previous, +1 for next).
  EthiopianDate _shiftMonth(int year, int month, int delta) {
    int newMonth = month + delta;
    int newYear = year;
    if (newMonth < 1) {
      newMonth = 13;
      newYear -= 1;
    } else if (newMonth > 13) {
      newMonth = 1;
      newYear += 1;
    }
    return EthiopianDate(newYear, newMonth, 1);
  }
}
