import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/dynamic_theme_service.dart';

class AppColors {
  static DynamicThemeService get _dynamic => Get.find<DynamicThemeService>();

  // Primary Colors (Dynamic)
  static Color get primaryStart => _dynamic.primaryColor.value;
  static Color get primaryEnd => _dynamic.secondaryColor.value;
  static Color get primaryLight => _dynamic.secondaryColor.value.withOpacity(0.7);
  static Color get primaryDark => _dynamic.primaryColor.value.withOpacity(0.8);
  
  // Accent Colors (Dynamic)
  static Color get accentGold => _dynamic.accentColor.value;
  static Color get accentBeige => _dynamic.backgroundColor.value;
  static const Color accentCrimson = Color(0xFFD00000); // Fixed Crimson for errors
  
  // Semantic Aliases
  static Color get accentRose => accentCrimson;
  static Color get accentAmber => accentGold;
  static Color get accentCyan => primaryEnd;
  static Color get accentEmerald => primaryEnd;
  
  // Light Mode Colors
  static Color get lightBackground => _dynamic.backgroundColor.value;
  static const Color lightSurface = Color(0xFFFFFFFF);
  static Color get lightSurfaceVariant => _dynamic.backgroundColor.value.withOpacity(0.5);
  static Color get lightBorder => _dynamic.backgroundColor.value.withOpacity(0.8);
  static Color get lightTextPrimary => _dynamic.primaryColor.value;
  static Color get lightTextSecondary => _dynamic.secondaryColor.value;
  
  // Dark Mode Colors - Using a professional deep navy/charcoal base
  static const Color darkBackground = Color(0xFF0A0F1D);
  static Color get darkSurface => Color.alphaBlend(
    _dynamic.primaryColor.value.withOpacity(0.12),
    const Color(0xFF161C2C),
  );
  static Color get darkSurfaceVariant => Color.alphaBlend(
    _dynamic.primaryColor.value.withOpacity(0.08),
    const Color(0xFF1E2638),
  );
  static Color get darkBorder => _dynamic.primaryColor.value.withOpacity(0.2);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  
  // Mesh Gradient Colors
  static Color get meshNavy => _dynamic.primaryColor.value.withOpacity(0.2);
  static Color get meshSteel => _dynamic.secondaryColor.value.withOpacity(0.2);
  static Color get meshGold => _dynamic.accentColor.value.withOpacity(0.2);
  static Color get meshBeige => _dynamic.backgroundColor.value.withOpacity(0.2);
  
  // Compatibility Aliases
  static Color get meshIndigo => meshNavy;
  static Color get meshViolet => meshSteel;
  static Color get meshCyan => meshSteel;
  static Color get meshRose => meshGold;
  static Color get meshTurquoise => meshSteel;
  static Color get meshBrown => meshNavy;
  static Color get meshPink => meshGold;
  
  // Glassmorphism Helpers
  static Color glassColor(bool isDark) => isDark 
      ? darkSurface.withOpacity(0.3)
      : Colors.white.withOpacity(0.7);
  
  static Color glassBorder(bool isDark) => isDark 
      ? accentGold.withOpacity(0.2)
      : primaryStart.withOpacity(0.15);

  // Legacy compatibility
  static Color get gradientStart => primaryStart;
  static Color get gradientEnd => primaryEnd;
  static const Color error = Color(0xFFD00000);
  static Color get success => accentGold;
  static Color get warning => accentGold;
  static Color get info => primaryEnd;
  static Color get secondaryBrown => primaryEnd;

  // Gradients (Converted to getters because colors are dynamic)
  static LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );
  
  static LinearGradient get accentGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, accentGold],
  );
  
  static LinearGradient get darkGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A3263), Color(0xFF0D1321)],
  );
  
  static LinearGradient get signatureGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryStart,
      primaryEnd,
      accentGold,
    ],
  );
}
