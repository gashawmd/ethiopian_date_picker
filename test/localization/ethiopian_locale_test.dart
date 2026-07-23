import 'package:flutter_ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:flutter_ethiopian_date_picker/localization/am.dart';
import 'package:flutter_ethiopian_date_picker/localization/en.dart';
import 'package:flutter_ethiopian_date_picker/localization/ethiopian_locale.dart';
import 'package:flutter_ethiopian_date_picker/localization/om.dart';
import 'package:flutter_ethiopian_date_picker/localization/ti.dart';
import 'package:flutter_ethiopian_date_picker/ui/date_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _dialogHost({String? locale}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showEthiopianDatePicker(
              context: context,
              initialDate: EthiopianDate(2016, 1, 1),
              locale: locale,
            ),
            child: const Text('Open picker'),
          ),
        ),
      ),
    ),
  );
}

class _LocalizedMonthLabel extends StatelessWidget {
  const _LocalizedMonthLabel({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final EthiopianLocaleData data = resolveEthiopianLocaleData(locale);
    return Text('${data.monthNames[0]} 2016');
  }
}

void main() {
  final locales = <String, EthiopianLocaleData>{
    'en': enLocaleData,
    'am': amLocaleData,
    'om': omLocaleData,
    'ti': tiLocaleData,
  };

  group('Switching locale updates all visible text (Task 5.1 DoD)', () {
    for (final entry in locales.entries) {
      final String code = entry.key;
      final EthiopianLocaleData data = entry.value;

      testWidgets(
          '$code: header month name, weekday row, and OK/CANCEL are all localized',
          (tester) async {
        await tester.pumpWidget(_dialogHost(locale: code));

        await tester.tap(find.text('Open picker'));
        await tester.pumpAndSettle();

        expect(
          find.text('${data.monthNames[0]} 2016'),
          findsOneWidget,
          reason: '$code header month name not shown',
        );
        for (final weekday in data.weekdayNamesShort) {
          expect(
            find.text(weekday),
            findsOneWidget,
            reason: '$code weekday label "$weekday" not shown',
          );
        }

        expect(find.text(data.okLabel), findsOneWidget,
            reason: '$code OK label not shown');
        expect(find.text(data.cancelLabel), findsOneWidget,
            reason: '$code CANCEL label not shown');
        expect(tester.takeException(), isNull);
      });

      testWidgets('$code: navigation tooltips are localized', (tester) async {
        await tester.pumpWidget(_dialogHost(locale: code));

        await tester.tap(find.text('Open picker'));
        await tester.pumpAndSettle();

        expect(find.byTooltip(data.previousMonthTooltip), findsOneWidget);
        expect(find.byTooltip(data.nextMonthTooltip), findsOneWidget);
      });
    }

    testWidgets(
        'rebuilding with a different locale fully replaces the old text, no leftovers',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: _LocalizedMonthLabel(locale: 'en')),
          ),
        ),
      );
      expect(find.text('Meskerem 2016'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: _LocalizedMonthLabel(locale: 'am')),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Meskerem 2016'), findsNothing);
      expect(find.text('${amLocaleData.monthNames[0]} 2016'), findsOneWidget);
    });

    testWidgets('an unsupported locale code falls back to English end-to-end',
        (tester) async {
      await tester.pumpWidget(_dialogHost(locale: 'fr'));

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();

      expect(find.text('Meskerem 2016'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a null locale falls back to English end-to-end',
        (tester) async {
      await tester.pumpWidget(_dialogHost());

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();

      expect(find.text('Meskerem 2016'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
