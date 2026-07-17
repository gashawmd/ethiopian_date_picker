import 'package:flutter/material.dart';

import '../core/ethiopian_date.dart';
import '../utils/date_utils.dart';
import 'day_cell.dart';
import 'header.dart';

/// Renders a single Ethiopian month as a 7-column grid, with a weekday
/// header row and a navigable month/year header above it.
///
/// Stateless and fully controlled: the caller owns [displayedMonth]
/// (which year/month is currently shown) and [selectedDate], and reacts
/// to [onDateSelected] / [onMonthChanged].
///
/// Rendered at a fixed intrinsic width (matching the footprint of
/// Material's own date picker) so it behaves predictably regardless of
/// how much space its parent offers - without this, an unconstrained
/// parent causes the grid to stretch to fill available width, producing
/// oversized cells and vertical overflow.
class EthiopianCalendarView extends StatelessWidget {
  const EthiopianCalendarView({
    super.key,
    required this.displayedMonth,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
    required this.onMonthChanged,
    this.selectedDate,
    this.locale,
  });

  /// Any date within the month currently being displayed. Only its
  /// year/month are read; the day is ignored.
  final EthiopianDate displayedMonth;

  /// The earliest selectable date (inclusive).
  final EthiopianDate firstDate;

  /// The latest selectable date (inclusive).
  final EthiopianDate lastDate;

  /// The currently selected date, if any. Highlighted when it falls
  /// within [displayedMonth].
  final EthiopianDate? selectedDate;

  /// Called when the user taps a selectable day.
  final ValueChanged<EthiopianDate> onDateSelected;

  /// Called with the new displayed month when the user taps the
  /// previous/next arrows in the header.
  final ValueChanged<EthiopianDate> onMonthChanged;

  /// Optional locale code, forwarded to [EthiopianCalendarHeader]. See
  /// [EthiopianCalendarHeader.resolveLocale] for fallback behavior.
  final String? locale;

  /// Fixed width for the whole widget, matching Material's own date
  /// picker footprint. 7 columns at ~46px each plus minor padding.
  static const double _width = 328;

  static const List<String> _weekdayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  @override
  Widget build(BuildContext context) {
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

    return SizedBox(
      width: _width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EthiopianCalendarHeader(
            year: year,
            month: month,
            locale: locale,
            onPreviousMonth: () => onMonthChanged(previousMonth),
            onNextMonth: () => onMonthChanged(nextMonth),
            canGoPrevious: !previousMonthLastDay.isBefore(firstDate),
            canGoNext: !nextMonth.isAfter(lastDate),
          ),
          const SizedBox(height: 8),
          Row(
            children: _weekdayLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            children: [
              for (int i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
              for (int day = 1; day <= daysInMonth; day++)
                _buildDayCell(year, month, day, today),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(int year, int month, int day, EthiopianDate today) {
    final EthiopianDate date = EthiopianDate(year, month, day);
    final bool isDisabled = date.isBefore(firstDate) || date.isAfter(lastDate);
    final bool isSelected = selectedDate != null && date == selectedDate;
    final bool isToday = date == today;

    return EthiopianDayCell(
      day: day,
      isSelected: isSelected,
      isToday: isToday,
      isDisabled: isDisabled,
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