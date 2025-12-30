import 'package:flutter/material.dart';

class AppColors {
  // === PREMIUM DESIGN TOKENS ===
  
  // Primary (Indigo/Violet) - Very Professional
  static const Color primaryStart = Color(0xFF6366F1); // Indigo 500
  static const Color primaryEnd = Color(0xFF8B5CF6);   // Violet 500
  
  // Accents
  static const Color accentRose = Color(0xFFF43F5E);   // Rose 500
  static const Color accentAmber = Color(0xFFF59E0B);  // Amber 500
  static const Color accentCyan = Color(0xFF06B6D4);   // Cyan 500
  static const Color accentEmerald = Color(0xFF10B981); // Emerald 500
  
  // Light Mode (Neutral/Slate)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  
  // Dark Mode (Deep Slate/Navy)
  static const Color darkBackground = Color(0xFF020617); // Slate 950
  static const Color darkSurface = Color(0xFF0F172A);    // Slate 900
  static const Color darkSurfaceVariant = Color(0xFF1E293B); // Slate 800
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  
  // Mesh Gradient Colors (For backgrounds)
  static const Color meshIndigo = Color(0x406366F1);
  static const Color meshViolet = Color(0x408B5CF6);
  static const Color meshCyan = Color(0x4006B6D4);
  static const Color meshRose = Color(0x40F43F5E);
  
  // Glassmorphism Helpers
  static Color glassColor(bool isDark) => isDark 
      ? Colors.white.withOpacity(0.05) 
      : Colors.white.withOpacity(0.7);
  
  static Color glassBorder(bool isDark) => isDark 
      ? Colors.white.withOpacity(0.1) 
      : Colors.white.withOpacity(0.5);

  // Legacy compatibility / Aliases
  static const Color gradientStart = primaryStart;
  static const Color gradientEnd = primaryEnd;
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentRose, accentAmber],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F172A), Color(0xFF020617)],
  );
}
