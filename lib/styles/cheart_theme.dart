import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheartTheme {
  // Primary Color for seed generation
  static const Color primaryRed = Color(0xFFB71C1C);
  // Additional colors for specific use cases
  static const Color accentMint = Color(0xFF26A69A);
  static const Color textLight = Color(0xFF616161);

  // Gradient for heart rate visualization
  static const List<Color> heartRateGradient = [
    Color(0xFFE53935),
    Color(0xFFEF5350),
  ];

  // Helper method for accessible text styles
  static TextStyle _createAccessibleTextStyle({
    required String fontFamily,
    required double fontSize,
    required Color color,
    required FontWeight weight,
  }) {
    return GoogleFonts.getFont(
      fontFamily,
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
      height: 1.5,
      letterSpacing: 0.15,
    );
  }

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          brightness: Brightness.light,
        ).copyWith(
          primaryContainer: primaryRed,
          onPrimaryContainer: Colors.white,
          secondaryContainer: accentMint,
          onSecondaryContainer: Colors.black,
          // Error states
          error: Color(0xFFD32F2F),
          onError: Colors.white,
          // Surface colors
          surface: Color(0xFFF5F5F5),
          onSurface: Color(0xFF212121),
        ),

        // Typography
        textTheme: TextTheme(
          headlineLarge: _createAccessibleTextStyle(
            fontFamily: 'Outfit',
            fontSize: 32,
            color: Color(0xFF212121),
            weight: FontWeight.bold,
          ),
          headlineMedium: _createAccessibleTextStyle(
            fontFamily: 'Outfit',
            fontSize: 24,
            color: Color(0xFF212121),
            weight: FontWeight.w600,
          ),
          bodyLarge: _createAccessibleTextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFF212121),
            weight: FontWeight.normal,
          ),
          bodyMedium: _createAccessibleTextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: textLight,
            weight: FontWeight.normal,
          ),
        ),

        // Card Theme
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(44, 44),
          ),
        ),
      );
}
