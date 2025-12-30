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
                _buildAppBar(context),
                Expanded(
                  child: Obx(() {
                    if (controller.isAnalyzing.value) {
                      return _buildNeuralLoading();
                    }
                    return _buildStudioView(controller, isDark);
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
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.meshCyan.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
              color: AppColors.primaryStart,
            ),
          ),
          const Spacer(),
          SizedBox(width: 48.w), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildNeuralLoading() {
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
              color: AppColors.primaryStart,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Our AI is decyphering your professional profile...",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
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

  Widget _buildStudioView(ResumeCheckerController controller, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          _buildHeroSection(),
          SizedBox(height: 40.h),
          _buildUploadSection(controller, isDark),
          SizedBox(height: 40.h),
          _buildFeatureSection(isDark),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "OPTIMIZE YOUR",
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: AppColors.primaryStart,
          ),
        ),
        Text(
          "Professional Signal",
          style: Get.theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          "Leverage multimodal AI to audit your resume for modern recruitment standards.",
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection(ResumeCheckerController controller, bool isDark) {
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
        SizedBox(height: 24.h),
        _buildDivider(),
        SizedBox(height: 24.h),
        _buildActionCard(
          title: "AI Resume Builder",
          sub: "Create a standard profile from scratch",
          icon: Icons.auto_awesome_rounded,
          color: AppColors.accentAmber,
          onTap: () => Get.toNamed('/resume-builder'),
          isDark: isDark,
          highlight: true,
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
                      style: TextStyle(fontSize: 10.sp, color: Colors.grey),
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

  Widget _buildFeatureSection(bool isDark) {
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
