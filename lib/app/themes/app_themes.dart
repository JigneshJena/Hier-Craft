import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppThemes {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryStart,
      secondary: AppColors.primaryDark,
      tertiary: AppColors.accentCrimson,
      surface: AppColors.lightSurface,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightSurface,
    dividerColor: const Color(0xFFE2E8F0),
    
    // Card Theme - More rounded and subtle
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: AppColors.lightSurface,
      margin: EdgeInsets.zero,
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.lightTextPrimary,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    
    // Elevated Button Theme - Premium & Modern
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.primaryStart,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.primaryStart, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: GoogleFonts.outfit(color: AppColors.lightTextSecondary),
      hintStyle: GoogleFonts.outfit(color: AppColors.lightTextSecondary.withOpacity(0.5)),
    ),
    
    // Text Theme - Modern Typography Pairing
    textTheme: TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 32,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 24,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: GoogleFonts.outfit(
        color: AppColors.lightTextPrimary,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.outfit(
        color: AppColors.lightTextSecondary,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.outfit(
        color: AppColors.lightTextSecondary,
        fontSize: 12,
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryStart,
      secondary: AppColors.primaryEnd,
      tertiary: AppColors.accentCrimson,
      surface: AppColors.darkSurface,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkSurface,
    dividerColor: const Color(0xFF1E2638),
    
    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: AppColors.darkSurface,
      margin: EdgeInsets.zero,
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.darkTextPrimary,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.primaryEnd,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.primaryEnd, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: GoogleFonts.outfit(color: AppColors.darkTextSecondary),
      hintStyle: GoogleFonts.outfit(color: AppColors.darkTextSecondary.withOpacity(0.5)),
    ),
    
    // Text Theme
    textTheme: TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.darkTextPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 32,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        color: AppColors.darkTextPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 24,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.darkTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        color: AppColors.darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: GoogleFonts.outfit(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.outfit(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.outfit(
        color: AppColors.darkTextSecondary,
        fontSize: 12,
      ),
    ),
  );
}
