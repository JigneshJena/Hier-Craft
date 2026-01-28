import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive utility class for consistent sizing across all devices
/// Use these helpers instead of raw values for better device compatibility
class ResponsiveUtils {
  // ==================== Screen Dimensions ====================
  
  /// Get screen width
  static double get screenWidth => 1.sw;
  
  /// Get screen height
  static double get screenHeight => 1.sh;
  
  /// Get status bar height
  static double get statusBarHeight => ScreenUtil().statusBarHeight;
  
  /// Get bottom bar height
  static double get bottomBarHeight => ScreenUtil().bottomBarHeight;
  
  // ==================== Device Type Detection ====================
  
  /// Check if device is a small phone (width < 360)
  static bool get isSmallPhone => screenWidth < 360;
  
  /// Check if device is a medium phone (360 <= width < 400)
  static bool get isMediumPhone => screenWidth >= 360 && screenWidth < 400;
  
  /// Check if device is a large phone (400 <= width < 600)
  static bool get isLargePhone => screenWidth >= 400 && screenWidth < 600;
  
  /// Check if device is a tablet (width >= 600)
  static bool get isTablet => screenWidth >= 600;
  
  /// Get device orientation
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;
  
  // ==================== Responsive Spacing ====================
  
  /// Extra small spacing (4.0)
  static double get spaceXS => 4.0.h;
  
  /// Small spacing (8.0)
  static double get spaceS => 8.0.h;
  
  /// Medium spacing (16.0)
  static double get spaceM => 16.0.h;
  
  /// Large spacing (24.0)
  static double get spaceL => 24.0.h;
  
  /// Extra large spacing (32.0)
  static double get spaceXL => 32.0.h;
  
  /// Huge spacing (48.0)
  static double get spaceXXL => 48.0.h;
  
  // ==================== Responsive Text Sizes ====================
  
  /// Tiny text (10sp)
  static double get textTiny => 10.0.sp;
  
  /// Small text (12sp)
  static double get textSmall => 12.0.sp;
  
  /// Body text (14sp)
  static double get textBody => 14.0.sp;
  
  /// Medium text (16sp)
  static double get textMedium => 16.0.sp;
  
  /// Large text (18sp)
  static double get textLarge => 18.0.sp;
  
  /// Title text (20sp)
  static double get textTitle => 20.0.sp;
  
  /// Heading text (24sp)
  static double get textHeading => 24.0.sp;
  
  /// Display text (32sp)
  static double get textDisplay => 32.0.sp;
  
  // ==================== Responsive Icon Sizes ====================
  
  /// Small icon (16)
  static double get iconSmall => 16.0.w;
  
  /// Medium icon (24)
  static double get iconMedium => 24.0.w;
  
  /// Large icon (32)
  static double get iconLarge => 32.0.w;
  
  /// Extra large icon (48)
  static double get iconXL => 48.0.w;
  
  // ==================== Responsive Border Radius ====================
  
  /// Small radius (4)
  static double get radiusS => 4.0.r;
  
  /// Medium radius (8)
  static double get radiusM => 8.0.r;
  
  /// Large radius (12)
  static double get radiusL => 12.0.r;
  
  /// Extra large radius (16)
  static double get radiusXL => 16.0.r;
  
  /// Huge radius (24)
  static double get radiusXXL => 24.0.r;
  
  /// Circular radius (999)
  static double get radiusCircular => 999.0.r;
  
  // ==================== Adaptive Values ====================
  
  /// Get adaptive value based on screen size
  /// Returns different values for small, medium, large phones and tablets
  static T adaptive<T>({
    required T small,
    T? medium,
    T? large,
    T? tablet,
  }) {
    if (isTablet && tablet != null) return tablet;
    if (isLargePhone && large != null) return large;
    if (isMediumPhone && medium != null) return medium;
    return small;
  }
  
  /// Get value scaled for current screen
  static double scale(double value) => value.w;
  
  /// Get height scaled for current screen
  static double scaleHeight(double value) => value.h;
  
  /// Get font size scaled for current screen
  static double scaleFontSize(double value) => value.sp;
  
  // ==================== Safe Area Helpers ====================
  
  /// Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
  
  /// Get horizontal safe padding
  static double safeHorizontal(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return padding.left + padding.right;
  }
  
  /// Get vertical safe padding
  static double safeVertical(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return padding.top + padding.bottom;
  }
  
  // ==================== Responsive Padding ====================
  
  /// Symmetric padding with responsive values
  static EdgeInsets symmetricPadding({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal.w,
      vertical: vertical.h,
    );
  }
  
  /// All-around padding with responsive value
  static EdgeInsets allPadding(double value) {
    return EdgeInsets.all(value.w);
  }
  
  /// Custom padding with responsive values
  static EdgeInsets customPadding({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left.w,
      top: top.h,
      right: right.w,
      bottom: bottom.h,
    );
  }
  
  // ==================== Responsive SizedBox ====================
  
  /// Horizontal spacing
  static Widget horizontalSpace(double width) => SizedBox(width: width.w);
  
  /// Vertical spacing
  static Widget verticalSpace(double height) => SizedBox(height: height.h);
  
  /// Square box
  static Widget squareBox(double size) => SizedBox(
        width: size.w,
        height: size.h,
      );
  
  // ==================== Responsive Constraints ====================
  
  /// Max width constraint
  static BoxConstraints maxWidth(double width) => BoxConstraints(
        maxWidth: width.w,
      );
  
  /// Max height constraint
  static BoxConstraints maxHeight(double height) => BoxConstraints(
        maxHeight: height.h,
      );
  
  /// Min max width constraint
  static BoxConstraints minMaxWidth({
    required double min,
    required double max,
  }) =>
      BoxConstraints(
        minWidth: min.w,
        maxWidth: max.w,
      );
  
  /// Min max height constraint
  static BoxConstraints minMaxHeight({
    required double min,
    required double max,
  }) =>
      BoxConstraints(
        minHeight: min.h,
        maxHeight: max.h,
      );
  
  // ==================== Debug Info ====================
  
  /// Print responsive debug info
  static void printDebugInfo() {
    debugPrint('========== RESPONSIVE DEBUG ==========');
    debugPrint('Screen Width: ${screenWidth}dp');
    debugPrint('Screen Height: ${screenHeight}dp');
    debugPrint('Device Type: ${_getDeviceType()}');
    debugPrint('Status Bar: ${statusBarHeight}dp');
    debugPrint('Bottom Bar: ${bottomBarHeight}dp');
    debugPrint('=====================================');
  }
  
  static String _getDeviceType() {
    if (isTablet) return 'Tablet';
    if (isLargePhone) return 'Large Phone';
    if (isMediumPhone) return 'Medium Phone';
    if (isSmallPhone) return 'Small Phone';
    return 'Unknown';
  }
}

/// Extension on num for cleaner syntax
extension ResponsiveExtension on num {
  /// Responsive width
  double get rw => ResponsiveUtils.scale(toDouble());
  
  /// Responsive height
  double get rh => ResponsiveUtils.scaleHeight(toDouble());
  
  /// Responsive font size
  double get rf => ResponsiveUtils.scaleFontSize(toDouble());
}
