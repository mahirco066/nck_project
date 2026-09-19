import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.cairoTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppConstants.primaryGreen,
      scaffoldBackgroundColor: AppConstants.backgroundLight,
      colorScheme: ColorScheme.light(
        primary: AppConstants.primaryGreen,
        secondary: AppConstants.navyBlue,
        tertiary: AppConstants.accentGold,
        surface: AppConstants.cardBg,
        error: const Color(0xFFDC2626),
      ),
      fontFamily: GoogleFonts.cairo().fontFamily,
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.cairo(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppConstants.navyBlue,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppConstants.navyBlue,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppConstants.textDark,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppConstants.textDark,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppConstants.textDark,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: AppConstants.textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.primaryGreen,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: AppConstants.cardBg,
        elevation: 1.5,
        shadowColor: AppConstants.navyBlue.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.cairo(color: AppConstants.textMuted, fontSize: 14),
        hintStyle: GoogleFonts.cairo(color: AppConstants.textMuted.withOpacity(0.6), fontSize: 13),
        prefixIconColor: AppConstants.primaryGreen,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppConstants.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryGreen,
          side: const BorderSide(color: AppConstants.primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
