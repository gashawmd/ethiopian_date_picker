import 'package:flutter/material.dart';

import '../core/ethiopian_date.dart';
import '../theme/picker_theme.dart';
import '../utils/date_utils.dart';
import 'calendar_view.dart';

/// Shows a modal dialog containing an [EthiopianCalendarView] plus
/// Cancel/OK actions, returning the selected date once OK is pressed,
/// or `null` if the dialog is dismissed or cancelled.
///
/// Mirrors the signature and behavior of Flutter's built-in
/// `showDatePicker()`: [initialDate] seeds the initial selection (and
/// displayed month), while [firstDate]/[lastDate] bound the selectable
/// range (both inclusive).
///
/// All parameters besides [context] are optional, so this works with
/// zero other configuration:
/// ```dart
/// final date = await showEthiopianDatePicker(context: context);
/// ```
///
/// Pass [theme] to override colors, spacing, or typography; omit it
/// and the picker matches the ambient Material 3 app theme.
///
/// Built on [showGeneralDialog] rather than [showDialog] (Task 4.1) so
/// the dialog's entrance/exit gets an explicit fade+scale transition,
/// rather than relying on whatever transition (if any) the platform's
/// default route happens to apply. `barrierDismissible`/`barrierColor`
/// are set to match `showDialog`'s own defaults, so tap-outside-to-
/// dismiss behavior is unchanged from before this task.
///
/// Error handling (see [EthiopianDatePickerDialog] for details):
/// - `initialDate` outside `[firstDate, lastDate]` is silently clamped
///   into range rather than throwing or producing an unselectable
///   initial state.
/// - `firstDate > lastDate` is a programmer error, caught by a debug
///   assertion with a clear message; it is not silently tolerated.
/// - An unsupported/missing [locale] falls back to English rather than
///   throwing.
Future<EthiopianDate?> showEthiopianDatePicker({
  required BuildContext context,
  EthiopianDate? initialDate,
  EthiopianDate? firstDate,
  EthiopianDate? lastDate,
  String? locale,
  EthiopianDatePickerTheme? theme,
}) {
  final EthiopianDate resolvedInitialDate =
      initialDate ?? EthiopianDate.today();
  final EthiopianDate resolvedFirstDate =
      firstDate ?? EthiopianDate(1900, 1, 1);
  final EthiopianDate resolvedLastDate =
      lastDate ?? EthiopianDate(2100, 12, 30);

  return showGeneralDialog<EthiopianDate>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: EthiopianDatePickerDialog(
          initialDate: resolvedInitialDate,
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

/// The dialog widget itself, exposed publicly in case callers want to
/// embed it directly (e.g. inside a custom bottom sheet) rather than
/// go through [showEthiopianDatePicker]. Note that going this route
/// bypasses the fade+scale entrance/exit transition described above -
/// that animation lives in [showEthiopianDatePicker]'s use of
/// `showGeneralDialog`, not in this widget itself, since a widget
/// can't animate its own route transition.
///
/// Error handling:
/// - A debug-mode [assert] catches `firstDate > lastDate` misconfig
///   with a clear message, matching how Flutter's own `DatePickerDialog`
///   validates its own `firstDate`/`lastDate`. This is a programmer
///   error - it should fail loudly in development, not be silently
///   "handled" in a way that hides the bug. It is stripped in release
///   builds, same as any other Dart `assert`.
/// - `initialDate` outside `[firstDate, lastDate]` is a much more
///   common, easy-to-hit mistake (e.g. a stored "last picked date" that
///   predates a newly-tightened `firstDate`), so rather than asserting
///   on it, it's silently clamped into range via
///   [EthiopianDateUtils.clamp].
class EthiopianDatePickerDialog extends StatefulWidget {
  EthiopianDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.locale,
    this.theme,
  }) : assert(
          !firstDate.isAfter(lastDate),
          'EthiopianDatePickerDialog: firstDate ($firstDate) must not be '
          'after lastDate ($lastDate).',
        );

  final EthiopianDate initialDate;
  final EthiopianDate firstDate;
  final EthiopianDate lastDate;

  /// Optional locale code, forwarded to [EthiopianCalendarView]. See
  /// [EthiopianCalendarHeader.resolveLocale] for fallback behavior -
  /// an unrecognized code never throws, it just falls back to English.
  final String? locale;

  /// Optional visual theme. Falls back to
  /// [EthiopianDatePickerTheme.material3] when omitted.
  final EthiopianDatePickerTheme? theme;

  @override
  State<EthiopianDatePickerDialog> createState() =>
      _EthiopianDatePickerDialogState();
}

class _EthiopianDatePickerDialogState
    extends State<EthiopianDatePickerDialog> {
  late EthiopianDate _selectedDate;
  late EthiopianDate _displayedMonth;

  @override
  void initState() {
    super.initState();
    // Defensive clamp: even if showEthiopianDatePicker() didn't clamp
    // (or this widget is constructed directly, bypassing that
    // function), an out-of-range initialDate is silently pulled back
    // into [firstDate, lastDate] rather than producing an initial
    // selection the calendar would refuse to render as selected.
    _selectedDate = EthiopianDateUtils.clamp(
      widget.initialDate,
      min: widget.firstDate,
      max: widget.lastDate,
    );
    _displayedMonth =
        EthiopianDate(_selectedDate.year, _selectedDate.month, 1);
  }

  void _handleDateSelected(EthiopianDate date) {
    setState(() => _selectedDate = date);
  }

  void _handleMonthChanged(EthiopianDate month) {
    setState(() => _displayedMonth = month);
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  void _handleOk() {
    Navigator.of(context).pop(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final EthiopianDatePickerTheme resolvedTheme =
        widget.theme ?? EthiopianDatePickerTheme.material3(context);

    return Dialog(
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
              selectedDate: _selectedDate,
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
                  ),
                  child: const Text('CANCEL'),
                ),
                SizedBox(width: resolvedTheme.spacing.sm),
                TextButton(
                  onPressed: _handleOk,
                  style: TextButton.styleFrom(
                    foregroundColor: resolvedTheme.primaryColor,
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}