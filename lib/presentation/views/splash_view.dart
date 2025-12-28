import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/splash_controller.dart';
import '../../app/constants/app_constants.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for Logo animation
            Container(
              height: 200.h,
              width: 200.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic_none_rounded,
                size: 100.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 30.h),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 28.sp,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Your Personal Interview Coach",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 50.h),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
