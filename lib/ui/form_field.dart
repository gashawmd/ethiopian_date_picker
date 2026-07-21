import 'package:flutter/material.dart';

import '../core/ethiopian_date.dart';
import '../core/ethiopian_date_interop.dart';
import '../theme/picker_theme.dart';
import 'date_picker_dialog.dart';

/// An optional controller for [EthiopianDateFormField] that switches the
/// field from its default tap-to-open behavior into typed-entry mode.
///
/// Mirrors [TextEditingController] in spirit: owns the underlying
/// [TextEditingController] used for keyboard entry, keeps it in sync with
/// a parsed [EthiopianDate] value, and must be [dispose]d by whoever
/// creates it — [EthiopianDateFormField] never disposes a controller it
/// didn't create itself, matching how [TextFormField] treats externally
/// supplied [TextEditingController]s.
///
/// Parsing currently only supports the default `yyyy-MM-dd` layout (the
/// same default as [EthiopianDateFormatting.format] and
/// [EthiopianDate.toString]). Text that doesn't parse to a valid
/// [EthiopianDate] simply leaves [value] as `null` rather than throwing —
/// the field's own [FormFieldValidator] is the right place to surface
/// "please enter a valid date" style errors to the user.
class EthiopianDateEditingController extends ValueNotifier<EthiopianDate?> {
  EthiopianDateEditingController({EthiopianDate? initialValue})
      : _textController = TextEditingController(
          text: initialValue?.format() ?? '',
        ),
        super(initialValue) {
    _textController.addListener(_handleTextChanged);
  }

  final TextEditingController _textController;

  /// The underlying text controller, exposed for the rare case a caller
  /// needs to attach a [FocusNode] or read selection state directly.
  TextEditingController get textController => _textController;

  /// Convenience accessor for the current raw text, equivalent to
  /// `textController.text`.
  String get text => _textController.text;
  set text(String newText) => _textController.text = newText;

  bool _syncingFromValue = false;
  bool _syncingFromText = false;

  void _handleTextChanged() {
    if (_syncingFromValue) return;
    _syncingFromText = true;
    value = _tryParse(_textController.text);
    _syncingFromText = false;
  }

  @override
  set value(EthiopianDate? newValue) {
    super.value = newValue;
    if (_syncingFromText) return;
    _syncingFromValue = true;
    _textController.text = newValue?.format() ?? '';
    _syncingFromValue = false;
  }

  static EthiopianDate? _tryParse(String input) {
    final List<String> parts = input.trim().split('-');
    if (parts.length != 3) return null;
    final int? year = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    final int? day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    try {
      return EthiopianDate(year, month, day);
    } catch (_) {
      // Invalid combination (e.g. month 14, or day 30 in a non-leap
      // Pagume) — treated as "not yet a valid date" rather than a
      // crash; the field's validator surfaces this to the user.
      return null;
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_handleTextChanged);
    _textController.dispose();
    super.dispose();
  }
}

/// An [EthiopianDate] field compatible with [Form]/[FormState], matching
/// the shape of Flutter's own [TextFormField] closely enough to drop into
/// existing forms with minimal friction.
///
/// **Default behavior (no [controller]):** a read-only, tap-to-open field.
/// Tapping it — or focusing it via keyboard/switch-access and activating —
/// opens [showEthiopianDatePicker]. This is the recommended mode for most
/// consumers: typed Ethiopian-date entry is easy to get subtly wrong (13
/// months, Pagume's 5/6-day range), so tap-to-open avoids that failure
/// surface entirely.
///
/// **Typed-entry mode:** pass an [EthiopianDateEditingController] to let
/// users type a date directly (`yyyy-MM-dd`), with a calendar-icon button
/// still available to open the picker as an alternative input path.
///
/// DoD: works inside a standard [Form], validated via
/// `formKey.currentState.validate()` — [validator] and [onSaved] are
/// forwarded to the underlying [FormField] unchanged.
class EthiopianDateFormField extends FormField<EthiopianDate> {
  EthiopianDateFormField({
    super.key,
    EthiopianDate? initialValue,
    this.firstDate,
    this.lastDate,
    this.locale,
    this.theme,
    this.decoration = const InputDecoration(),
    this.controller,
    this.onChanged,
    super.validator,
    super.onSaved,
    super.enabled = true,
    AutovalidateMode? autovalidateMode,
  })  : assert(
          initialValue == null || controller == null,
          'EthiopianDateFormField: provide either initialValue or '
          'controller, not both — the controller already owns the '
          'initial value.',
        ),
        super(
          initialValue: controller?.value ?? initialValue,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          builder: (FormFieldState<EthiopianDate> field) {
            return _EthiopianDateFormFieldInput(field: field);
          },
        );

