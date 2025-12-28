import 'package:flutter/material.dart';

class AppColors {
  // === MODERN GRADIENT COLORS ===
  
  // Primary Gradient (Purple → Blue → Cyan)
  static const Color gradientStart = Color(0xFF8B5CF6); // Purple
  static const Color gradientMid = Color(0xFF3B82F6);   // Blue
  static const Color gradientEnd = Color(0xFF06B6D4);   // Cyan
  
  // Accent Colors
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentEmerald = Color(0xFF10B981);
  
  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightPrimary = Color(0xFF8B5CF6);
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  
  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkPrimary = Color(0xFFA78BFA);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  
  // Glassmorphism Colors
  static const Color glassLight = Color(0xCCFFFFFF); // 80% white
  static const Color glassDark = Color(0xCC1E293B);  // 80% dark surface
  
  // Status Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMid, gradientEnd],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPink, accentAmber],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );
  
  // Shimmer Gradient for loading states
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, -0.5),
    end: Alignment(1.0, 0.5),
    colors: [
      Color(0xFFE2E8F0),
      Color(0xFFF1F5F9),
      Color(0xFFE2E8F0),
    ],
  );
}

