import 'package:flutter/material.dart';

/// Spacing constants used throughout the Ethiopian date picker's layout.
class EthiopianDatePickerSpacing {
  /// Creates a spacing configuration. All values default to an 8px
  /// base scale (4/8/16/24).
  const EthiopianDatePickerSpacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 16,
    this.lg = 24,
  });

  /// Extra-small spacing, in logical pixels.
  final double xs;

  /// Small spacing, in logical pixels.
  final double sm;

  /// Medium spacing, in logical pixels.
  final double md;

  /// Large spacing, in logical pixels.
  final double lg;
}

/// Text styles used for the picker's header, day cells, and weekday row.
class EthiopianDatePickerTypography {
  /// Creates a typography configuration from explicit text styles.
  const EthiopianDatePickerTypography({
    required this.headerStyle,
    required this.dayStyle,
    required this.weekdayLabelStyle,
  });

  /// Style used for the month/year header label.
  final TextStyle headerStyle;

  /// Style used for individual day-cell numbers.
  final TextStyle dayStyle;

  /// Style used for the weekday abbreviation row (Mon, Tue, ...).
  final TextStyle weekdayLabelStyle;

  /// Derives sensible header/day/weekday styles from an ambient
  /// Material [TextTheme], falling back to reasonable defaults if
  /// any style is unset.
  factory EthiopianDatePickerTypography.fromTextTheme(TextTheme text) {
    return EthiopianDatePickerTypography(
      headerStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w600) ??
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      dayStyle: text.bodyMedium ?? const TextStyle(fontSize: 14),
      weekdayLabelStyle:
          text.labelSmall?.copyWith(fontWeight: FontWeight.w600) ??
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    );
  }
}

/// Visual configuration for the Ethiopian date picker: colors, spacing,
/// and typography.
///
/// Every field is required; there is no lightweight constructor. Use
/// [EthiopianDatePickerTheme.material3] to derive a full theme from
/// the ambient [Theme], then [copyWith] to override individual colors.
class EthiopianDatePickerTheme {
  /// Creates a theme from fully explicit values.
  const EthiopianDatePickerTheme({
    required this.primaryColor,
    required this.selectedColor,
    required this.backgroundColor,
    required this.onSelectedColor,
    required this.todayBorderColor,
    required this.disabledColor,
    required this.spacing,
    required this.typography,
  });

  /// The picker's primary accent color (e.g. navigation arrows, focus ring).
  final Color primaryColor;

  /// Background color of the selected day cell.
  final Color selectedColor;

  /// Background color of the picker dialog/surface.
  final Color backgroundColor;

  /// Color of the day-number text on a selected cell.
  final Color onSelectedColor;

  /// Border color used to outline today's date.
  final Color todayBorderColor;

  /// Color used for dates outside the selectable range.
  final Color disabledColor;

  /// Spacing constants used across the picker's layout.
  final EthiopianDatePickerSpacing spacing;

  /// Text styles used across the picker's layout.
  final EthiopianDatePickerTypography typography;

  /// Builds a theme derived from the ambient Material 3 [ColorScheme]
  /// and [TextTheme] found via `Theme.of(context)`.
  factory EthiopianDatePickerTheme.material3(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return EthiopianDatePickerTheme(
      primaryColor: colors.primary,
      selectedColor: colors.primary,
      backgroundColor: colors.surface,
      onSelectedColor: colors.onPrimary,
      todayBorderColor: colors.primary,
      disabledColor: colors.onSurface.withValues(alpha: 0.38),
      spacing: const EthiopianDatePickerSpacing(),
      typography: EthiopianDatePickerTypography.fromTextTheme(
        theme.textTheme,
      ),
    );
  }

  /// Returns a copy of this theme with the given fields replaced.
  EthiopianDatePickerTheme copyWith({
    Color? primaryColor,
    Color? selectedColor,
    Color? backgroundColor,
    Color? onSelectedColor,
    Color? todayBorderColor,
    Color? disabledColor,
    EthiopianDatePickerSpacing? spacing,
    EthiopianDatePickerTypography? typography,
  }) {
    return EthiopianDatePickerTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      selectedColor: selectedColor ?? this.selectedColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      onSelectedColor: onSelectedColor ?? this.onSelectedColor,
      todayBorderColor: todayBorderColor ?? this.todayBorderColor,
      disabledColor: disabledColor ?? this.disabledColor,
      spacing: spacing ?? this.spacing,
      typography: typography ?? this.typography,
    );
  }
}
