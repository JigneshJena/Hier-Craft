import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/home_controller.dart';
import '../controllers/scheduling_controller.dart';
import '../../core/services/ai_config_service.dart';
import '../../app/themes/app_colors.dart';
import '../../app/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../widgets/common_background.dart';
import '../widgets/common_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final scheduleController = Get.put(SchedulingController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
                  child: _buildHeader(),
                ),
              ),

              // 2. Main Hero Card
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                sliver: SliverToBoxAdapter(
                  child: _buildMainActionCard(controller),
                ),
              ),

              // 3. Grid Menu - Using SliverGrid for performance
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 16.w,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildMenuCard(
                      "Resume Builder",
                      "Create professional CVs",
                      Icons.description_rounded,
                      AppColors.accentCyan,
                      controller.goToResumeBuilder,
                    ),
                    _buildMenuCard(
                      "Resume Checker",
                      "AI Scan for optimization",
                      Icons.fact_check_rounded,
                      AppColors.accentRose,
                      controller.goToResumeChecker,
                    ),
                    _buildMenuCard(
                      "Prep Hub",
                      "Tips & Resources",
                      Icons.lightbulb_rounded,
                      AppColors.accentAmber,
                      controller.goToPrepHub,
                    ),
                    _buildMenuCard(
                      "Interview History",
                      "Track your progress",
                      Icons.history_rounded,
                      AppColors.accentEmerald,
                      () => Get.toNamed(AppRoutes.history),
                    ),
                  ]),
                ),
              ),

              // 4. Schedule Section
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                sliver: SliverToBoxAdapter(
                  child: _buildScheduleSection(scheduleController),
                ),
              ),

              // 5. Daily Tip
              SliverPadding(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 40.h),
                sliver: SliverToBoxAdapter(
                  child: _buildDailyTipCard(controller),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    final authService = Get.find<AuthService>();
    final userName = authService.user?.email?.split('@')[0].capitalizeFirst ?? "User";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Good Morning,",
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.primaryEnd : AppColors.primaryStart,
            letterSpacing: 1.2,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                userName,
                style: GoogleFonts.outfit(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Obx(() => authService.isAdmin 
              ? IconButton(
                  onPressed: () => Get.toNamed(AppRoutes.adminDashboard),
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryStart.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.admin_panel_settings_rounded, color: isDark ? AppColors.primaryEnd : AppColors.primaryStart, size: 24.sp),
                  ),
                )
              : const SizedBox.shrink()),
          ],
        ),
      ],
    );
  }

  Widget _buildMainActionCard(HomeController controller) {
    final aiConfig = Get.find<AiConfigService>();
    
    return GestureDetector(
      onTap: controller.goToMockInterview,
      child: Container(
        width: double.infinity,
        height: 160.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryStart, AppColors.primaryEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryStart.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                Icons.rocket_launch_rounded,
                size: 120.sp,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Start AI Interview",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Obx(() => Text(
                    "Practice with industry-specific\npowered by ${aiConfig.provider.value.capitalizeFirst} AI",
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      "Launch Now",
                      style: GoogleFonts.outfit(
                        color: AppColors.primaryStart,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return CommonCard(
      onTap: onTap,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
              height: 1.2,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: 10.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(SchedulingController controller) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.primaryStart.withOpacity(0.04),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: (isDark ? AppColors.primaryEnd : AppColors.primaryStart).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Prep Schedule",
                style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w800),
              ),
              IconButton(
                onPressed: () => controller.pickTime(Get.context!),
                icon: Icon(Icons.add_circle_outline_rounded, color: isDark ? AppColors.primaryEnd : AppColors.primaryStart, size: 26.sp),
              ),
            ],
          ),
          Obx(() {
            if (controller.schedules.isEmpty) {
              return Text("No sessions scheduled yet.", 
                style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey.withOpacity(0.7)));
            }
            return Column(
              children: controller.schedules.take(2).map((schedule) {
                final time = DateTime.parse(schedule['time']);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.access_time_filled_rounded, color: AppColors.primaryStart, size: 20.sp),
                  title: Text("${time.hour}:${time.minute.toString().padLeft(2, '0')}", 
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  subtitle: Text(schedule['domain'], style: TextStyle(fontSize: 12.sp)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline_rounded, size: 18.sp, color: Colors.grey),
                    onPressed: () => controller.deleteSchedule(schedule['id']),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDailyTipCard(HomeController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.accentEmerald.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_rounded, color: AppColors.accentEmerald, size: 32.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Interview Tip", 
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppColors.accentEmerald)),
                Text(controller.dailyTip, 
                  style: GoogleFonts.outfit(fontSize: 12.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
