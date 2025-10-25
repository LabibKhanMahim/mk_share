import 'package:flutter/material.dart';

class AppTheme {
  // Cyberpunk/neon color palette
  static const Color primaryColor = Color(0xFF00FF41); // Neon green
  static const Color secondaryColor = Color(0xFF00FFFF); // Cyan
  static const Color backgroundColor = Color(0xFF0A0A0A); // Dark black
  static const Color surfaceColor = Color(0xFF1A1A1A); // Dark gray
  static const Color errorColor = Color(0xFFFF0040); // Neon red
  static const Color warningColor = Color(0xFFFFAA00); // Neon orange

  // Dark theme with cyberpunk/neon accents
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Courier',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: surfaceColor,
        foregroundColor: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: primaryColor, width: 1),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: primaryColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'Courier',
      ),
      headlineMedium: TextStyle(
        color: secondaryColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Courier',
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'Courier',
      ),
      bodyMedium: TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontFamily: 'Courier',
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: primaryColor, width: 0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: secondaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: primaryColor),
      hintStyle: const TextStyle(color: Colors.white54),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryColor,
      inactiveTrackColor: surfaceColor,
      thumbColor: secondaryColor,
      overlayColor: secondaryColor.withValues(alpha: 0.2),
      valueIndicatorColor: surfaceColor,
      valueIndicatorTextStyle: const TextStyle(color: primaryColor),
    ),
  );
}
