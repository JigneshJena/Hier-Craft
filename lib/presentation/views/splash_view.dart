import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../app/constants/app_constants.dart';
import '../../app/themes/app_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Premium Mesh Gradient Background
          _buildBackground(isDark),
          
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with Pulse Effect
                  _buildAnimatedLogo(context),
                  
                  SizedBox(height: 48.h),
                  
                  // App Name with modern typography
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          AppConstants.appName,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 32.sp,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "Precision Training for Professionals",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 80.h),
                  
                  // Clean Loading Indicator
                  SizedBox(
                    width: 40.w,
                    height: 2.h,
                    child: LinearProgressIndicator(
                      backgroundColor: (isDark ? AppColors.primaryEnd : AppColors.primaryStart).withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppColors.primaryEnd : AppColors.primaryStart
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Version Branding
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "v1.0.0",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary).withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      ),
    );
  }

  Widget _buildMeshCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(seconds: 2),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            height: 140.w,
            width: 140.w,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 64.sp,
                color: primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
