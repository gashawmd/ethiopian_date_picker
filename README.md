# ethiopian_date_picker 🇪🇹

A modern, accurate, Material 3 Ethiopian (Ge'ez) calendar date picker for Flutter.

- ✅ Accurate Gregorian ⇄ Ethiopian conversion (Pagumē / 13th month, leap years)
- ✅ Dialog picker **and** a standalone embeddable calendar widget
- ✅ Theming (light/dark, custom colors)
- ✅ Range selection
- ✅ Localization (English + Amharic built in; trivial to add more)
- ✅ Material 3, accessible (48px touch targets, semantic labels)

## Installation

```yaml
dependencies:
  ethiopian_date_picker: ^0.0.1
```

```dart
import 'package:ethiopian_date_picker/ethiopian_date_picker.dart';
```

## Simple usage

```dart
final date = await showEthiopianDatePicker(context: context);
```

## Advanced usage

```dart
final date = await showEthiopianDatePicker(
  context: context,
  initialDate: EthiopianDate.today(),
  firstDate: EthiopianDate(2015, 1, 1),
  lastDate: EthiopianDate(2017, 13, 5),
  theme: EthiopianDatePickerTheme.dark(),
  locale: EthiopianLocale.amharic,
);
```

## Widget usage (embed it anywhere)

```dart
EthiopianCalendarView(
  selectedDate: myDate,
  onDateSelected: (date) => setState(() => myDate = date),
)
```

## Range selection

```dart
EthiopianCalendarView(
  rangeMode: true,
  onRangeSelected: (range) => print('${range.start} - ${range.end}'),
)
```

## Converting dates

```dart
final eth = EthiopianDate.fromGregorian(DateTime.now());
final gregorian = eth.toGregorian();
final today = EthiopianDate.today();
```

## Supported features

| Feature | Status |
|---|---|
| Dialog picker | ✅ |
| Embeddable calendar widget | ✅ |
| Gregorian ⇄ Ethiopian conversion | ✅ |
| Pagumē (13th month) + leap years | ✅ |
| Theming | ✅ |
| Range selection | ✅ |
| Localization (en/am built in) | ✅ |
| Holidays / event markers | 🔵 planned (v2+) |
| Multi-date selection | 🔵 planned (v2+) |

## Accuracy note

The conversion engine is anchored to the well-documented Ethiopian
Millennium (Meskerem 1, 2000 = 11 September 2007) and uses the standard
Ethiopian leap-year rule (`year % 4 == 3`). It is covered by round-trip
tests across 500+ pseudo-random dates and 100+ sequential calendar years,
plus explicit Pagumē/leap-year edge cases. See `test/converter_test.dart`.

## Adding a language

Localization files live in `lib/localization/` as one file per language
(matching the PRD's `en.dart` / `am.dart` layout). To add Tigrinya, Afaan
Oromo, Somali, Sidama, or any other language:

1. Create `lib/localization/tigrinya.dart`:
   ```dart
   import 'ethiopian_locale_data.dart';

   const EthiopianLocaleData ethiopianLocaleTi = EthiopianLocaleData(
     monthNames: <String>[/* 13 names */],
     weekdayShortNames: <String>[/* 7 names, Monday first */],
     today: '...',
     ok: '...',
     cancel: '...',
   );
   ```
2. Export it from `lib/ethiopian_date_picker.dart` if you want it public,
   or just import it directly wherever you build your picker.
3. Pass it in: `showEthiopianDatePicker(context: context, locale: ethiopianLocaleTi)`.

No changes to `EthiopianLocale` or any other package internals are needed
— that class only holds the two built-in defaults (English fallback +
Amharic). This is intentionally left to you since translation accuracy
matters and is best verified by native speakers.

## Example app

See `example/lib/main.dart` for a full demo: dialog picker, embedded
widget, dark/light theme toggle, and locale switching.

## Architecture

```
lib/
├── core/            # Pure Dart, no Flutter dependency
│   ├── converter.dart          # JDN-based Gregorian <-> Ethiopian math
│   ├── calendar_logic.dart     # Leap years, month lengths, weekdays
│   ├── ethiopian_date.dart     # EthiopianDate value type
│   └── ethiopian_date_range.dart
├── ui/
│   ├── calendar_view.dart      # EthiopianCalendarView (the widget API)
│   ├── date_picker_dialog.dart # showEthiopianDatePicker
│   ├── day_cell.dart
│   └── header.dart
├── theme/
│   └── picker_theme.dart
├── localization/
│   └── ethiopian_locale.dart
├── utils/
│   └── date_utils.dart
└── ethiopian_date_picker.dart  # Barrel export
```

## Roadmap

- **v0.0.1** – core model, conversion engine, basic picker UI ✅
- **v0.1.0** – theme system, improved UI ✅
- **v0.2.0** – animations, range selection (range logic ✅, transition animation planned)
- **v0.3.0** – localization expansion, accessibility polish
- **v1.0.0** – stable release
