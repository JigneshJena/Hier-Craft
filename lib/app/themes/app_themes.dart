import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.accentPink,
      tertiary: AppColors.accentAmber,
      surface: AppColors.lightSurface,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    
    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.lightSurface,
      shadowColor: Colors.black.withOpacity(0.05),
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.lightTextPrimary,
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    
    // Text Theme
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      displayMedium: GoogleFonts.poppins(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      titleLarge: GoogleFonts.poppins(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleMedium: GoogleFonts.poppins(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: GoogleFonts.inter(
        color: AppColors.lightTextPrimary,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.inter(
        color: AppColors.lightTextSecondary,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.inter(
        color: AppColors.lightTextSecondary,
        fontSize: 12,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.accentPink,
      tertiary: AppColors.accentAmber,
      surface: AppColors.darkSurface,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      error: AppColors.error,
      onPrimary: AppColors.darkBackground,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    
    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.darkSurface,
      shadowColor: Colors.black.withOpacity(0.2),
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.darkTextPrimary,
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkBackground,
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    
    // Text Theme
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      displayMedium: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      titleLarge: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleMedium: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: GoogleFonts.inter(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.inter(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.inter(
        color: AppColors.darkTextSecondary,
        fontSize: 12,
      ),
    ),
  );
}

