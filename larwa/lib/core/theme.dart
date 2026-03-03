// lib/core/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class LarwaTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(AppConstants.colorBackground),
      primaryColor: const Color(AppConstants.colorPrimary),
      colorScheme: const ColorScheme.dark(
        primary: Color(AppConstants.colorPrimary),
        secondary: Color(AppConstants.colorPrimary),
        surface: Color(AppConstants.colorCardBg),
        error: Color(AppConstants.colorUrgent),
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
              headlineLarge: const TextStyle(
                color: Color(AppConstants.colorTextPrimary),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              headlineMedium: const TextStyle(
                color: Color(AppConstants.colorTextPrimary),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              titleLarge: const TextStyle(
                color: Color(AppConstants.colorTextPrimary),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              titleMedium: const TextStyle(
                color: Color(AppConstants.colorTextPrimary),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              bodyLarge: const TextStyle(
                color: Color(AppConstants.colorTextPrimary),
                fontSize: 15,
              ),
              bodyMedium: const TextStyle(
                color: Color(AppConstants.colorTextSecondary),
                fontSize: 13,
              ),
              bodySmall: const TextStyle(
                color: Color(AppConstants.colorTextSecondary),
                fontSize: 11,
              ),
            ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppConstants.colorCardBg),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white70),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(AppConstants.colorCardBg),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.colorPrimary),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(AppConstants.colorSurface),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(AppConstants.colorPrimary),
            width: 1.5,
          ),
        ),
        hintStyle: const TextStyle(
          color: Color(AppConstants.colorTextSecondary),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(AppConstants.colorSurface),
        selectedColor: const Color(AppConstants.colorPrimary),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(AppConstants.colorCardBg),
        selectedItemColor: Color(AppConstants.colorPrimary),
        unselectedItemColor: Color(AppConstants.colorTextSecondary),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2D3E),
        thickness: 0.5,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(AppConstants.colorSurface),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
