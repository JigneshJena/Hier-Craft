import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/themes/app_colors.dart';
import '../controllers/ai_provider_controller.dart';
import '../widgets/responsive_admin_layout.dart';
import '../../data/models/ai_model.dart';

class AiProvidersAdminView extends StatelessWidget {
  const AiProvidersAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller if not already present
    final controller = Get.put(AiProviderController());

    return ResponsiveAdminLayout(
      title: 'AI Management',
      child: SingleChildScrollView( // Wrap entire content in scroll
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible( // Make flexible to prevent overflow
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI Provider List",
                          style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Manage your models and their API keys here.",
                          style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _confirmDeleteAll(context, controller),
                        icon: const Icon(Icons.delete_sweep, color: Colors.red),
                        tooltip: "Clear All Providers",
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton.icon(
                        onPressed: () => _showModelDialog(context, controller),
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: Text("Add", style: GoogleFonts.outfit(color: Colors.white, fontSize: 13.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryStart,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.aiModels.isEmpty) {
                  return _buildEmptyState(context, controller);
                }
                return ListView.builder(
                  shrinkWrap: true, // Important for nested scroll
                  physics: const NeverScrollableScrollPhysics(), // Let parent scroll
                  itemCount: controller.aiModels.length,
                  itemBuilder: (context, index) {
                    final model = controller.aiModels[index];
                    return _buildModelCard(context, controller, model);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AiProviderController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.smart_toy_outlined, size: 60.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            "No AI providers found",
            style: GoogleFonts.outfit(fontSize: 18.sp, color: Colors.grey),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () => _showModelDialog(context, controller),
            child: const Text("Create your first provider"),
          ),
        ],
      ),
    );
  }

  Widget _buildModelCard(BuildContext context, AiProviderController controller, AiModel model) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: model.isActive ? AppColors.primaryStart.withOpacity(0.3) : Colors.grey.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: (model.isActive ? AppColors.primaryStart : Colors.grey).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: model.isActive ? AppColors.primaryStart : Colors.grey,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          
          // Text content - use Expanded here
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        model.provider.toUpperCase(),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (model.isActive) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryStart.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "ACTIVE",
                          style: GoogleFonts.outfit(
                            fontSize: 8.sp,
                            color: AppColors.primaryStart,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  "Model: ${model.model}",
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11.sp),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          
          // Actions - no Expanded/Flexible
          Switch(
            value: model.isActive,
            onChanged: (val) => controller.toggleStatus(model),
            activeColor: AppColors.primaryStart,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
            onPressed: () => _showModelDialog(context, controller, model: model),
            padding: EdgeInsets.all(4.w),
            constraints: const BoxConstraints(),
            iconSize: 18.sp,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
            onPressed: () => _confirmDelete(context, controller, model),
            padding: EdgeInsets.all(4.w),
            constraints: const BoxConstraints(),
            iconSize: 18.sp,
          ),
        ],
      ),
    );
  }

  void _showModelDialog(BuildContext context, AiProviderController controller, {AiModel? model}) {
    final idCtrl = TextEditingController(text: model?.id ?? '');
    final providerCtrl = TextEditingController(text: model?.provider ?? '');
    final modelCtrl = TextEditingController(text: model?.model ?? '');
    final apiKeyCtrl = TextEditingController(text: model?.apiKey ?? '');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: Container(
          padding: EdgeInsets.all(24.w), // Slightly reduced padding
          constraints: BoxConstraints(maxWidth: 400.w),
          child: SingleChildScrollView( // Added ScrollView to fix pixel error
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model == null ? "Add AI Provider" : "Edit AI Provider",
                  style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24.h),
                _buildDialogField(idCtrl, "Unique ID (e.g. gemini_flash)", enabled: model == null),
                SizedBox(height: 16.h),
                _buildDialogField(providerCtrl, "Provider Name (e.g. gemini, groq)"),
                SizedBox(height: 16.h),
                _buildDialogField(modelCtrl, "Model Name (e.g. gemini-1.5-flash)"),
                SizedBox(height: 16.h),
                _buildDialogField(apiKeyCtrl, "API Key", isPassword: true),
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                    SizedBox(width: 16.w),
                    ElevatedButton(
                      onPressed: () {
                        if (idCtrl.text.isEmpty) {
                          Get.snackbar("Error", "ID cannot be empty");
                          return;
                        }
                        final newModel = AiModel(
                          id: idCtrl.text.trim(),
                          provider: providerCtrl.text.trim(),
                          model: modelCtrl.text.trim(),
                          apiKey: apiKeyCtrl.text.trim(),
                          isActive: model?.isActive ?? false,
                        );
                        controller.saveModel(newModel);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryStart,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        model == null ? "Create" : "Save Changes",
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, {bool isPassword = false, bool enabled = true}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      style: GoogleFonts.outfit(fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: enabled ? Colors.grey : Colors.grey.shade400),
        filled: true,
        fillColor: enabled ? Colors.grey.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AiProviderController controller, AiModel model) {
    Get.defaultDialog(
      title: "Delete Provider?",
      middleText: "Are you sure you want to delete ${model.provider} - ${model.model}?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteModel(model.id);
        Get.back();
      },
    );
  }

  void _confirmDeleteAll(BuildContext context, AiProviderController controller) {
    Get.defaultDialog(
      title: "Clear All Data?",
      middleText: "This will delete ALL AI providers from the database. This action cannot be undone. \n\nUseful if the database is corrupted.",
      textConfirm: "Delete All",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteAllModels();
        Get.back();
      },
    );
  }
}
