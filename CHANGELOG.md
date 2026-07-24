# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.1] - 2026-07-24

### Fixed
- Updated package metadata, fixed minor documentation typos, and aligned version references across the project.

## [1.0.0] - 2026-07-23

### Added
- Added a complete example application demonstrating picker usage, theme
  switching, locale switching, range selection, and form integration.
- Added a full README with installation, usage, API reference, a features
  list, and a screenshot gallery covering light/dark theme, default/custom
  picker theme, range selection, and Amharic/Afaan Oromo/Tigrinya locales.
- Added GitHub Actions platform verification for Android, Web, Linux,
  Windows, macOS, and iOS.
- Manually verified functionality on Linux desktop and Web, including a
  performance pass showing smooth month navigation.

### Changed
- Renamed the package from `ethiopian_date_picker` to
  `flutter_ethiopian_date_picker` before the initial public release to avoid
  a naming collision with an existing package on pub.dev.

### Fixed
- Removed a deprecated lint rule (`avoid_returning_null_for_future`) that was
  removed upstream in Dart 3.3.0 and caused `flutter analyze` to fail on
  current SDKs.
- Corrected the README installation snippet and license section to match the
  published version and license file.

## [0.4.0] - Internal milestone

### Added
- State management smoke tests confirming `EthiopianCalendarView` works
  correctly when driven externally by Provider, Riverpod, and Bloc, with no
  internal shared mutable state.
- Golden test suite covering all theme and locale variants.
- `PLATFORM_SUPPORT.md` manual verification script and support matrix.

### Fixed
- `RenderFlex` overflow when laying out two calendar instances for the
  no-shared-state test; switched from vertical `Column`/`Expanded` to a
  horizontal `Row` layout.

## [0.3.0] - Internal milestone

### Added
- Locale files for English, Amharic, Afaan Oromo, and Tigrinya with
  fallback-to-English behavior.
- `EthiopianDateFormField` for `Form`/`FormState` integration, with
  `validator` and `onSaved` support.
- Full keyboard navigation, semantic labels, ≥48px touch targets, and
  high-contrast/scalable-font support.

## [0.2.0] - Internal milestone

### Added
- Slide/fade transitions on month change, ripple effect on day selection,
  dialog open/close animation.
- `EthiopianDateRange` model and range selection interaction flow
  (tap start, tap end, re-tap to reset).

## [0.1.0] - Internal milestone

### Added
- `EthiopianDatePickerTheme` with Material 3 defaults and full override
  support for colors, spacing, and typography.

## [0.0.1] - Internal milestone

### Added
- `EthiopianDate` model with validation, comparisons, and JSON
  serialization.
- Gregorian ⇄ Ethiopian conversion with leap year and Pagume handling,
  fuzz-tested across thousands of random dates.
- Calendar grid widget and `showEthiopianDatePicker()` dialog.
- Error handling: clamping to `firstDate`/`lastDate`, debug assertions for
  invalid config, safe locale fallback.

[Unreleased]: https://github.com/gashawmd/ethiopian_date_picker/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/gashawmd/ethiopian_date_picker/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/gashawmd/ethiopian_date_picker/releases/tag/v1.0.0