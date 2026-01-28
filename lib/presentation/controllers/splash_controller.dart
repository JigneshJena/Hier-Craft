import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../core/services/auth_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startInitSequence();
  }

  void _startInitSequence() async {
    // 1. Minimum splash time for branding
    await Future.delayed(const Duration(seconds: 2));
    
    // 2. Perform Navigation
    _navigateToNext();
  }

  void _navigateToNext() async {
    final authService = Get.find<AuthService>();
    
    if (authService.isLoggedIn) {
      // Small delay to ensure any auth-triggered streams are populated
      await Future.delayed(const Duration(milliseconds: 200));
      
      if (authService.isAdmin) {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else {
        Get.offAllNamed(AppRoutes.mainShell);
      }
    } else {
      Get.offAllNamed(AppRoutes.auth);
    }
  }
}
