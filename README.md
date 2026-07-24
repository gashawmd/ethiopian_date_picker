# flutter_ethiopian_date_picker

[![pub package](https://img.shields.io/pub/v/flutter_ethiopian_date_picker.svg)](https://pub.dev/packages/flutter_ethiopian_date_picker)
[![likes](https://img.shields.io/pub/likes/flutter_ethiopian_date_picker)](https://pub.dev/packages/flutter_ethiopian_date_picker/score)
[![pub points](https://img.shields.io/pub/points/flutter_ethiopian_date_picker)](https://pub.dev/packages/flutter_ethiopian_date_picker/score)
[![CI](https://github.com/gashawmd/ethiopian_date_picker/actions/workflows/platform-matrix.yml/badge.svg)](https://github.com/gashawmd/ethiopian_date_picker/actions/workflows/platform-matrix.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

A customizable Material 3 Ethiopian (Ge'ez) date picker for Flutter with accurate Gregorian conversion, date-range selection, localization, theming, and seamless form integration.

## Why flutter_ethiopian_date_picker?

- Native Ethiopian (Ge'ez) calendar support
- Accurate Gregorian ⇄ Ethiopian conversion
- Material 3–styled date picker
- Embeddable calendar widget
- Date range selection
- Form integration
- Full localization support
- Customizable theming
- Keyboard and screen-reader accessible

## Screenshots

<table>
  <tr>
    <td align="center"><img src="doc/screenshots/01-home-light.jpg" width="260"><br><sub>Example app — home</sub></td>
    <td align="center"><img src="doc/screenshots/03-picker-default-theme.jpg" width="260"><br><sub>Date picker — default theme</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="doc/screenshots/05-range-picker.jpg" width="260"><br><sub>Range picker — selected range</sub></td>
    <td align="center"><img src="doc/screenshots/04-picker-custom-theme.jpg" width="260"><br><sub>Date picker — custom theme (deep orange)</sub></td>
  </tr>
</table>

<details>
<summary>More examples (dark theme, Amharic, Afaan Oromo, Tigrinya)</summary>

<table>
  <tr>
    <td align="center"><img src="doc/screenshots/02-home-dark.jpg" width="260"><br><sub>Example app — dark theme</sub></td>
    <td align="center"><img src="doc/screenshots/07-locale-am.jpg" width="260"><br><sub>Localized — Amharic (አማርኛ)</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="doc/screenshots/08-locale-om.jpg" width="260"><br><sub>Localized — Afaan Oromo, with keyboard-focus tooltip</sub></td>
    <td align="center"><img src="doc/screenshots/06-locale-ti.jpg" width="260"><br><sub>Localized — Tigrinya (ትግርኛ)</sub></td>
  </tr>
</table>

</details>

## Installation

```yaml
dependencies:
  flutter_ethiopian_date_picker: ^1.0.1
```

```sh
flutter pub get
```

```dart
import 'package:flutter_ethiopian_date_picker/flutter_ethiopian_date_picker.dart';
```

## Quick start

Show a date picker with the default configuration:

```dart
final date = await showEthiopianDatePicker(context: context);
```

## Customization

```dart
final date = await showEthiopianDatePicker(
  context: context,
  initialDate: EthiopianDate.today(),
  firstDate: EthiopianDate(2010, 1, 1),
  lastDate: EthiopianDate(2020, 13, 5),
  locale: EthiopianLocale.amharic.code,
  theme: EthiopianDatePickerTheme.material3(context).copyWith(
    primaryColor: Colors.deepOrange,
    selectedColor: Colors.deepOrange,
    backgroundColor: Colors.white,
  ),
);
```

> `EthiopianDatePickerTheme` has no lightweight constructor — every field
> (including `onSelectedColor`, `todayBorderColor`, `disabledColor`) is
> required. Build a custom theme by calling `.material3(context)` for the
> Material 3 defaults, then `.copyWith(...)` the colors you want to change.

### Range selection

```dart
final range = await showEthiopianDateRangePicker(
  context: context,
  firstDate: EthiopianDate(2010, 1, 1),
  lastDate: EthiopianDate(2020, 13, 5),
);

if (range != null) {
  print('${range.start} → ${range.end}');
}
```

### Converting between calendars

```dart
final ethiopian = EthiopianDate.fromGregorian(DateTime.now());
final gregorian = ethiopian.toGregorian();

// DateTime extension
final today = DateTime.now().toEthiopianDate();
```

## Embedded calendar

```dart
class MyEmbeddedCalendar extends StatefulWidget {
  const MyEmbeddedCalendar({super.key});

  @override
  State<MyEmbeddedCalendar> createState() => _MyEmbeddedCalendarState();
}

class _MyEmbeddedCalendarState extends State<MyEmbeddedCalendar> {
  EthiopianDate _displayedMonth = EthiopianDate.today();
  EthiopianDate? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return EthiopianCalendarView(
      displayedMonth: _displayedMonth,
      firstDate: EthiopianDate(2010, 1, 1),
      lastDate: EthiopianDate(2020, 13, 5),
      selectedDate: _selectedDate,
      onDateSelected: (date) => setState(() => _selectedDate = date),
      onMonthChanged: (month) => setState(() => _displayedMonth = month),
    );
  }
}
```

`EthiopianCalendarView` is fully stateless and controlled. The parent owns the displayed month and selected date (or selected range, which takes priority over `selectedDate` if both are set) and updates them through `onMonthChanged` and `onDateSelected`. It integrates naturally with `setState`, Provider, Riverpod, Bloc, or any other state management solution.

## Form field usage

```dart
Form(
  key: _formKey,
  child: EthiopianDateFormField(
    firstDate: EthiopianDate(2010, 1, 1),
    lastDate: EthiopianDate(2020, 13, 5),
    decoration: const InputDecoration(labelText: 'Birth date'),
    validator: (value) => value == null ? 'Required' : null,
    onSaved: (value) => _birthDate = value,
  ),
)
```

## Localization

```dart
showEthiopianDatePicker(
  context: context,
  locale: EthiopianLocale.oromo.code,
);
```

Supported locales:

- English (`en`)
- Amharic (`am`)
- Afaan Oromo (`om`)
- Tigrinya (`ti`)

Unsupported locale codes automatically fall back to English.

## Theming

Pass an `EthiopianDatePickerTheme` to override `primaryColor`, `selectedColor`,
`backgroundColor`, spacing, and typography. With no theme provided, the picker
uses Material 3 defaults derived from the ambient `Theme.of(context)`.

## API reference

| API | Description |
|---|---|
| `EthiopianDate` | Core date model: `year`, `month`, `day`, validation, `today()`, comparisons (`compareTo`, `isBefore`, `isAfter`, `isAtSameMomentAs`), `toJson`/`fromJson`. |
| `EthiopianDate.fromGregorian(DateTime)` | Convert a `DateTime` to `EthiopianDate`. |
| `EthiopianDate.toGregorian()` | Convert back to a Gregorian `DateTime`. |
| `DateTime.toEthiopianDate()` | Extension method, equivalent to `EthiopianDate.fromGregorian`. |
| `showEthiopianDatePicker({...})` | Opens the picker dialog, returns `Future<EthiopianDate?>`. `null` on cancel. |
| `showEthiopianDateRangePicker({...})` | Opens the range picker dialog, returns `Future<EthiopianDateRange?>`. |
| `EthiopianDateRange` | `start`, `end` date pair. |
| `EthiopianCalendarView` | Embeddable, stateless calendar grid widget. Required: `displayedMonth`, `firstDate`, `lastDate`, `onDateSelected`, `onMonthChanged`. Optional: `selectedDate`, `selectedRange` (takes priority over `selectedDate`), `locale`, `theme`. |
| `EthiopianDateFormField` | `FormField<EthiopianDate>` — works with standard `Form`/`FormState`. |
| `EthiopianDatePickerTheme` | Visual customization: colors, spacing, typography. |
| `EthiopianLocale` | `en`, `am`, `om`, `ti` — enum used for all localized text. |

For complete API documentation, see the package page on pub.dev.

## Features

- ✅ Gregorian ⇄ Ethiopian conversion (leap years, Pagume 5/6 days), fuzz-tested
- ✅ Material 3 date picker dialog
- ✅ Embeddable calendar widget
- ✅ Date range selection (same-day, cross-month, cross-year)
- ✅ Material 3 theming with full override support
- ✅ Localization: English, Amharic, Afaan Oromo, Tigrinya (fallback to English)
- ✅ `Form`/`FormState` integration via `EthiopianDateFormField`
- ✅ Accessibility: semantic labels, full keyboard navigation, ≥48px touch targets, screen reader smoke-tested (VoiceOver/TalkBack)
- ✅ No internal global/static mutable state — safe with Provider, Riverpod, and Bloc
- ✅ Golden-tested UI across all themes and locales
- ✅ Slide/fade month transitions, ripple selection, and dialog animations
- ✅ Verified building on Android, iOS, Web, Windows, macOS, and Linux


## Example app

The `example/` application demonstrates:

- Date picker dialog
- Embedded calendar widget
- Range selection
- Theme switching
- Locale switching
- Form integration

```sh
cd example
flutter pub get
flutter run
```

## Contributing / development

Contributions, bug reports, and feature requests are welcome.

- `flutter analyze` and `flutter test` must pass before opening a PR (enforced
  in CI).
- Any change to the public API must update `CHANGELOG.md`.

## License

MIT — see the [LICENSE](LICENSE) file for details.
