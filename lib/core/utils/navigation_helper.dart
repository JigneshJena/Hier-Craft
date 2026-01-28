import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';

/// Navigation Helper for consistent navigation across the app
class NavigationHelper {
  // Navigate to user home with bottom navigation
  static void toHome() => Get.offAllNamed(AppRoutes.mainShell);
  
  static void toDomain() => Get.toNamed(AppRoutes.domain);
  
  static void toPracticeMode({required String domain}) =>
      Get.toNamed(AppRoutes.practiceMode, arguments: {'domain': domain});
  
  static void toInterview({
    required String domain,
    required String aiProviderId,
    required String difficulty,
  }) =>
      Get.toNamed(AppRoutes.interview, arguments: {
        'domain': domain,
        'aiProviderId': aiProviderId,
        'difficulty': difficulty,
      });
  
  static void toResults({required Map<String, dynamic> sessionData}) =>
      Get.toNamed(AppRoutes.results, arguments: sessionData);
  
  static void toPrepHub() => Get.toNamed(AppRoutes.prepHub);
  
  static void toResumeChecker() => Get.toNamed(AppRoutes.resumeChecker);
  
  static void toResumeBuilder() => Get.toNamed(AppRoutes.resumeBuilder);
  
  static void toResumeAnalysis({required Map<String, dynamic> resumeData}) =>
      Get.toNamed(AppRoutes.resumeAnalysis, arguments: resumeData);
  
  static void toGeneratedResume({required Map<String, dynamic> resumeData}) =>
      Get.toNamed(AppRoutes.generatedResume, arguments: resumeData);
  
  static void toAdminDashboard() => Get.toNamed(AppRoutes.adminDashboard);
  
  static void toAiProvidersAdmin() => Get.toNamed(AppRoutes.aiProvidersAdmin);
  
  static void toUserManagement() => Get.toNamed(AppRoutes.userManagement);
  
  static void toDomainManagement() => Get.toNamed(AppRoutes.domainManagement);
  
  // Go back
  static void back() => Get.back();
  
  // Go back with result
  static void backWithResult(dynamic result) => Get.back(result: result);
  
  // Replace current route
  static void replaceTo(String routeName) => Get.offNamed(routeName);
  
  // Clear stack and go to route
  static void clearAndGoTo(String routeName) => Get.offAllNamed(routeName);
  
  // Show snackbar
  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.9),
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }
  
  static void showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.9),
      colorText: Get.theme.colorScheme.onError,
    );
  }
  
  static void showInfo(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      backgroundColor: Get.theme.colorScheme.surface.withOpacity(0.95),
      colorText: Get.theme.colorScheme.onSurface,
    );
  }
  
  // Show loading dialog
  static void showLoading({String? message}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Get.theme.colorScheme.primary,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: Get.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
  
  // Confirm dialog
  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
