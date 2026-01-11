import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../app/routes/app_routes.dart';
import '../../core/services/auth_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    
    final authService = Get.find<AuthService>();
    if (authService.isLoggedIn) {
      // Small wait to ensure role is fetched if just logged in via persistence
      if (authService.role == 'user') {
        // Double check role if it hasn't updated yet from firestore
        // Usually AuthService ever(user) handles this, but splash is fast.
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      if (authService.isAdmin) {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } else {
      Get.offAllNamed(AppRoutes.auth);
    }
  }
}
