import 'package:flutter/material.dart';

/// Visual configuration for [EthiopianCalendarView] and
/// [showEthiopianDatePicker]. All fields have sensible Material 3
/// defaults, so you only need to override what you want to customize.
class EthiopianDatePickerTheme {
  const EthiopianDatePickerTheme({
    this.primaryColor = const Color(0xFF2E7D32),
    this.selectedColor = const Color(0xFF1565C0),
    this.todayColor = const Color(0xFFEF6C00),
    this.backgroundColor = Colors.white,
    this.disabledColor = const Color(0xFFBDBDBD),
    this.dayTextColor = const Color(0xFF212121),
    this.headerTextColor = Colors.white,
    this.weekdayLabelColor = const Color(0xFF757575),
    this.borderRadius = 16,
    this.cellBorderRadius = 12,
    this.dayTextStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    this.headerTextStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  });

  final Color primaryColor;
  final Color selectedColor;
  final Color todayColor;
  final Color backgroundColor;
  final Color disabledColor;
  final Color dayTextColor;
  final Color headerTextColor;
  final Color weekdayLabelColor;
  final double borderRadius;
  final double cellBorderRadius;
  final TextStyle dayTextStyle;
  final TextStyle headerTextStyle;

  EthiopianDatePickerTheme copyWith({
    Color? primaryColor,
    Color? selectedColor,
    Color? todayColor,
    Color? backgroundColor,
    Color? disabledColor,
    Color? dayTextColor,
    Color? headerTextColor,
    Color? weekdayLabelColor,
    double? borderRadius,
    double? cellBorderRadius,
    TextStyle? dayTextStyle,
    TextStyle? headerTextStyle,
  }) {
    return EthiopianDatePickerTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      selectedColor: selectedColor ?? this.selectedColor,
      todayColor: todayColor ?? this.todayColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      disabledColor: disabledColor ?? this.disabledColor,
      dayTextColor: dayTextColor ?? this.dayTextColor,
      headerTextColor: headerTextColor ?? this.headerTextColor,
      weekdayLabelColor: weekdayLabelColor ?? this.weekdayLabelColor,
      borderRadius: borderRadius ?? this.borderRadius,
      cellBorderRadius: cellBorderRadius ?? this.cellBorderRadius,
      dayTextStyle: dayTextStyle ?? this.dayTextStyle,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
    );
  }

  /// A ready-made dark theme variant.
  static EthiopianDatePickerTheme dark() => const EthiopianDatePickerTheme(
        primaryColor: Color(0xFF1B5E20),
        selectedColor: Color(0xFF1976D2),
        todayColor: Color(0xFFFF9800),
        backgroundColor: Color(0xFF121212),
        disabledColor: Color(0xFF424242),
        dayTextColor: Colors.white,
        headerTextColor: Colors.white,
        weekdayLabelColor: Color(0xFFB0B0B0),
      );
}
