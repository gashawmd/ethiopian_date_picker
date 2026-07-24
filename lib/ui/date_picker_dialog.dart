import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/ethiopian_date.dart';
import '../localization/ethiopian_locale.dart';
import '../theme/picker_theme.dart';
import '../utils/date_utils.dart';
import 'calendar_view.dart';

/// Shows the Ethiopian date picker as a modal dialog and returns the
/// date the user selected, or `null` if they cancelled.
///
/// - [initialDate] is the date shown/selected when the dialog opens;
///   defaults to [EthiopianDate.today].
/// - [firstDate] and [lastDate] bound the selectable range; default to
///   a wide span (1900-2100).
/// - [locale] selects UI language (`'en'`, `'am'`, `'om'`, `'ti'`);
///   unsupported or missing codes fall back to English.
/// - [theme] overrides colors, spacing, and typography; defaults to
///   [EthiopianDatePickerTheme.material3].
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

/// The dialog widget rendered by [showEthiopianDatePicker].
///
/// Most users should call [showEthiopianDatePicker] directly rather
/// than constructing this widget themselves.
class EthiopianDatePickerDialog extends StatefulWidget {
  /// Creates the picker dialog. Throws an assertion error in debug
  /// mode if [firstDate] is after [lastDate].
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

  /// The date shown/selected when the dialog first opens.
  final EthiopianDate initialDate;

  /// The earliest selectable date.
  final EthiopianDate firstDate;

  /// The latest selectable date.
  final EthiopianDate lastDate;

  /// Locale code for UI text. If unset or unsupported, it just falls
  /// back to English.
  final String? locale;

  /// Optional visual theme. Falls back to
  /// [EthiopianDatePickerTheme.material3] when unset.
  final EthiopianDatePickerTheme? theme;

  @override
  State<EthiopianDatePickerDialog> createState() =>
      _EthiopianDatePickerDialogState();
}

class _EthiopianDatePickerDialogState extends State<EthiopianDatePickerDialog> {
  late EthiopianDate _selectedDate;
  late EthiopianDate _displayedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = EthiopianDateUtils.clamp(
      widget.initialDate,
      min: widget.firstDate,
      max: widget.lastDate,
    );
    _displayedMonth = EthiopianDate(_selectedDate.year, _selectedDate.month, 1);
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
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text(localeData.cancelLabel),
                  ),
                  SizedBox(width: resolvedTheme.spacing.sm),
                  TextButton(
                    onPressed: _handleOk,
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
