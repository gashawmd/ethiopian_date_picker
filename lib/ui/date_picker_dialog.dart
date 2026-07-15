import 'package:flutter/material.dart';

import '../core/ethiopian_date.dart';
import '../localization/ethiopian_locale.dart';
import '../theme/picker_theme.dart';
import 'calendar_view.dart';

/// Shows a dialog containing an [EthiopianCalendarView] and returns the
/// date the user picked, or `null` if they cancelled.
///
/// Example:
/// ```dart
/// final date = await showEthiopianDatePicker(context: context);
/// ```
Future<EthiopianDate?> showEthiopianDatePicker({
  required BuildContext context,
  EthiopianDate? initialDate,
  EthiopianDate? firstDate,
  EthiopianDate? lastDate,
  EthiopianDatePickerTheme theme = const EthiopianDatePickerTheme(),
  EthiopianLocaleData locale = EthiopianLocale.english,
}) {
  return showDialog<EthiopianDate>(
    context: context,
    builder: (context) {
      return _EthiopianDatePickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        theme: theme,
        locale: locale,
      );
    },
  );
}

class _EthiopianDatePickerDialog extends StatefulWidget {
  const _EthiopianDatePickerDialog({
    this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.theme,
    required this.locale,
  });

  final EthiopianDate? initialDate;
  final EthiopianDate? firstDate;
  final EthiopianDate? lastDate;
  final EthiopianDatePickerTheme theme;
  final EthiopianLocaleData locale;

  @override
  State<_EthiopianDatePickerDialog> createState() =>
      _EthiopianDatePickerDialogState();
}

class _EthiopianDatePickerDialogState
    extends State<_EthiopianDatePickerDialog> {
  EthiopianDate? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate ?? EthiopianDate.today();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EthiopianCalendarView(
                initialDate: _selected,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                selectedDate: _selected,
                theme: widget.theme,
                locale: widget.locale,
                onDateSelected: (date) => setState(() => _selected = date),
              ),
              Container(
                decoration: BoxDecoration(
                  color: widget.theme.backgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(widget.theme.borderRadius),
                    bottomRight: Radius.circular(widget.theme.borderRadius),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: Text(widget.locale.cancel),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_selected),
                      child: Text(widget.locale.ok),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
