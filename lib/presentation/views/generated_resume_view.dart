import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../core/services/pdf_generator_service.dart';

class GeneratedResumeView extends StatelessWidget {
  const GeneratedResumeView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = Get.arguments ?? {};
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("RESUME TEMPLATE", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Get.find<PdfGeneratorService>().generateAndDownloadResume(data), 
            icon: const Icon(Icons.download_rounded)
          ),
          IconButton(
            onPressed: () => Get.find<PdfGeneratorService>().generateAndShareResume(data), 
            icon: const Icon(Icons.share_rounded)
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            _buildClassicTemplate(data, isDark),
            SizedBox(height: 40.h),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildClassicTemplate(Map<String, dynamic> data, bool isDark) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Text(
                  (data['name'] ?? "YOUR NAME").toUpperCase(),
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
                SizedBox(height: 8.h),
                Text(
                  "${data['email'] ?? "email@example.com"} | ${data['phone'] ?? "+1 234 567 890"}",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Divider(thickness: 1, color: AppColors.primaryStart.withOpacity(0.2)),
          SizedBox(height: 24.h),

          // Summary
          _buildSectionHeader("PROFESSIONAL SUMMARY"),
          Text(
            data['summary'] ?? "Experienced professional with a strong background in software development...",
            style: TextStyle(fontSize: 13.sp, height: 1.5),
          ),
          SizedBox(height: 24.h),

          // Experience
          _buildSectionHeader("WORK EXPERIENCE"),
          ...((data['experience'] as List? ?? []).map((exp) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(exp['role'] ?? "Role", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    Text(exp['duration'] ?? "Dates", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                  ],
                ),
                Text(exp['company'] ?? "Company", style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.primaryStart)),
                SizedBox(height: 4.h),
                Text(exp['description'] ?? "", style: TextStyle(fontSize: 12.sp, height: 1.3)),
              ],
            ),
          ))),

          // Education
          _buildSectionHeader("EDUCATION"),
          ...((data['education'] as List? ?? []).map((edu) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text("${edu['degree']} - ${edu['school']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
                Text(edu['year'] ?? "", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
          ))),

          SizedBox(height: 24.h),
          // Skills
          _buildSectionHeader("CORE COMPETENCIES"),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: (data['skills'] as List? ?? []).map((skill) => Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryStart.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(skill.toString(), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: AppColors.primaryStart, letterSpacing: 1.2)),
          SizedBox(height: 4.h),
          Container(width: 40.w, height: 2.h, color: AppColors.primaryStart),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.edit_rounded),
            label: const Text("EDIT CONTENT"),
            style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16.h)),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save_rounded),
            label: const Text("FINALIZE"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryStart,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
          ),
        ),
      ],
    );
  }
}
