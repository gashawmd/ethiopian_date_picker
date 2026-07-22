# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## Versioning policy

- **MAJOR** — any change that breaks existing public API usage: removing or
  renaming a public class/method/parameter, changing a parameter's required
  status or type, changing default behavior in a way existing callers would
  notice (e.g. a picker that used to allow a config now throws).
- **MINOR** — backwards-compatible additions: new optional parameters, new
  widgets, new locales, new theme properties with safe defaults.
- **PATCH** — bug fixes, performance improvements, documentation, internal
  refactors with no observable API change.

Every merged PR that touches the public API must add an entry under
`[Unreleased]` before merge. Release commits move `[Unreleased]` into a new
dated version section.

## [Unreleased]

### Added
- Example app (`example/`) demonstrating picker, theme switch, locale switch,
  and form field usage (Task 7.1).
- Full README with installation, usage, API reference, supported features
  list, and a screenshot gallery covering light/dark theme, default/custom
  picker theme, range selection, and Amharic/Afaan Oromo/Tigrinya locales
  (Task 7.2).

## [0.4.0] — Interop, Testing & Polish

### Added
- State management smoke tests confirming `EthiopianCalendarView` works
  correctly when driven externally by Provider, Riverpod, and Bloc, with no
  internal shared mutable state.
- Golden test suite covering all theme and locale variants.
- `PLATFORM_SUPPORT.md` manual verification script and support matrix
  (verification itself still pending).

### Fixed
- `RenderFlex` overflow when laying out two calendar instances for the
  no-shared-state test; switched from vertical `Column`/`Expanded` to a
  horizontal `Row` layout.

## [0.3.0] — Localization & Accessibility

### Added
- Locale files for English, Amharic, Afaan Oromo, and Tigrinya with
  fallback-to-English behavior.
- `EthiopianDateFormField` for `Form`/`FormState` integration, with
  `validator` and `onSaved` support.
- Full keyboard navigation, semantic labels, ≥48px touch targets, and
  high-contrast/scalable-font support.

## [0.2.0] — Animation & Range Selection

### Added
- Slide/fade transitions on month change, ripple effect on day selection,
  dialog open/close animation.
- `EthiopianDateRange` model and range selection interaction flow
  (tap start, tap end, re-tap to reset).

## [0.1.0] — Theming

### Added
- `EthiopianDatePickerTheme` with Material 3 defaults and full override
  support for colors, spacing, and typography.

## [0.0.1] — Core Engine & Basic Picker

### Added
- `EthiopianDate` model with validation, comparisons, and JSON
  serialization.
- Gregorian ⇄ Ethiopian conversion with leap year and Pagume handling,
  fuzz-tested across thousands of random dates.
- Calendar grid widget and `showEthiopianDatePicker()` dialog.
- Error handling: clamping to `firstDate`/`lastDate`, debug assertions for
  invalid config, safe locale fallback.