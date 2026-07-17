import 'package:flutter/material.dart';

/// Spacing scale used throughout the picker's layout. Baked to an 8px
/// grid, matching Material 3's own spacing conventions, so custom
/// themes stay visually consistent with the rest of a Material app
/// even when colors/typography are overridden.
class EthiopianDatePickerSpacing {
  const EthiopianDatePickerSpacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 16,
    this.lg = 24,
  });

  /// Tightest spacing - e.g. the gap between a day cell and its border.
  final double xs;

  /// Default spacing between related elements (header <-> weekday row).
  final double sm;

  /// Spacing around a self-contained section (dialog content padding).
  final double md;

  /// Spacing between clearly separate sections.
  final double lg;
}

/// Text styles for the three distinct pieces of text the picker
/// renders. Grouped together (rather than three loose parameters)
/// so a custom theme can't accidentally leave one unset.
class EthiopianDatePickerTypography {
  const EthiopianDatePickerTypography({
    required this.headerStyle,
    required this.dayStyle,
    required this.weekdayLabelStyle,
  });

  /// Style for the "Month Year" label in the header.
  final TextStyle headerStyle;

  /// Style for the day-number text inside each grid cell.
  final TextStyle dayStyle;

  /// Style for the Mon/Tue/Wed... row above the day grid.
  final TextStyle weekdayLabelStyle;

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

/// Visual theme for the Ethiopian date picker: colors, spacing, and
/// typography for the calendar grid, header, and dialog chrome.
///
/// Pass a custom instance to [showEthiopianDatePicker] or
/// [EthiopianDatePickerDialog] to override any of these. Every widget
/// in this package falls back to [EthiopianDatePickerTheme.material3]
/// when no theme is given, so the default appearance always matches
/// the ambient app theme rather than a fixed hardcoded palette.
class EthiopianDatePickerTheme {
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

  /// Accent color used for interactive chrome - e.g. the header's
  /// navigation arrows and today's border.
  final Color primaryColor;

  /// Fill color for the selected day cell.
  final Color selectedColor;

  /// Background color behind the whole calendar (and, in the dialog,
  /// the dialog surface itself).
  final Color backgroundColor;

  /// Text color used on top of [selectedColor] - needs to stay
  /// readable regardless of what [selectedColor] is set to, so it's
  /// tracked separately rather than assumed.
  final Color onSelectedColor;

  /// Border color for today's cell when it isn't also selected.
  final Color todayBorderColor;

  /// Text color for disabled (out-of-range) day cells.
  final Color disabledColor;

  /// 8px-grid spacing values used throughout the layout.
  final EthiopianDatePickerSpacing spacing;

  /// Text styles for the header, day numbers, and weekday labels.
  final EthiopianDatePickerTypography typography;

  /// Builds a theme derived from the ambient [Theme.of(context)],
  /// following Material 3 guidelines: primary/selection colors come
  /// from the app's [ColorScheme], text styles come from the app's
  /// [TextTheme]. This is what every widget in this package falls
  /// back to when no explicit theme is passed, so the picker always
  /// looks at home inside whatever Material app it's dropped into.
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