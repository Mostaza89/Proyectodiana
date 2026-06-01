import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryNavy = Color(0xFF0B132B);
  static const Color primaryGold = Color(0xFFB8860B);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  
  static const Color statusAvailable = Color(0xFF4CAF50);
  static const Color statusOccupied = Color(0xFFF44336);
  static const Color statusMaintenance = Color(0xFFFFC107);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primaryNavy,
      colorScheme: ColorScheme.light(
        primary: primaryNavy,
        secondary: primaryGold,
        surface: Colors.white,
        error: statusOccupied,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: primaryNavy,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryNavy),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGold),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
