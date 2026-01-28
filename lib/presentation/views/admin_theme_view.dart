import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/services/dynamic_theme_service.dart';
import '../../app/themes/app_colors.dart';

class AdminThemeController extends GetxController {
  final _service = Get.find<DynamicThemeService>();
  
  final primaryController = TextEditingController();
  final secondaryController = TextEditingController();
  final accentController = TextEditingController();
  final backgroundController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    primaryController.text = _toHex(_service.primaryColor.value);
    secondaryController.text = _toHex(_service.secondaryColor.value);
    accentController.text = _toHex(_service.accentColor.value);
    backgroundController.text = _toHex(_service.backgroundColor.value);
  }

  String _toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  Future<void> saveTheme() async {
    try {
      await _service.updateTheme(
        primary: primaryController.text.trim(),
        secondary: secondaryController.text.trim(),
        accent: accentController.text.trim(),
        background: backgroundController.text.trim(),
      );
      Get.snackbar(
        'Success',
        'App theme updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update theme: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}

class AdminThemeView extends StatelessWidget {
  const AdminThemeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminThemeController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Config'),
        backgroundColor: AppColors.primaryStart,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            SizedBox(height: 32.h),
            _buildColorField(
              label: 'Primary Brand Color',
              subtitle: 'Used for headers, nav bars, and primary buttons',
              controller: controller.primaryController,
              previewColor: controller._service.primaryColor,
            ),
            SizedBox(height: 24.h),
            _buildColorField(
              label: 'Secondary / Steel Color',
              subtitle: 'Used for accents, borders, and secondary text',
              controller: controller.secondaryController,
              previewColor: controller._service.secondaryColor,
            ),
            SizedBox(height: 24.h),
            _buildColorField(
              label: 'Accent / Highlight Color',
              subtitle: 'Used for notifications, warnings, and special cards',
              controller: controller.accentController,
              previewColor: controller._service.accentColor,
            ),
            SizedBox(height: 24.h),
            _buildColorField(
              label: 'App Background Color',
              subtitle: 'The primary scaffolding color for light mode',
              controller: controller.backgroundController,
              previewColor: controller._service.backgroundColor,
            ),
            SizedBox(height: 48.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.saveTheme,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryStart,
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: const Text('APPLY THEME GLOBALLY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryStart.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryStart.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primaryStart),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Changes made here will be instantly pushed to all active users via Firestore.',
              style: TextStyle(fontSize: 13.sp, color: AppColors.primaryStart, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorField({
    required String label,
    required String subtitle,
    required TextEditingController controller,
    required Rx<Color> previewColor,
  }) {
    final context = Get.context!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        SizedBox(height: 12.h),
        Row(
          children: [
            Obx(() => Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: previewColor.value,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(color: previewColor.value.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
            )),
            SizedBox(width: 16.w),
            Expanded(
              child: TextField(
                controller: controller,
                  decoration: InputDecoration(
                    hintText: '#HEXCODE',
                    fillColor: Theme.of(context).cardColor,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  ),
                onChanged: (val) {
                  // Optional: Live preview logic could go here
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
