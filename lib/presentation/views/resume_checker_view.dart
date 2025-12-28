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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Get.isDarkMode 
            ? AppColors.darkGradient 
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.lightBackground,
                  AppColors.lightSurfaceVariant,
                ],
              ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Obx(() {
                  if (controller.analysis.value != null) {
                    return _buildResultsView(controller);
                  }
                  return _buildUploadView(controller);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.surface,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'AI Resume Checker',
              style: Get.textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadView(ResumeCheckerController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          // Hero Section
          _buildHeroSection(),
          SizedBox(height: 40.h),

          // Upload Card
          _buildUploadCard(controller),
          SizedBox(height: 24.h),

          // Features
          _buildFeaturesList(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.description,
            size: 64.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Upload Your Resume',
          style: Get.textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Text(
          'Get AI-powered feedback and suggestions\nto improve your resume',
          style: Get.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUploadCard(ResumeCheckerController controller) {
    return Obx(() => Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: controller.isAnalyzing.value
          ? _buildLoadingState()
          : _buildUploadButtons(controller),
    ));
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        SizedBox(
          width: 80.w,
          height: 80.w,
          child: CircularProgressIndicator(
            strokeWidth: 6,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.gradientMid,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Analyzing Resume...',
          style: Get.textTheme.titleMedium,
        ),
        SizedBox(height: 8.h),
        Text(
          'AI is reviewing your resume',
          style: Get.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildUploadButtons(ResumeCheckerController controller) {
    return Column(
      children: [
        _buildUploadButton(
          icon: Icons.picture_as_pdf,
          title: 'Upload PDF',
          subtitle: 'Select PDF from files',
          gradient: AppColors.primaryGradient,
          onTap: () => controller.pickPdfFile(),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildUploadButton(
                icon: Icons.photo_library,
                title: 'Gallery',
                subtitle: 'Choose image',
                gradient: AppColors.accentGradient,
                onTap: () => controller.pickImageFromGallery(),
                compact: true,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildUploadButton(
                icon: Icons.camera_alt,
                title: 'Camera',
                subtitle: 'Take photo',
                gradient: LinearGradient(
                  colors: [AppColors.accentEmerald, AppColors.gradientEnd],
                ),
                onTap: () => controller.captureImageFromCamera(),
                compact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(compact ? 16.w : 20.w),
        decoration: BoxDecoration(
          gradient: gradient.createShader(Rect.largest) != null
              ? null
              : LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: compact
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 32.sp),
                  SizedBox(height: 8.h),
                  Text(
                    title,
                    style: Get.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28.sp),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Get.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          subtitle,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.star, 'text': 'Overall score out of 100'},
      {'icon': Icons.check_circle, 'text': 'Strengths & weaknesses analysis'},
      {'icon': Icons.lightbulb, 'text': 'Actionable improvement suggestions'},
      {'icon': Icons.format_align_left, 'text': 'Formatting recommendations'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What you\'ll get:',
          style: Get.textTheme.titleMedium,
        ),
        SizedBox(height: 16.h),
        ...features.map((feature) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.gradientStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: AppColors.gradientStart,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  feature['text'] as String,
                  style: Get.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildResultsView(ResumeCheckerController controller) {
    final analysis = controller.analysis.value!;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          // Score Card
          _buildScoreCard(analysis),
          SizedBox(height: 24.h),

          // Strengths
          if (analysis.strengths.isNotEmpty) ...[
            _buildFeedbackSection(
              title: 'Strengths',
              icon: Icons.check_circle,
              color: AppColors.success,
              items: analysis.strengths,
            ),
            SizedBox(height: 16.h),
          ],

          // Weaknesses
          if (analysis.weaknesses.isNotEmpty) ...[
            _buildFeedbackSection(
              title: 'Areas to Improve',
              icon: Icons.warning,
              color: AppColors.warning,
              items: analysis.weaknesses,
            ),
            SizedBox(height: 16.h),
          ],

          // Suggestions
          if (analysis.suggestions.isNotEmpty) ...[
            _buildFeedbackSection(
              title: 'Suggestions',
              icon: Icons.lightbulb,
              color: AppColors.info,
              items: analysis.suggestions,
            ),
            SizedBox(height: 16.h),
          ],

          // Formatting Issues
          if (analysis.formattingIssues.isNotEmpty) ...[
            _buildFeedbackSection(
              title: 'Formatting Issues',
              icon: Icons.format_align_left,
              color: AppColors.error,
              items: analysis.formattingIssues,
            ),
            SizedBox(height: 16.h),
          ],

          // Actions
          _buildActionButtons(controller),
        ],
      ),
    );
  }

  Widget _buildScoreCard(analysis) {
    final score = analysis.overallScore;
    final color = score >= 80
        ? AppColors.success
        : score >= 60
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120.w,
                height: 120.w,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$score',
                    style: Get.textTheme.displayLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'out of 100',
                    style: Get.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Grade: ${analysis.grade}',
              style: Get.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  margin: EdgeInsets.only(top: 8.h, right: 12.w),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: Get.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ResumeCheckerController controller) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => controller.reset(),
            icon: const Icon(Icons.refresh),
            label: const Text('Analyze Another'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.home),
            label: const Text('Go Home'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: BorderSide(
                color: Get.theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
