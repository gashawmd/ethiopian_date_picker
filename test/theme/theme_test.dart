import 'package:flutter_ethiopian_date_picker/core/ethiopian_date.dart';
import 'package:flutter_ethiopian_date_picker/theme/picker_theme.dart';
import 'package:flutter_ethiopian_date_picker/ui/calendar_view.dart';
import 'package:flutter_ethiopian_date_picker/ui/date_picker_dialog.dart';
import 'package:flutter_ethiopian_date_picker/ui/day_cell.dart';
import 'package:flutter_ethiopian_date_picker/ui/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {ThemeData? appTheme}) {
  return MaterialApp(
    theme: appTheme,
    home: Scaffold(body: Center(child: child)),
  );
}

EthiopianDatePickerTheme _customTheme() {
  return const EthiopianDatePickerTheme(
    primaryColor: Color(0xFFFF00FF),
    selectedColor: Color(0xFF00FF00),
    backgroundColor: Color(0xFF000033),
    onSelectedColor: Color(0xFF111111),
    todayBorderColor: Color(0xFFFFAA00),
    disabledColor: Color(0xFF888888),
    spacing: EthiopianDatePickerSpacing(xs: 2, sm: 6, md: 12, lg: 20),
    typography: EthiopianDatePickerTypography(
      headerStyle: TextStyle(fontSize: 22, fontStyle: FontStyle.italic),
      dayStyle: TextStyle(fontSize: 18),
      weekdayLabelStyle: TextStyle(fontSize: 9, letterSpacing: 2),
    ),
  );
}

void main() {
  group('Default theme matches Material 3 (Task 3.1 DoD)', () {
    testWidgets('material3() derives primaryColor from ColorScheme.primary',
        (tester) async {
      const seedColor = Colors.deepPurple;
      final appTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      );

      late EthiopianDatePickerTheme resolved;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              resolved = EthiopianDatePickerTheme.material3(context);
              return const SizedBox.shrink();
            },
          ),
          appTheme: appTheme,
        ),
      );

      expect(resolved.primaryColor, appTheme.colorScheme.primary);
      expect(resolved.selectedColor, appTheme.colorScheme.primary);
      expect(resolved.backgroundColor, appTheme.colorScheme.surface);
      expect(resolved.onSelectedColor, appTheme.colorScheme.onPrimary);
    });

    testWidgets(
        'no theme passed to the dialog renders using the ambient app theme',
        (tester) async {
      final appTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      );

      await tester.pumpWidget(
        _wrap(
          EthiopianDatePickerDialog(
            initialDate: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
          ),
          appTheme: appTheme,
        ),
      );

      final Dialog dialog = tester.widget(find.byType(Dialog));
      expect(dialog.backgroundColor, appTheme.colorScheme.surface);
    });

    test('spacing defaults follow an 8px grid', () {
      const spacing = EthiopianDatePickerSpacing();
      expect(spacing.sm, 8);
      expect(spacing.md, 16);
      expect(spacing.lg, 24);
      expect(spacing.xs, 4);
    });
  });

  group('Custom theme changes visual elements (Task 3.1 DoD)', () {
    testWidgets('custom backgroundColor applies to the dialog surface',
        (tester) async {
      final custom = _customTheme();

      await tester.pumpWidget(
        _wrap(
          EthiopianDatePickerDialog(
            initialDate: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            theme: custom,
          ),
        ),
      );

      final Dialog dialog = tester.widget(find.byType(Dialog));
      expect(dialog.backgroundColor, custom.backgroundColor);
    });

    testWidgets('custom selectedColor applies to the selected day cell',
        (tester) async {
      final custom = _customTheme();

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            selectedDate: EthiopianDate(2016, 1, 10),
            theme: custom,
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final EthiopianDayCell selectedCell = tester.widget(
        find.byWidgetPredicate((w) => w is EthiopianDayCell && w.day == 10),
      );
      expect(selectedCell.theme, custom);
      expect(selectedCell.theme!.selectedColor, custom.selectedColor);
    });

    testWidgets('custom primaryColor applies to today border and nav arrows',
        (tester) async {
      final custom = _customTheme();
      final today = EthiopianDate.today();

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(today.year, today.month, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2030, 12, 30),
            theme: custom,
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );

      final IconButton nextButton = tester.widget(
        find.ancestor(
          of: find.byTooltip('Next month'),
          matching: find.byType(IconButton),
        ),
      );
      expect(nextButton.color, custom.primaryColor);
    });

    testWidgets('custom typography.headerStyle applies to the header text',
        (tester) async {
      final custom = _customTheme();

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarHeader(
            year: 2016,
            month: 1,
            theme: custom,
            onPreviousMonth: () {},
            onNextMonth: () {},
          ),
        ),
      );

      final Text headerText = tester.widget(find.text('Meskerem 2016'));
      expect(
          headerText.style?.fontSize, custom.typography.headerStyle.fontSize);
      expect(headerText.style?.fontStyle, FontStyle.italic);
    });

    testWidgets('custom spacing changes the gap between header and grid',
        (tester) async {
      final tightTheme = _customTheme().copyWith(
        spacing: const EthiopianDatePickerSpacing(xs: 0, sm: 0, md: 0, lg: 0),
      );
      final looseTheme = _customTheme().copyWith(
        spacing:
            const EthiopianDatePickerSpacing(xs: 40, sm: 40, md: 40, lg: 40),
      );

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            theme: tightTheme,
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );
      final double tightHeight =
          tester.getSize(find.byType(EthiopianCalendarView)).height;

      await tester.pumpWidget(
        _wrap(
          EthiopianCalendarView(
            displayedMonth: EthiopianDate(2016, 1, 1),
            firstDate: EthiopianDate(2000, 1, 1),
            lastDate: EthiopianDate(2020, 12, 30),
            theme: looseTheme,
            onDateSelected: (_) {},
            onMonthChanged: (_) {},
          ),
        ),
      );
      final double looseHeight =
          tester.getSize(find.byType(EthiopianCalendarView)).height;

      expect(looseHeight, greaterThan(tightHeight));
    });

    testWidgets('copyWith overrides only the specified fields, keeps the rest',
        (tester) async {
      final base = _customTheme();
      final tweaked = base.copyWith(primaryColor: Colors.cyan);

      expect(tweaked.primaryColor, Colors.cyan);
      expect(tweaked.selectedColor, base.selectedColor);
      expect(tweaked.backgroundColor, base.backgroundColor);
      expect(tweaked.spacing, base.spacing);
      expect(tweaked.typography, base.typography);
    });
  });
}
