import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/themes/app_colors.dart';

enum ButtonType { primary, secondary, outline, text }

/// Common button widget for consistent button design
class CommonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? customColor;

  const CommonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 56.h,
      child: _buildButton(isDark),
    );
  }

  Widget _buildButton(bool isDark) {
    switch (type) {
      case ButtonType.primary:
        return _buildPrimaryButton(isDark);
      case ButtonType.secondary:
        return _buildSecondaryButton(isDark);
      case ButtonType.outline:
        return _buildOutlineButton(isDark);
      case ButtonType.text:
        return _buildTextButton(isDark);
    }
  }

  Widget _buildPrimaryButton(bool isDark) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: customColor ??
            (isDark ? AppColors.primaryEnd : AppColors.primaryStart),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        shadowColor: (customColor ?? AppColors.primaryStart).withOpacity(0.3),
      ),
      child: _buildButtonContent(Colors.white),
    );
  }

  Widget _buildSecondaryButton(bool isDark) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        foregroundColor:
            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      child: _buildButtonContent(
          isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
    );
  }

  Widget _buildOutlineButton(bool isDark) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: customColor ??
            (isDark ? AppColors.primaryEnd : AppColors.primaryStart),
        side: BorderSide(
          color: customColor ??
              (isDark ? AppColors.primaryEnd : AppColors.primaryStart),
          width: 1.5,
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      child: _buildButtonContent(customColor ??
          (isDark ? AppColors.primaryEnd : AppColors.primaryStart)),
    );
  }

  Widget _buildTextButton(bool isDark) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: customColor ??
            (isDark ? AppColors.primaryEnd : AppColors.primaryStart),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      ),
      child: _buildButtonContent(customColor ??
          (isDark ? AppColors.primaryEnd : AppColors.primaryStart)),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20.h,
        width: 20.h,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20.r),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
