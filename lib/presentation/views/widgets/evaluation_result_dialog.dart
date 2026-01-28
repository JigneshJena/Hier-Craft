import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../data/models/evaluation_result_model.dart';

class EvaluationResultDialog extends StatelessWidget {
  final EvaluationResult result;

  const EvaluationResultDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scoreColor = _getScoreColor(result.score);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16213E) : Colors.white,
          borderRadius: BorderRadius.circular(32.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildScoreCircle(scoreColor),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Feedback"),
                    Text(
                      result.feedback,
                      style: TextStyle(fontSize: 14.sp, height: 1.5, color: Colors.grey[400]),
                    ),
                    if (result.matchedKeywords.isNotEmpty) ...[
                      SizedBox(height: 20.h),
                      _buildSectionHeader("Keywords Matched"),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: result.matchedKeywords.map((k) => _buildKeywordChip(k)).toList(),
                      ),
                    ],
                    if (result.idealAnswer != null) ...[
                      SizedBox(height: 24.h),
                      _buildIdealAnswerSection(),
                    ],
                    if (result.strengths != null && result.strengths!.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      _buildPointList("Strengths", result.strengths!, Colors.green),
                    ],
                    if (result.improvements != null && result.improvements!.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _buildPointList("Areas for Improvement", result.improvements!, Colors.orange),
                    ],
                    SizedBox(height: 32.h),
                    _buildContinueButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle(Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 4),
            ),
            child: Text(
              "${result.score}",
              style: TextStyle(
                fontSize: 48.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            _getScoreLabel(result.score),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildKeywordChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12.sp, color: Colors.green, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildIdealAnswerSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.meshViolet.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.meshViolet.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Ideal Answer"),
          Text(
            result.idealAnswer!,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPointList(String title, List<String> points, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        ...points.map((p) => Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("✓ ", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              Expanded(child: Text(p, style: TextStyle(fontSize: 13.sp, color: Colors.grey))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.meshViolet,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
        onPressed: () => Get.back(),
        child: Text("Continue to Next Question", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return "Excellent!";
    if (score >= 60) return "Good Progress";
    return "Keep Practicing";
  }
}
