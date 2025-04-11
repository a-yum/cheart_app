import 'package:flutter/material.dart';

class CHeartTheme {
  // General Colors
  static const Color primaryColor = Color(0xFF6A5AE0);
  static const Color backgroundColor = Colors.white;
  static const Color cardBackgroundColor = Color(0xFFE3E7FF);
  static const Color textColor = Colors.black;
  static const Color accentColor = Color(0xFFB4A7E7);
  static const Color lightGrey = Color(0xFFBDBDBD);

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

  // Button Styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    textStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
  );

  static final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    side: const BorderSide(color: primaryColor),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: const TextStyle(fontWeight: FontWeight.w500),
    foregroundColor: primaryColor,
  );

   // Button Styling
  static const Color buttonColor = Color(0xFF6A5AE0); // Primary button
  static const Color buttonTextColor = Colors.white;
  static const Color buttonDisabledColor = Color(0xFFBDBDBD); // Gray for disabled
  static const Color buttonOverlayColor = Color(0x296A5AE0); // Transparent purple on press

  // Input Decoration
  static const InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: lightGrey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: lightGrey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
    labelStyle: TextStyle(color: textColor),
  );

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
    inputDecorationTheme: inputDecorationTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      titleTextStyle: titleText,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: bottomNavSelected,
      unselectedItemColor: bottomNavUnselected,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonStyle),
  );
}
