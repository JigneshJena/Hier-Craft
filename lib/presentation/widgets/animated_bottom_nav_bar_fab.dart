import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../../app/themes/app_colors.dart';

/// Premium Bottom Nav Bar with Center FAB - YouTube Style
class AnimatedBottomNavBarWithFAB extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onCenterTap;
  final List<BottomNavItemFAB> items;
  final IconData centerIcon;
  final String centerLabel;

  const AnimatedBottomNavBarWithFAB({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
    required this.items,
    this.centerIcon = Icons.add_rounded,
    this.centerLabel = 'Start',
  });

  @override
  State<AnimatedBottomNavBarWithFAB> createState() => _AnimatedBottomNavBarWithFABState();
}

class _AnimatedBottomNavBarWithFABState extends State<AnimatedBottomNavBarWithFAB>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );

    _fabRotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Container(
        height: 100.h, // Adjusted height
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Bottom Nav Bar - Lower Layer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70.h,
                margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.glassColor(isDark).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(32.r),
                        border: Border.all(
                          color: AppColors.glassBorder(isDark),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _navItems(isDark),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Center FAB - Upper Layer (Isolated from BackdropFilter)
            Positioned(
              top: 15.h, // Lowered from 12.h to 15.h for better alignment
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTapDown: (_) => _fabController.forward(),
                  onTapUp: (_) {
                    _fabController.reverse();
                    widget.onCenterTap();
                  },
                  onTapCancel: () => _fabController.reverse(),
                  child: AnimatedBuilder(
                    animation: _fabController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _fabScaleAnimation.value,
                        child: Container(
                          width: 68.w,
                          height: 68.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Stable Glow (Instead of BoxShadow)
                              Container(
                                width: 55.w,
                                height: 55.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.primaryEnd.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              // Primary Button
                              Container(
                                width: 56.w,
                                height: 56.w,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primaryStart, AppColors.primaryEnd],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                                ),
                                child: Icon(
                                  widget.centerIcon,
                                  color: Colors.white,
                                  size: 26.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _navItems(bool isDark) {
    List<Widget> children = [];
    
    for (int i = 0; i < widget.items.length; i++) {
      if (i == 2) {
        children.add(SizedBox(width: 80.w)); // Center Spacer
      }
      final isSelected = i == widget.currentIndex;
      children.add(_buildNavItem(widget.items[i], i, isSelected, isDark));
    }
    
    return children;
  }

  Widget _buildNavItem(BottomNavItemFAB item, int index, bool isSelected, bool isDark) {
    final selectedColor = AppColors.primaryStart;
    final unselectedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent, // Explicitly transparent
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()
                  ..translate(0.0, isSelected ? -2.0 : 0.0)
                  ..scale(isSelected ? 1.1 : 1.0),
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color: isSelected ? selectedColor : unselectedColor,
                  size: 20.sp, // Slightly smaller
                ),
              ),
              if (isSelected) ...[
                SizedBox(height: 4.h),
                Container(
                  height: 4.h,
                  width: 12.w,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavItemFAB {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const BottomNavItemFAB({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
