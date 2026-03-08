import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New Enhanced Palette from User
  static const Color primaryGold = Color(0xFFF59E0B);
  static const Color primaryGoldLight = Color(0xFFFBBF24);
  static const Color primaryGoldDark = Color(0xFFD97706);
  static const Color titleGold = Color(0xFFB8860B);
  
  static const Color bgLight = Color(0xFFFAFAF5);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgCream = Color(0xFFFFFEF7);
  
  // Support Colors
  static const Color errorColor = Color(0xFFCF6679);
  static const Color textDark = Color(0xFF1F2937); // Dark Slate for text
  static const Color textDim = Color(0xFF6B7280);  // Muted Gray
  static const Color textLight = Color(0xFFF3F4F6);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGold,
      scaffoldBackgroundColor: Colors.transparent, // Transparent for global gradient
      
      colorScheme: const ColorScheme.light(
        primary: primaryGold,
        onPrimary: Colors.white,
        secondary: titleGold,
        onSecondary: Colors.white,
        surface: bgWhite,
        onSurface: textDark,
        background: bgLight,
        onBackground: textDark,
        error: errorColor,
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.tenorSans(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: titleGold,
          letterSpacing: 1.2,
        ),
        displayMedium: GoogleFonts.tenorSans(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: titleGold,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDim,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white, // Button text
        ),
      ),

      // Component Themes
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.tenorSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: titleGold,
          letterSpacing: 1.0,
        ),
        iconTheme: const IconThemeData(color: titleGold),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryGold.withOpacity(0.1)),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryGold.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      iconTheme: const IconThemeData(
        color: primaryGold,
        size: 24,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: GoogleFonts.outfit(color: textDim),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryGold.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryGold.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
      ),
    );
  }

  // Helper for gold gradient
  static Gradient get goldGradient => const LinearGradient(
    colors: [primaryGoldLight, primaryGold, primaryGoldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}


