import 'package:flutter/material.dart';

import '../core/ethiopian_date.dart';
import '../core/ethiopian_date_range.dart';
import '../localization/ethiopian_locale.dart';
import '../theme/picker_theme.dart';
import '../utils/date_utils.dart';
import 'day_cell.dart';
import 'header.dart';

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

  final EthiopianDate displayedMonth;
  final EthiopianDate firstDate;
  final EthiopianDate lastDate;
  final EthiopianDate? selectedDate;
  final EthiopianDateRange? selectedRange;
  final ValueChanged<EthiopianDate> onDateSelected;
  final ValueChanged<EthiopianDate> onMonthChanged;
  final String? locale;

  /// Optional visual theme. Falls back to
  final EthiopianDatePickerTheme? theme;
  static const double _width = 364;
  static const Duration _monthTransitionDuration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final EthiopianDatePickerTheme resolvedTheme =
        theme ?? EthiopianDatePickerTheme.material3(context);
    final EthiopianLocaleData localeData = resolveEthiopianLocaleData(locale);

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

    final EthiopianDate? autofocusDate =
        _resolveAutofocusDate(today, daysInMonth);

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
            children: localeData.weekdayNamesShort
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
            child: FocusTraversalGroup(
              key: ValueKey<String>('$year-$month'),
              child: GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.0,
                children: [
                  for (int i = 0; i < leadingBlanks; i++)
                    const SizedBox.shrink(),
                  for (int day = 1; day <= daysInMonth; day++)
                    _buildDayCell(
                      year,
                      month,
                      day,
                      today,
                      leadingBlanks,
                      localeData,
                      autofocusDate,
                      resolvedTheme,
                    ),
                ],
              ),
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
    int leadingBlanks,
    EthiopianLocaleData localeData,
    EthiopianDate? autofocusDate,
    EthiopianDatePickerTheme resolvedTheme,
  ) {
    final EthiopianDate date = EthiopianDate(year, month, day);
    final bool isDisabled = date.isBefore(firstDate) || date.isAfter(lastDate);
    final bool isToday = date == today;

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

    final int weekdayIndex = (leadingBlanks + day - 1) % 7;

    return EthiopianDayCell(
      day: day,
      isSelected: isSelected,
      isToday: isToday,
      isDisabled: isDisabled,
      theme: resolvedTheme,
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
      isInRange: isInRange,
      autofocus: autofocusDate != null && date == autofocusDate,
      semanticLabel: _semanticLabel(
        date: date,
        weekdayIndex: weekdayIndex,
        localeData: localeData,
        isToday: isToday,
      ),
      onTap: isDisabled ? null : () => onDateSelected(date),
    );
  }

  String _semanticLabel({
    required EthiopianDate date,
    required int weekdayIndex,
    required EthiopianLocaleData localeData,
    required bool isToday,
  }) {
    final String weekday = localeData.weekdayNamesShort[weekdayIndex];
    final String monthName = localeData.monthNames[date.month - 1];
    final String base = '$weekday, $monthName ${date.day}, ${date.year}';
    return isToday ? '$base, ${localeData.todayLabel}' : base;
  }


  EthiopianDate? _resolveAutofocusDate(EthiopianDate today, int daysInMonth) {
    final EthiopianDate? selected = selectedRange?.start ?? selectedDate;
    if (selected != null &&
        selected.year == displayedMonth.year &&
        selected.month == displayedMonth.month) {
      return selected;
    }
    if (today.year == displayedMonth.year &&
        today.month == displayedMonth.month) {
      return today;
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final EthiopianDate candidate =
          EthiopianDate(displayedMonth.year, displayedMonth.month, day);
      if (!candidate.isBefore(firstDate) && !candidate.isAfter(lastDate)) {
        return candidate;
      }
    }
    return null;
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
