import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/results_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../widgets/common_background.dart';
import '../widgets/common_card.dart';
import '../widgets/common_button.dart';

class ResultsView extends StatelessWidget {
  const ResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResultsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildHeader(context),
                SizedBox(height: 32.h),
                _buildScoreBillboard(controller, isDark),
                if (controller.personality != null) ...[
                  SizedBox(height: 32.h),
                  _buildSectionTitle("Interview Personality"),
                  SizedBox(height: 16.h),
                  _buildPersonalityCard(controller, isDark),
                ],
                SizedBox(height: 40.h),
                _buildSectionTitle("Detailed Performance Audit"),
                SizedBox(height: 16.h),
                _buildQuestionBreakdown(controller, isDark),
                SizedBox(height: 40.h),
                _buildActionDock(controller),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ASSESSMENT REPORT",
              style: GoogleFonts.outfit(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                color: AppColors.primaryStart,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Your Performance Analysis",
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreBillboard(ResultsController controller, bool isDark) {
    final primaryColor = isDark ? AppColors.primaryEnd : AppColors.primaryStart;
    
    return CommonCard(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 160.w,
                width: 160.w,
                child: CircularProgressIndicator(
                  value: controller.percentage / 100,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  backgroundColor: primaryColor.withOpacity(0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${controller.percentage.toInt()}%",
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    "PERFORMANCE",
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Text(
            controller.performanceMessage.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Final Evaluation in ${controller.domain}",
            style: Theme.of(Get.context!).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 14.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildQuestionBreakdown(ResultsController controller, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.results.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final result = controller.results[index];
        final score = result['score'] as int;
        final color = score >= 8 ? AppColors.accentEmerald : (score >= 5 ? AppColors.accentAmber : AppColors.accentRose);

        return CommonCard(
          padding: EdgeInsets.zero,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              leading: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    "$score",
                    style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16.sp),
                  ),
                ),
              ),
              title: Text(
                result['question'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
              ),
              subtitle: Text(
                "Feedback: ${result['feedback']}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.sp, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAuditPoint("VERBATIM RECORD", result['answer'], isDark),
                      SizedBox(height: 16.h),
                      _buildAuditPoint("AI FEEDBACK", result['feedback'], isDark, highlight: color),
                      if (result['explanation'] != null) ...[
                        SizedBox(height: 16.h),
                        _buildAuditPoint("SUGGESTED ANSWER", result['explanation'], isDark, highlight: AppColors.primaryStart),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuditPoint(String label, String content, bool isDark, {Color? highlight}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: highlight ?? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.5,
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionDock(ResultsController controller) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.domain),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.onSurface.withOpacity(0.05),
              foregroundColor: Get.theme.colorScheme.onSurface,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(color: Get.theme.colorScheme.onSurface.withOpacity(0.1)),
              ),
            ),
            child: Text("SWITCH DOMAIN", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp, letterSpacing: 1)),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryStart,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              elevation: 0,
            ),
            child: Text("RETAKE AUDIT", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp, letterSpacing: 1)),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalityCard(ResultsController controller, bool isDark) {
    final personality = controller.personality!;
    final accentColor = AppColors.meshViolet;
    final scores = Map<String, int>.from(personality['scores'] ?? {});

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor.withOpacity(0.05), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: accentColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.psychology_rounded, color: accentColor, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personality['traitName']?.toUpperCase() ?? "THE CANDIDATE",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Behavioral Profile",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            personality['description'] ?? "",
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 24.h),
          
          // Scores
          ...scores.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key.toUpperCase(),
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      Text(
                        "${entry.value}%",
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: accentColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: entry.value / 100,
                      minHeight: 6.h,
                      backgroundColor: accentColor.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                ],
              ),
            );
          }),
          
          SizedBox(height: 12.h),
          const Divider(),
          SizedBox(height: 12.h),
          
          Text(
            "CORE STRENGTHS",
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: (personality['strengths'] as List? ?? []).map((s) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.accentEmerald.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.accentEmerald.withOpacity(0.1)),
                ),
                child: Text(
                  s,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentEmerald,
                  ),
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Get.theme.colorScheme.onSurface.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_rounded, color: AppColors.accentAmber, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    personality['advice'] ?? "",
                    style: TextStyle(fontSize: 12.sp, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
