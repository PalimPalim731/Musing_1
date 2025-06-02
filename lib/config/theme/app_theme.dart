// config/theme/app_theme.dart

import 'package:flutter/material.dart';

/// Centralized theme configuration for the app with category-specific colors
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Category-specific colors
  static const Color privateColor = Color(0xFF1976D2); // Blue
  static const Color circleColor = Color(0xFFE91E63); // Pink/Red
  static const Color publicColor = Color(0xFF9C27B0); // Purple

  // Secondary variants for each category (lighter shades)
  static const Color privateColorLight = Color(0xFF42A5F5);
  static const Color circleColorLight = Color(0xFFF06292);
  static const Color publicColorLight = Color(0xFFBA68C8);

  // Legacy colors (keeping for backward compatibility)
  static const Color primaryColor = Color(0xFF6670F9);
  static const Color secondaryColor = Color(0xFF8F97FB);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color textColor = Color(0xFF333333);
  static const Color textColorDark = Color(0xFFEEEEEE);
  static const String fontFamily = 'Roboto';

  // Get category color by name
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'private':
        return privateColor;
      case 'circle':
        return circleColor;
      case 'public':
        return publicColor;
      default:
        return privateColor; // Default to private color
    }
  }

  // Get light variant of category color
  static Color getCategoryColorLight(String category) {
    switch (category.toLowerCase()) {
      case 'private':
        return privateColorLight;
      case 'circle':
        return circleColorLight;
      case 'public':
        return publicColorLight;
      default:
        return privateColorLight;
    }
  }

  // Get category color with opacity
  static Color getCategoryColorWithOpacity(String category, double opacity) {
    return getCategoryColor(category).withOpacity(opacity);
  }

  // Text styles with proper hierarchy
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle categoryTextStyle = buttonTextStyle;

  static const TextStyle tagTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle inputTextStyle = TextStyle(
    fontSize: 16,
    color: textColor,
  );

  // Shadow definitions with category support
  static List<BoxShadow> getLightShadow([String? category]) {
    final color = category != null ? getCategoryColor(category) : primaryColor;
    return [
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static List<BoxShadow> get tagShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  // Light theme configuration
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      bodyLarge: inputTextStyle,
      bodyMedium: TextStyle(color: textColor),
      labelLarge: buttonTextStyle,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: buttonTextStyle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
    ),
  );

  // Dark theme configuration
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColorDark),
      bodyMedium: TextStyle(color: textColorDark),
      labelLarge: buttonTextStyle,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: buttonTextStyle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade800,
      thickness: 1,
    ),
  );
}
