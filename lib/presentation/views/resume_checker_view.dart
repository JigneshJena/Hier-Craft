import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/resume_checker_controller.dart';
import '../../app/themes/app_colors.dart';

class ResumeCheckerView extends StatelessWidget {
  const ResumeCheckerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResumeCheckerController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(isDark),
          
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                Expanded(
                  child: Obx(() {
                    if (controller.isAnalyzing.value) {
                      return _buildNeuralLoading();
                    }
                    return _buildStudioView(controller);
                  }),
                ),
              ],
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

  Widget _buildAppBar() {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          const Spacer(),
          Text(
            "RESUME STUDIO",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: isDark ? AppColors.primaryEnd : AppColors.primaryStart,
            ),
          ),
          const Spacer(),
          SizedBox(width: 48.w), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildNeuralLoading() {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPulseAnimation(),
          SizedBox(height: 48.h),
          Text(
            "PARSING CONTENT ARCHITECTURE",
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: isDark ? AppColors.primaryEnd : AppColors.primaryStart,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Our AI is decyphering your professional profile...",
            style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.darkTextSecondary : Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.2),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryStart.withOpacity(0.1 * (2 - value)),
              border: Border.all(color: AppColors.primaryStart.withOpacity(0.5 * (2 - value)), width: 2),
            ),
            child: Icon(Icons.bolt_rounded, color: AppColors.primaryStart, size: 40.sp),
          ),
        );
      },
    );
  }

  Widget _buildStudioView(ResumeCheckerController controller) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 130.h), // Extra bottom padding
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h), // Reduced
          _buildHeroSection(),
          SizedBox(height: 20.h), // Increased spacing since we removed a section
          // _buildAIProviderSection(controller, isDark), // REMOVED - Too technical for users
          _buildUploadSection(controller),
          SizedBox(height: 16.h), // Reduced
          _buildFeatureSection(),
          SizedBox(height: 20.h), // Reduced
        ],
      ),
    );
  }

  Widget _buildAIProviderSection(ResumeCheckerController controller, bool isDark) {
    return Obx(() {
      if (controller.isLoadingProviders.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.aiProviders.isEmpty) {
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.accentAmber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.accentAmber.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.accentAmber, size: 16.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'No AI providers configured',
                  style: TextStyle(color: AppColors.accentAmber, fontSize: 11.sp),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SELECT AI ENGINE",
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: isDark ? AppColors.primaryEnd : AppColors.primaryStart,
            ),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            height: 57.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.aiProviders.length,
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final provider = controller.aiProviders[index];
                final isSelected = controller.selectedProvider.value?.id == provider.id;
                
                return _buildProviderCard(
                  provider: provider,
                  isSelected: isSelected,
                  onTap: () => controller.selectedProvider.value = provider,
                  isDark: isDark,
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProviderCard({
    required dynamic provider,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    Color getProviderColor(String providerName) {
      switch (providerName.toLowerCase()) {
        case 'gemini':
          return AppColors.accentCyan;
        case 'groq':
          return AppColors.accentEmerald;
        case 'openai':
          return AppColors.primaryStart;
        default:
          return AppColors.accentAmber;
      }
    }

    final providerColor = getProviderColor(provider.provider);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 105.w,
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? providerColor : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    providerColor.withOpacity(0.15),
                    providerColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : (isDark ? Colors.grey[900] : Colors.white),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: providerColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: providerColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: providerColor,
                    size: 12.sp,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: providerColor,
                    size: 12.sp,
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              provider.provider.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 9.sp,
                color: isSelected ? providerColor : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
            Text(
              provider.model,
              style: TextStyle(
                fontSize: 7.sp,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "OPTIMIZE YOUR",
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: isDark ? AppColors.primaryEnd : AppColors.primaryStart,
          ),
        ),
        Text(
          "Professional Signal",
          style: Get.theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            fontSize: 26.sp,
            color: Theme.of(Get.context!).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Leverage multimodal AI to audit your resume for modern recruitment standards.",
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
            color: isDark ? AppColors.darkTextSecondary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection(ResumeCheckerController controller) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Column(
      children: [
        _buildActionCard(
          title: "Import Document",
          sub: "Upload PDF / DOCX Analysis",
          icon: Icons.upload_file_rounded,
          color: AppColors.primaryStart,
          onTap: () => controller.pickPdfFile(),
          isDark: isDark,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: "Scan",
                sub: "Camera Capture",
                icon: Icons.camera_rounded,
                color: AppColors.accentRose,
                onTap: () => controller.captureImageFromCamera(),
                isDark: isDark,
                compact: true,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildActionCard(
                title: "Gallery",
                sub: "Image Import",
                icon: Icons.photo_library_rounded,
                color: AppColors.accentEmerald,
                onTap: () => controller.pickImageFromGallery(),
                isDark: isDark,
                compact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String sub,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    bool compact = false,
    bool highlight = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          padding: EdgeInsets.all(compact ? 16.w : 24.w),
          decoration: BoxDecoration(
            color: highlight ? color.withOpacity(0.1) : Get.theme.cardTheme.color,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: highlight ? color.withOpacity(0.3) : color.withOpacity(0.1), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.sp),
                    ),
                    Text(
                      sub,
                      style: TextStyle(fontSize: 10.sp, color: isDark ? AppColors.darkTextSecondary : Colors.grey),
                    ),
                  ],
                ),
              ),
              if (!compact) Icon(Icons.chevron_right_rounded, color: Colors.grey.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.grey.withOpacity(0.1))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text("OR", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.grey.withOpacity(0.5))),
        ),
        Expanded(child: Container(height: 1, color: Colors.grey.withOpacity(0.1))),
      ],
    );
  }

  Widget _buildFeatureSection() {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant.withOpacity(0.3) : AppColors.lightSurfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ANALYSIS SCOPE",
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem(Icons.query_stats_rounded, "Content Scoring (ATS Compliance)"),
          _buildFeatureItem(Icons.psychology_rounded, "Strategic Weakness Mapping"),
          _buildFeatureItem(Icons.tips_and_updates_rounded, "Formatting & Typography Audit"),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primaryStart),
          SizedBox(width: 12.w),
          Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
