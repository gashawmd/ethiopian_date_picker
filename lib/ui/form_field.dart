import 'package:flutter/material.dart';

import '../core/ethiopian_date.dart';
import '../core/ethiopian_date_interop.dart';
import '../theme/picker_theme.dart';
import 'date_picker_dialog.dart';

class EthiopianDateEditingController extends ValueNotifier<EthiopianDate?> {
  EthiopianDateEditingController({EthiopianDate? initialValue})
      : _textController = TextEditingController(
          text: initialValue?.format() ?? '',
        ),
        super(initialValue) {
    _textController.addListener(_handleTextChanged);
  }

  final TextEditingController _textController;
  TextEditingController get textController => _textController;
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

  final EthiopianDate? firstDate;
  final EthiopianDate? lastDate;
  final String? locale;
  final EthiopianDatePickerTheme? theme;
  final InputDecoration decoration;
  final EthiopianDateEditingController? controller;
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
