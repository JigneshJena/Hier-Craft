import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive Helper for perfect mobile adaptation
/// Ensures no pixel overflow errors across all device sizes
class ResponsiveHelper {
  /// Get responsive padding based on screen width
  static EdgeInsets getPadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    // Reduce padding on very small screens
    final factor = _getScaleFactor();
    
    return EdgeInsets.only(
      left: ((left ?? horizontal ?? all ?? 0) * factor).w,
      right: ((right ?? horizontal ?? all ?? 0) * factor).w,
      top: ((top ?? vertical ?? all ?? 0) * factor).h,
      bottom: ((bottom ?? vertical ?? all ?? 0) * factor).h,
    );
  }
  
  /// Get scale factor based on screen width
  static double _getScaleFactor() {
    final width = ScreenUtil().screenWidth;
    if (width < 360) return 0.85; // Very small phones
    if (width < 380) return 0.92; // Small phones
    return 1.0; // Normal and larger
  }
  
  /// Get responsive font size
  static double fontSize(double size) {
    final factor = _getScaleFactor();
    return (size * factor).sp;
  }
  
  /// Get responsive icon size  
  static double iconSize(double size) {
    final factor = _getScaleFactor();
    return (size * factor).w;
  }
  
  /// Get responsive border radius
  static BorderRadius borderRadius(double radius) {
    return BorderRadius.circular(radius.r);
  }
  
  /// Check if screen is small
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }
  
  /// Check if screen is in landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  /// Get safe responsive height (prevents overflow)
  static double safeHeight(BuildContext context, double percentage) {
    final height = MediaQuery.of(context).size.height;
    final safeHeight = height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom;
    return (safeHeight * percentage).h;
  }
  
  /// Get safe responsive width
  static double safeWidth(BuildContext context, double percentage) {
    final width = MediaQuery.of(context).size.width;
    return (width * percentage).w;
  }
  
  /// Get grid cross axis count based on screen width
  static int getGridCount(BuildContext context, {int defaultCount = 2}) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 3;
    if (width > 480) return defaultCount;
    return defaultCount;
  }
  
  /// Get responsive spacing
  static double spacing(double space) {
    final factor = _getScaleFactor();
    return (space * factor).w;
  }
  
  /// Get responsive vertical spacing
  static double verticalSpacing(double space) {
    final factor = _getScaleFactor();
    return (space * factor).h;
  }
}
