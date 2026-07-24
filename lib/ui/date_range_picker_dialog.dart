import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/ethiopian_date.dart';
import '../core/ethiopian_date_range.dart';
import '../core/ethiopian_date_range_selection.dart';
import '../localization/ethiopian_locale.dart';
import '../theme/picker_theme.dart';
import '../utils/date_utils.dart';
import 'calendar_view.dart';

/// Shows the Ethiopian date-range picker as a modal dialog and
/// returns the range the user selected, or `null` if they cancelled.
///
/// - [initialRange] pre-fills a start/end selection when the dialog
///   opens; leave unset to start with no selection.
/// - [firstDate] and [lastDate] bound the selectable range; default to
///   a wide span (1900-2100).
/// - [locale] selects UI language (`'en'`, `'am'`, `'om'`, `'ti'`);
///   unsupported or missing codes fall back to English.
/// - [theme] overrides colors, spacing, and typography; defaults to
///   [EthiopianDatePickerTheme.material3].
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

/// The dialog widget rendered by [showEthiopianDateRangePicker].
///
/// Most users should call [showEthiopianDateRangePicker] directly
/// rather than constructing this widget themselves.
class EthiopianDateRangePickerDialog extends StatefulWidget {
  /// Creates the range picker dialog. Throws an assertion error in
  /// debug mode if [firstDate] is after [lastDate].
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

  /// A pre-filled start/end selection shown when the dialog opens.
  final EthiopianDateRange? initialRange;

  /// The earliest selectable date.
  final EthiopianDate firstDate;

  /// The latest selectable date.
  final EthiopianDate lastDate;

  /// Locale code for UI text. Falls back to English if unset or
  /// unsupported.
  final String? locale;

  /// Optional visual theme. Falls back to
  /// [EthiopianDatePickerTheme.material3] when unset.
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
