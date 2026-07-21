import 'package:ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:ethiopian_date_picker/core/ethiopian_date_interop.dart';
import 'package:ethiopian_date_picker/ui/form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal host: a Form containing one EthiopianDateFormField plus a
/// submit button that runs validate() then save(), recording the saved
/// value so tests can assert on it.
class _TestHost extends StatefulWidget {
  const _TestHost({
    this.initialValue,
    this.controller,
    this.validator,
    this.firstDate,
    this.lastDate,
  });

  final EthiopianDate? initialValue;
  final EthiopianDateEditingController? controller;
  final FormFieldValidator<EthiopianDate>? validator;
  final EthiopianDate? firstDate;
  final EthiopianDate? lastDate;

  @override
  State<_TestHost> createState() => _TestHostState();
}

class _TestHostState extends State<_TestHost> {
  final _formKey = GlobalKey<FormState>();
  EthiopianDate? saved;
  bool didSave = false;
  bool validateResult = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EthiopianDateFormField(
                initialValue: widget.initialValue,
                controller: widget.controller,
                validator: widget.validator,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                onSaved: (value) => saved = value,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    validateResult = _formKey.currentState!.validate();
                    if (validateResult) {
                      _formKey.currentState!.save();
                      didSave = true;
                    }
                  });
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  group('EthiopianDateFormField inside Form (Task 5.2 DoD)', () {
    testWidgets(
        'formKey.currentState.validate() runs the validator and shows errorText',
        (tester) async {
      await tester.pumpWidget(
        _TestHost(
          validator: (value) => value == null ? 'Required' : null,
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('validate() passes and save() delivers the value',
        (tester) async {
      await tester.pumpWidget(
        _TestHost(
          initialValue: EthiopianDate(2016, 5, 12),
          validator: (value) => value == null ? 'Required' : null,
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text('Required'), findsNothing);

      final state = tester.state<_TestHostState>(find.byType(_TestHost));
      expect(state.didSave, isTrue);
      expect(state.saved, EthiopianDate(2016, 5, 12));
    });

    testWidgets('initialValue is displayed via the default format',
        (tester) async {
      await tester.pumpWidget(
        _TestHost(initialValue: EthiopianDate(2016, 5, 12)),
      );

      expect(find.text(EthiopianDate(2016, 5, 12).format()), findsOneWidget);
    });
  });

  group('Tap-to-open mode (no controller, Task 5.2 DoD default)', () {
    testWidgets(
        'tapping the field opens the picker and selecting sets the value',
        (tester) async {
      await tester.pumpWidget(
        _TestHost(
          initialValue: EthiopianDate(2016, 5, 12),
          firstDate: EthiopianDate(2000, 1, 1),
          lastDate: EthiopianDate(2020, 12, 30),
        ),
      );

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      // The picker dialog should now be open, seeded at the field's
      // current value (Tir 2016).
      expect(find.text('Tir 2016'), findsOneWidget);

      await tester.tap(find.text('20'));
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text(EthiopianDate(2016, 5, 20).format()), findsOneWidget);
    });

    testWidgets('cancelling the picker leaves the field unchanged',
        (tester) async {
      await tester.pumpWidget(
        _TestHost(initialValue: EthiopianDate(2016, 5, 12)),
      );

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text(EthiopianDate(2016, 5, 12).format()), findsOneWidget);
    });
  });

  group('Typed-entry mode (controller supplied, Task 5.2 DoD optional)', () {
    testWidgets('typing a valid date parses into the controller and field',
        (tester) async {
      final controller = EthiopianDateEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_TestHost(controller: controller));

      await tester.enterText(find.byType(TextField), '2016-05-12');
      await tester.pump();

      expect(controller.value, EthiopianDate(2016, 5, 12));

      await tester.tap(find.text('Submit'));
      await tester.pump();

      final state = tester.state<_TestHostState>(find.byType(_TestHost));
      expect(state.saved, EthiopianDate(2016, 5, 12));
    });

    testWidgets('typing an invalid date leaves controller.value null',
        (tester) async {
      final controller = EthiopianDateEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_TestHost(controller: controller));

      await tester.enterText(find.byType(TextField), 'not a date');
      await tester.pump();

      expect(controller.value, isNull);
    });

    testWidgets('the calendar icon still opens the picker in typed mode',
        (tester) async {
      final controller = EthiopianDateEditingController(
          initialValue: EthiopianDate(2016, 5, 12));
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _TestHost(
          controller: controller,
          firstDate: EthiopianDate(2000, 1, 1),
          lastDate: EthiopianDate(2020, 12, 30),
        ),
      );

      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      expect(find.text('Tir 2016'), findsOneWidget);

      await tester.tap(find.text('20'));
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(controller.value, EthiopianDate(2016, 5, 20));
      expect(controller.text, EthiopianDate(2016, 5, 20).format());
    });
  });

  group('initialValue/controller mutual exclusion (Task 5.2 DoD assertion)',
      () {
    testWidgets('providing both throws a clear assertion error',
        (tester) async {
      final controller = EthiopianDateEditingController();
      addTearDown(controller.dispose);

      expect(
        () => EthiopianDateFormField(
          initialValue: EthiopianDate(2016, 1, 1),
          controller: controller,
        ),
        throwsAssertionError,
      );
    });
  });
}
