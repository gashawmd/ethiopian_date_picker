import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/ethiopian_date.dart';
import '../core/ethiopian_date_range.dart';
import '../core/ethiopian_date_range_selection.dart';
import '../localization/ethiopian_locale.dart';
import '../theme/picker_theme.dart';
import '../utils/date_utils.dart';
import 'calendar_view.dart';

/// Shows a modal dialog for picking an [EthiopianDateRange] via a
/// tap-start / tap-end interaction: the first tap sets the range's
/// start, the second tap sets its end (auto-swapped into `start <=
/// end` order if tapped out of order), and tapping again after the
/// range is complete resets and starts a new selection.
///
/// Returns the completed range once OK is pressed, or `null` if the
/// dialog is dismissed or cancelled. OK stays disabled until a full
/// range has been picked - a single pending start isn't enough to
/// confirm.
///
/// All parameters besides [context] are optional:
/// ```dart
/// final range = await showEthiopianDateRangePicker(context: context);
/// ```
///
/// Uses the same `showGeneralDialog`-based fade+scale entrance/exit
/// as [showEthiopianDatePicker] (Task 4.1), and the same
/// `firstDate > lastDate` debug assertion and locale-fallback
/// behavior as the single-date dialog (Task 2.3).
Future<EthiopianDateRange?> showEthiopianDateRangePicker({
  required BuildContext context,
  EthiopianDateRange? initialRange,
  EthiopianDate? firstDate,
  EthiopianDate? lastDate,
  String? locale,
  EthiopianDatePickerTheme? theme,
}) {
  final EthiopianDate resolvedFirstDate =
      firstDate ?? EthiopianDate(1900, 1, 1);
  final EthiopianDate resolvedLastDate =
      lastDate ?? EthiopianDate(2100, 12, 30);

  return showGeneralDialog<EthiopianDateRange>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: EthiopianDateRangePickerDialog(
          initialRange: initialRange,
          firstDate: resolvedFirstDate,
          lastDate: resolvedLastDate,
          locale: locale,
          theme: theme,
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final CurvedAnimation curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// The dialog widget itself, exposed publicly for callers who want to
/// embed it directly rather than go through
/// [showEthiopianDateRangePicker] (same rationale as
/// [EthiopianDatePickerDialog] - going this route skips the built-in
/// fade+scale transition, which lives in the `showGeneralDialog` call
/// above, not in this widget).
///
/// Accessibility (Task 5.3): same as [EthiopianDatePickerDialog] -
/// Escape closes the dialog via [CallbackShortcuts], and both action
/// buttons carry an explicit 48x48 minimum tap target.
class EthiopianDateRangePickerDialog extends StatefulWidget {
  EthiopianDateRangePickerDialog({
    super.key,
    this.initialRange,
    required this.firstDate,
    required this.lastDate,
    this.locale,
    this.theme,
  }) : assert(
          !firstDate.isAfter(lastDate),
          'EthiopianDateRangePickerDialog: firstDate ($firstDate) must not '
          'be after lastDate ($lastDate).',
        );

  /// Optional pre-existing range to seed the dialog with (e.g. editing
  /// a previously-picked range). Both endpoints are independently
  /// clamped into `[firstDate, lastDate]`, same defensive philosophy
  /// as the single-date dialog's `initialDate` clamping (Task 2.3).
  final EthiopianDateRange? initialRange;

  final EthiopianDate firstDate;
  final EthiopianDate lastDate;

  /// Optional locale code, forwarded to [EthiopianCalendarView]. See
  /// [EthiopianCalendarHeader.resolveLocale] for fallback behavior.
  final String? locale;

  /// Optional visual theme. Falls back to
  /// [EthiopianDatePickerTheme.material3] when omitted.
  final EthiopianDatePickerTheme? theme;

  @override
  State<EthiopianDateRangePickerDialog> createState() =>
      _EthiopianDateRangePickerDialogState();
}

class _EthiopianDateRangePickerDialogState
    extends State<EthiopianDateRangePickerDialog> {
  late EthiopianDateRangeSelection _selection;
  late EthiopianDate _displayedMonth;

  @override
  void initState() {
    super.initState();
    final EthiopianDateRange? initial = widget.initialRange;

    if (initial != null) {
      // Clamp is monotonic, so clamping each endpoint independently
      // can never invert their order - clampedStart <= clampedEnd is
      // still guaranteed even if the original range fell entirely
      // outside [firstDate, lastDate].
      final EthiopianDate clampedStart = EthiopianDateUtils.clamp(
        initial.start,
        min: widget.firstDate,
        max: widget.lastDate,
      );
      final EthiopianDate clampedEnd = EthiopianDateUtils.clamp(
        initial.end,
        min: widget.firstDate,
        max: widget.lastDate,
      );
      _selection = EthiopianDateRangeSelection.completed(
        EthiopianDateRange(start: clampedStart, end: clampedEnd),
      );
      _displayedMonth = EthiopianDate(clampedStart.year, clampedStart.month, 1);
    } else {
      _selection = const EthiopianDateRangeSelection.empty();
      final EthiopianDate today = EthiopianDateUtils.clamp(
        EthiopianDate.today(),
        min: widget.firstDate,
        max: widget.lastDate,
      );
      _displayedMonth = EthiopianDate(today.year, today.month, 1);
    }
  }

  void _handleDateSelected(EthiopianDate date) {
    setState(() => _selection = _selection.select(date));
  }

  void _handleMonthChanged(EthiopianDate month) {
    setState(() => _displayedMonth = month);
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  void _handleOk() {
    final EthiopianDateRange? range = _selection.completedRange;
    if (range != null) {
      Navigator.of(context).pop(range);
    }
  }

  @override
  Widget build(BuildContext context) {
    final EthiopianDatePickerTheme resolvedTheme =
        widget.theme ?? EthiopianDatePickerTheme.material3(context);
    final EthiopianLocaleData localeData =
        resolveEthiopianLocaleData(widget.locale);

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: Dialog(
        backgroundColor: resolvedTheme.backgroundColor,
        child: Padding(
          padding: EdgeInsets.all(resolvedTheme.spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EthiopianCalendarView(
                displayedMonth: _displayedMonth,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                selectedRange: _selection.displayRange,
                locale: widget.locale,
                theme: resolvedTheme,
                onDateSelected: _handleDateSelected,
                onMonthChanged: _handleMonthChanged,
              ),
              SizedBox(height: resolvedTheme.spacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _handleCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: resolvedTheme.primaryColor,
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text(localeData.cancelLabel),
                  ),
                  SizedBox(width: resolvedTheme.spacing.sm),
                  TextButton(
                    // Disabled until a full range is picked - a single
                    // pending start isn't a confirmable selection.
                    onPressed: _selection.isComplete ? _handleOk : null,
                    style: TextButton.styleFrom(
                      foregroundColor: resolvedTheme.primaryColor,
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text(localeData.okLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
