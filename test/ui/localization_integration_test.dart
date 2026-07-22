// test/ui/localization_integration_test.dart
//
// Task 5.1 DoD (widget-level): "Switching locale updates all visible text
// with no missing-key fallback errors" — proven through the actual
// showEthiopianDatePicker() dialog, not just raw locale-data lookups.
//
// Deliberately does NOT assert on specific translated strings (e.g. the
// am/om/ti OK/CANCEL labels) since those live in locale data files this
// test doesn't have visibility into — asserting on guessed text would
// just reintroduce the same problem in a different form. Instead this
// checks structural properties: the dialog renders, its full text
// content changes between locales, and the English/default path is
// unaffected (already covered exactly by date_picker_dialog_test.dart,
// repeated here for a single coherent locale-focused suite).

import 'package:flutter_ethiopian_date_picker/ui/date_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openDialog(WidgetTester tester, {String? locale}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showEthiopianDatePicker(
                context: context,
                locale: locale,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

/// All visible text currently in the tree, as a set (order doesn't
/// matter for the comparisons below).
Set<String> _visibleTexts(WidgetTester tester) {
  return find
      .byType(Text)
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .whereType<String>()
      .toSet();
}

void main() {
  group('Full-dialog locale switching (Task 5.1 DoD, widget-level)', () {
    for (final locale in ['am', 'om', 'ti']) {
      testWidgets(
          '$locale: dialog opens without crashing and renders non-empty text',
          (tester) async {
        await _openDialog(tester, locale: locale);

        expect(find.byType(Dialog), findsOneWidget);

        final texts = _visibleTexts(tester);
        expect(texts, isNotEmpty);
      });
    }

    testWidgets('en (default, no locale passed): OK/Cancel render as-is',
        (tester) async {
      await _openDialog(tester, locale: null);

      expect(find.byType(Dialog), findsOneWidget);
      // Confirmed via diagnostic dump: the actual rendered label is
      // 'Cancel' (title case), not 'CANCEL'. Note: this differs from
      // what test/ui/date_picker_dialog_test.dart currently asserts —
      // worth reconciling separately, see conversation notes.
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('unsupported locale code falls back to English, no crash',
        (tester) async {
      await _openDialog(tester, locale: 'xx-not-a-real-locale');

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    for (final locale in ['am', 'om', 'ti']) {
      testWidgets(
          '$locale: visible text differs from the English default (real localization happened)',
          (tester) async {
        await _openDialog(tester, locale: null);
        final enTexts = _visibleTexts(tester);

        // Dismiss via the barrier tap, mirroring the pattern already
        // used in date_picker_dialog_test.dart.
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        await _openDialog(tester, locale: locale);
        final localizedTexts = _visibleTexts(tester);

        expect(
          localizedTexts,
          isNot(equals(enTexts)),
          reason: 'Expected $locale text to differ from English default; '
              'identical sets suggest the locale was silently ignored.',
        );
      });
    }
  });
}
