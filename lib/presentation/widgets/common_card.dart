import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/themes/app_colors.dart';

/// Common glassmorphic card widget for consistent UI
class CommonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool useGlassmorphism;
  final double elevation;

  const CommonCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.useGlassmorphism = true,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    Widget cardContent = Container(
      padding: padding ?? EdgeInsets.all(20.r),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (useGlassmorphism
                ? AppColors.glassColor(isDark)
                : defaultBgColor),
        borderRadius: BorderRadius.circular(borderRadius ?? 24.r),
        border: Border.all(
          color: useGlassmorphism
              ? AppColors.glassBorder(isDark)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 1,
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: elevation,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    // Add backdrop filter for glassmorphism - Optimized sigma
    if (useGlassmorphism) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Lowered from 10 to 5 for speed
          child: cardContent,
        ),
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 24.r),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
