import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/prep_hub_controller.dart';
import '../../app/themes/app_colors.dart';

class PrepHubView extends StatelessWidget {
  const PrepHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrepHubController());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text("Prep Hub", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            Text("v2.0-DYNAMIC", style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildPracticeBanner(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Text(
                        category.title,
                        style: GoogleFonts.outfit(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    ...category.items.map((item) => _buildPrepItem(item)).toList(),
                    SizedBox(height: 20.h),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrepItem(PrepItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          item.title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        expandedAlignment: Alignment.topLeft,
        children: [
          Text(
            item.content,
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              color: AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeBanner() {
    final List<String> domains = ['Flutter', 'Java', 'DSA', 'Python', 'React', 'Behavioral'];
    
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(24.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryStart, AppColors.secondaryBrown],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryStart.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology_outlined, color: Colors.white, size: 32.sp),
                  SizedBox(width: 12.w),
                  Text(
                    "Specialized Practice",
                    style: GoogleFonts.outfit(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                "Master specific domains with our hybrid question bank and AI scoring system.",
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.secondaryBrown,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    elevation: 0,
                  ),
                  onPressed: () => Get.toNamed('/practice-mode'),
                  child: Text(
                    "Launch Custom Session",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
