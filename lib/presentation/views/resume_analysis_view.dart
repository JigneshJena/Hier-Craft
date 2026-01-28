import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../data/models/resume_model.dart';
import '../../app/themes/app_colors.dart';

class ResumeAnalysisView extends StatelessWidget {
  const ResumeAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    final ResumeAnalysis analysis = Get.arguments as ResumeAnalysis;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(isDark),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  _buildHeader(),
                  SizedBox(height: 32.h),
                  _buildScoreBillboard(analysis, isDark),
                  SizedBox(height: 40.h),
                  _buildSectionTitle("CRITICAL INSIGHTS"),
                  SizedBox(height: 16.h),
                  _buildAnalysisSection(
                    title: 'Strategic Strengths',
                    icon: Icons.verified_rounded,
                    color: AppColors.accentEmerald,
                    items: analysis.strengths,
                    isDark: isDark,
                  ),
                  SizedBox(height: 16.h),
                  _buildAnalysisSection(
                    title: 'Exposure Risk (Weaknesses)',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.accentRose,
                    items: analysis.weaknesses,
                    isDark: isDark,
                  ),
                  SizedBox(height: 16.h),
                  _buildAnalysisSection(
                    title: 'Optimization Logic',
                    icon: Icons.lightbulb_rounded,
                    color: AppColors.accentAmber,
                    items: analysis.suggestions,
                    isDark: isDark,
                  ),
                  if (analysis.formattingIssues.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    _buildAnalysisSection(
                      title: 'Visual Hierarchy Issues',
                      icon: Icons.grid_view_rounded,
                      color: AppColors.accentCyan,
                      items: analysis.formattingIssues,
                      isDark: isDark,
                    ),
                  ],
                  SizedBox(height: 40.h),
                  _buildActionDock(isDark),
                  SizedBox(height: 40.h),
                ],
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

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.05),
          ),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "RESUME AUDIT",
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppColors.primaryStart,
              ),
            ),
            Text(
              "Optimization Report",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreBillboard(ResumeAnalysis analysis, bool isDark) {
    final color = analysis.overallScore >= 80 
        ? AppColors.accentEmerald 
        : (analysis.overallScore >= 60 ? AppColors.accentAmber : AppColors.accentRose);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Get.theme.cardTheme.color,
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140.w,
                height: 140.w,
                child: CircularProgressIndicator(
                  value: analysis.overallScore / 100,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  backgroundColor: color.withOpacity(0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${analysis.overallScore}',
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'INDEX',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Text(
            _getGradeMessage(analysis.overallScore).toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getGradeMessage(int score) {
    if (score >= 90) return "Excellent! Market Ready Profile.";
    if (score >= 80) return "High Potential. Minor Friction.";
    if (score >= 70) return "Strategic Deficits Detected.";
    if (score >= 60) return "Sub-Optimal Structure.";
    return "Complete Architecture Rebuild Indicated.";
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: Get.theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildAnalysisSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Get.theme.cardTheme.color?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20.sp),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13.sp,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            SizedBox(height: 20.h),
            ...items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 6.h, right: 16.w),
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ] else
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Text("No critical issues detected in this segment.", 
                style: TextStyle(fontSize: 12.sp, fontStyle: FontStyle.italic, color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  Widget _buildActionDock(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryStart,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              elevation: 0,
            ),
            child: Text("BACK TO STUDIO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp, letterSpacing: 1)),
          ),
        ),
      ],
    );
  }
}
