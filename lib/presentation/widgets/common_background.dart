import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/themes/app_colors.dart';

/// Common background widget used across all views for consistency
class CommonBackground extends StatelessWidget {
  final Widget child;
  final bool showGradient;
  final bool showMeshBlur;

  const CommonBackground({
    super.key,
    required this.child,
    this.showGradient = true,
    this.showMeshBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: showGradient
            ? (isDark ? AppColors.darkGradient : null)
            : null,
        color: isDark ? null : AppColors.lightBackground,
      ),
      child: Stack(
        children: [
          // Main content
          child,
        ],
      ),
    );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.8), // Increased opacity to compensate for lack of filter
            color.withOpacity(0),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