  /// Lower bound passed through to [showEthiopianDatePicker].
  final EthiopianDate? firstDate;

  /// Upper bound passed through to [showEthiopianDatePicker].
  final EthiopianDate? lastDate;

  /// Locale code passed through to [showEthiopianDatePicker]; falls back
  /// to English for `null`/unsupported codes, same as the dialog itself.
  final String? locale;

  /// Visual theme passed through to [showEthiopianDatePicker].
  final EthiopianDatePickerTheme? theme;

  /// Decoration for the field's [InputDecorator]/[TextField], following
  /// the same conventions as [TextFormField.decoration].
  final InputDecoration decoration;

  /// When supplied, switches the field into typed-entry mode. See the
  /// class doc comment for the behavioral difference.
  final EthiopianDateEditingController? controller;

  /// Called whenever the selected date changes, whether via typing,
  /// tapping the calendar icon, or (in tap-to-open mode) the field
  /// itself.
  final ValueChanged<EthiopianDate?>? onChanged;
}

class _EthiopianDateFormFieldInput extends StatefulWidget {
  const _EthiopianDateFormFieldInput({required this.field});

  final FormFieldState<EthiopianDate> field;

  @override
  State<_EthiopianDateFormFieldInput> createState() =>
      _EthiopianDateFormFieldInputState();
}

class _EthiopianDateFormFieldInputState
    extends State<_EthiopianDateFormFieldInput> {
  EthiopianDateFormField get _owner =>
      widget.field.widget as EthiopianDateFormField;

  @override
  void initState() {
    super.initState();
    _owner.controller?.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant _EthiopianDateFormFieldInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final EthiopianDateEditingController? oldController =
        (oldWidget.field.widget as EthiopianDateFormField).controller;
    final EthiopianDateEditingController? newController = _owner.controller;
    if (oldController != newController) {
      oldController?.removeListener(_handleControllerChanged);
      newController?.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    _owner.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    final EthiopianDate? newValue = _owner.controller!.value;
    if (newValue != widget.field.value) {
      widget.field.didChange(newValue);
      _owner.onChanged?.call(newValue);
    }
  }

  Future<void> _openPicker() async {
    if (!_owner.enabled) return;
    final EthiopianDate? picked = await showEthiopianDatePicker(
      context: context,
      initialDate: widget.field.value,
      firstDate: _owner.firstDate,
      lastDate: _owner.lastDate,
      locale: _owner.locale,
      theme: _owner.theme,
    );
    if (picked == null) return;
    widget.field.didChange(picked);
    _owner.controller?.value = picked;
    _owner.onChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final InputDecoration effectiveDecoration = _owner.decoration
        .applyDefaults(Theme.of(context).inputDecorationTheme)
        .copyWith(errorText: widget.field.errorText);

    final EthiopianDateEditingController? controller = _owner.controller;

    if (controller != null) {
      return TextField(
        controller: controller.textController,
        enabled: _owner.enabled,
        decoration: effectiveDecoration.copyWith(
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Open calendar',
            onPressed: _owner.enabled ? _openPicker : null,
          ),
        ),
      );
    }

    return InkWell(
      onTap: _owner.enabled ? _openPicker : null,
      child: InputDecorator(
        decoration: effectiveDecoration,
        child: Text(
          widget.field.value?.format() ?? '',
          style: widget.field.value == null
              ? Theme.of(context).inputDecorationTheme.hintStyle
              : null,
        ),
      ),
    );
  }
}
