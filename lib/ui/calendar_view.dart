import 'package:flutter/material.dart';

import '../core/calendar_logic.dart';
import '../core/ethiopian_date.dart';
import '../core/ethiopian_date_range.dart';
import '../localization/ethiopian_locale.dart';
import '../theme/picker_theme.dart';
import 'day_cell.dart';
import 'header.dart';

/// A standalone, embeddable Ethiopian calendar widget.
///
/// Unlike [showEthiopianDatePicker] (which pops a dialog), this widget can
/// be placed directly in your widget tree - e.g. inside a page, a bottom
/// sheet, or a side panel - making it the key differentiator versus most
/// Ethiopian calendar packages, which only offer a dialog.
class EthiopianCalendarView extends StatefulWidget {
  const EthiopianCalendarView({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.selectedDate,
    this.selectedRange,
    this.onRangeSelected,
    this.rangeMode = false,
    this.theme = const EthiopianDatePickerTheme(),
    this.locale = EthiopianLocale.english,
  });

  /// The month initially shown. Defaults to today.
  final EthiopianDate? initialDate;

  /// Earliest selectable date (inclusive). Dates before this are disabled.
  final EthiopianDate? firstDate;

  /// Latest selectable date (inclusive). Dates after this are disabled.
  final EthiopianDate? lastDate;

  /// Called with the tapped date in single-selection mode.
  final ValueChanged<EthiopianDate>? onDateSelected;

  /// Currently selected date, for single-selection mode.
  final EthiopianDate? selectedDate;

  /// Currently selected range, for range-selection mode.
  final EthiopianDateRange? selectedRange;

  /// Called when a range selection completes (start and end both picked).
  final ValueChanged<EthiopianDateRange>? onRangeSelected;

  /// When true, two taps select a start/end range instead of a single date.
  final bool rangeMode;

  final EthiopianDatePickerTheme theme;
  final EthiopianLocaleData locale;

  @override
  State<EthiopianCalendarView> createState() => _EthiopianCalendarViewState();
}

class _EthiopianCalendarViewState extends State<EthiopianCalendarView> {
  late EthiopianDate _visibleMonth;
  EthiopianDate? _rangeStart;
  EthiopianDate? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _visibleMonth =
        (widget.initialDate ?? widget.selectedDate ?? EthiopianDate.today())
            .firstDayOfMonth;
    if (widget.selectedRange != null) {
      _rangeStart = widget.selectedRange!.start;
      _rangeEnd = widget.selectedRange!.end;
    }
  }

  bool _isDisabled(EthiopianDate date) {
    if (widget.firstDate != null && date.isBefore(widget.firstDate!)) {
      return true;
    }
    if (widget.lastDate != null && date.isAfter(widget.lastDate!)) {
      return true;
    }
    return false;
  }

  void _goToPreviousMonth() {
    setState(() => _visibleMonth = _visibleMonth.addMonths(-1));
  }

  void _goToNextMonth() {
    setState(() => _visibleMonth = _visibleMonth.addMonths(1));
  }

  void _handleTap(EthiopianDate date) {
    if (widget.rangeMode) {
      setState(() {
        if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
          _rangeStart = date;
          _rangeEnd = null;
        } else {
          _rangeEnd = date;
          widget.onRangeSelected?.call(
            EthiopianDateRange(start: _rangeStart!, end: date),
          );
        }
      });
    } else {
      widget.onDateSelected?.call(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = EthiopianDate.today();
    final int year = _visibleMonth.year;
    final int month = _visibleMonth.month;
    final int totalDays = EthiopianCalendarLogic.daysInMonth(year, month);
    final int firstWeekday = EthiopianCalendarLogic.weekdayOf(year, month, 1);

    return Container(
      decoration: BoxDecoration(
        color: widget.theme.backgroundColor,
        borderRadius: BorderRadius.circular(widget.theme.borderRadius),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EthiopianCalendarHeader(
            year: year,
            month: month,
            theme: widget.theme,
            locale: widget.locale,
            onPrevious: _goToPreviousMonth,
            onNext: _goToNextMonth,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: widget.locale.weekdayShortNames
                  .map(
                    (label) => Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.theme.weekdayLabelColor,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: firstWeekday + totalDays,
              itemBuilder: (context, index) {
                if (index < firstWeekday) {
                  return const SizedBox.shrink();
                }
                final int day = index - firstWeekday + 1;
                final date = EthiopianDate(year, month, day);
                final bool isToday = date == today;
                final bool isSelected =
                    !widget.rangeMode && date == widget.selectedDate;
                final bool isRangeEdge = widget.rangeMode &&
                    (date == _rangeStart || date == _rangeEnd);
                final bool isInRange = widget.rangeMode &&
                    _rangeStart != null &&
                    _rangeEnd != null &&
                    EthiopianDateRange(start: _rangeStart!, end: _rangeEnd!)
                        .contains(date);

                return EthiopianDayCell(
                  day: day,
                  theme: widget.theme,
                  isSelected: isSelected,
                  isToday: isToday,
                  isRangeEdge: isRangeEdge,
                  isInRange: isInRange,
                  isDisabled: _isDisabled(date),
                  onTap: () => _handleTap(date),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
