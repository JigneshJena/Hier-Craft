import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import '../../app/themes/app_colors.dart';

/// Premium Animated Bottom Navigation Bar with Glassmorphism
class AnimatedBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  State<AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _slideAnimations;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers for each item
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    // Scale animations for icons
    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Slide animations for labels
    _slideAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();

    // Indicator animation
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _indicatorAnimation = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeInOutCubic,
    ));

    // Animate the initially selected item
    _controllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(AnimatedBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reverse old item animation
      _controllers[oldWidget.currentIndex].reverse();
      // Forward new item animation
      _controllers[widget.currentIndex].forward();
      
      // Animate indicator
      _indicatorAnimation = Tween<double>(
        begin: oldWidget.currentIndex.toDouble(),
        end: widget.currentIndex.toDouble(),
      ).animate(CurvedAnimation(
        parent: _indicatorController,
        curve: Curves.easeInOutCubic,
      ));
      _indicatorController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = widget.selectedColor ?? AppColors.primaryStart;
    final unselectedColor = widget.unselectedColor ?? 
        (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return Container(
      height: 80.h,
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassColor(isDark),
              borderRadius: BorderRadius.circular(32.r),
              border: Border.all(
                color: AppColors.glassBorder(isDark),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Animated indicator
                AnimatedBuilder(
                  animation: _indicatorAnimation,
                  builder: (context, child) {
                    final itemWidth = 1.0 / widget.items.length;
                    final leftPosition = _indicatorAnimation.value * itemWidth;
                    
                    return Positioned(
                      left: leftPosition * MediaQuery.of(context).size.width - 32.w,
                      top: 8.h,
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 64.w) / widget.items.length,
                        height: 64.h,
                        decoration: BoxDecoration(
                          color: selectedColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                    );
                  },
                ),
                
                // Navigation items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    final isSelected = index == widget.currentIndex;
                    
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onTap(index),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _scaleAnimations[index],
                            _slideAnimations[index],
                          ]),
                          builder: (context, child) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Animated Icon
                                  Transform.scale(
                                    scale: _scaleAnimations[index].value,
                                    child: Icon(
                                      isSelected ? item.selectedIcon : item.icon,
                                      color: isSelected ? selectedColor : unselectedColor,
                                      size: 24.sp,
                                    ),
                                  ),
                                  
                                  SizedBox(height: 4.h),
                                  
                                  // Animated Label
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: isSelected ? 16.h : 0,
                                    child: Opacity(
                                      opacity: _slideAnimations[index].value,
                                      child: Text(
                                        item.label,
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700,
                                          color: selectedColor,
                                          letterSpacing: 0.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Model for Bottom Nav Items
class BottomNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
