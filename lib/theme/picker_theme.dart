import 'package:flutter/material.dart';

class EthiopianDatePickerSpacing {
  const EthiopianDatePickerSpacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 16,
    this.lg = 24,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
}

class EthiopianDatePickerTypography {
  const EthiopianDatePickerTypography({
    required this.headerStyle,
    required this.dayStyle,
    required this.weekdayLabelStyle,
  });

  final TextStyle headerStyle;
  final TextStyle dayStyle;
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

  final Color primaryColor;
  final Color selectedColor;
  final Color backgroundColor;
  final Color onSelectedColor;
  final Color todayBorderColor;
  final Color disabledColor;
  final EthiopianDatePickerSpacing spacing;
  final EthiopianDatePickerTypography typography;

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
