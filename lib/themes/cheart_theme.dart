import 'package:flutter/material.dart';

class CHeartTheme {
  // General Colors
  static const Color primaryColor = Color(0xFF6A5AE0);
  static const Color backgroundColor = Colors.white;
  static const Color cardBackgroundColor = Color(0xFFE3E7FF);
  static const Color textColor = Colors.black;
  static const Color accentColor = Color(0xFFB4A7E7);

  // General Text Styles
  static const TextStyle titleText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: textColor,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  // General Padding and Margins
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets sectionSpacing = EdgeInsets.symmetric(vertical: 8.0);

  // Card Styling
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackgroundColor,
    borderRadius: BorderRadius.circular(12),
  );

  // Bottom Navigation Bar Styling
  static const Color bottomNavSelected = textColor;
  static const Color bottomNavUnselected = Colors.grey;

  // ThemeData
  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: const TextTheme(
      displayLarge: titleText,
      titleLarge: sectionTitle,
      bodyLarge: bodyText,
    ),
    cardColor: cardBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      titleTextStyle: titleText,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: bottomNavSelected,
      unselectedItemColor: bottomNavUnselected,
    ),
  );
}
