import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/admin_controller.dart';
import '../../app/themes/app_colors.dart';
import '../../app/routes/app_routes.dart';
import '../widgets/responsive_admin_layout.dart';
import 'ai_provider_debug_view.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveAdminLayout(
      title: "Admin Dashboard",
      child: Stack(
        children: [
          _buildBackground(isDark),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                controller.refreshData(); // Call new helper or startListening
                await Future.delayed(const Duration(seconds: 1));
              },
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(24.w),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Live Overview",
                              style: GoogleFonts.outfit(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: AppColors.accentEmerald.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.circle, color: AppColors.accentEmerald, size: 8.r),
                                  SizedBox(width: 6.w),
                                  Text(
                                    "LIVE",
                                    style: GoogleFonts.outfit(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.accentEmerald,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildStatsGrid(controller),
                        SizedBox(height: 32.h),
                        _buildAdminMenu(context),
                        SizedBox(height: 32.h),
                        _buildRecentActivityHeader(),
                        SizedBox(height: 16.h),
                        _buildRecentUsersList(controller),
                      ]),
                    ),
                  ),
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
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
    );
  }

  Widget _buildStatsGrid(AdminController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 2);
        
        return Obx(() => GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: isMobile ? 12.w : 24,
          mainAxisSpacing: isMobile ? 12.h : 24,
          childAspectRatio: isMobile ? 1.5 : 2.0,
          children: [
            _buildStatCard(
              "Total Users",
              controller.users.length.toString(),
              Icons.people_alt_rounded,
              AppColors.primaryStart,
              isMobile,
            ),
            _buildStatCard(
              "Active Now",
              controller.activeUsersCount.toString(),
              Icons.bolt_rounded,
              AppColors.accentEmerald,
              isMobile,
            ),
            _buildStatCard(
              "Domains",
              controller.totalDomains.toString(),
              Icons.category_rounded,
              AppColors.accentCyan,
              isMobile,
            ),
            _buildStatCard(
              "Sessions", 
              controller.totalSessions.toString(), 
              Icons.analytics_rounded, 
              AppColors.accentRose, 
              isMobile,
            ),
          ],
        ));
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16.w : 20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(isMobile ? 24.r : 24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: isMobile ? 24.sp : 28),
          SizedBox(height: isMobile ? 8.h : 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: isMobile ? 20.sp : 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 12.sp : 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatStat(String title, String value, IconData icon, Color color, bool isMobile) {
    return _buildStatCard(title, value, icon, color, isMobile);
  }

  Widget _buildAdminMenu(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final bool isWide = constraints.maxWidth > 700;
        
        if (isWide) {
          return Row(
            children: [
              Expanded(
                child: _buildMenuItem(
                  "User Management",
                  "Track activity & progress",
                  Icons.manage_accounts_rounded,
                  AppColors.primaryStart,
                  () => Get.toNamed(AppRoutes.userManagement),
                  isMobile,
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: _buildMenuItem(
                  "AI Configuration",
                  "Manage models & keys",
                  Icons.smart_toy_rounded,
                  AppColors.accentAmber,
                  () => Get.toNamed(AppRoutes.aiProvidersAdmin),
                  isMobile,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _buildMenuItem(
              "User Management",
              "Track activity, progress & details",
              Icons.manage_accounts_rounded,
              AppColors.primaryStart,
              () => Get.toNamed(AppRoutes.userManagement),
              isMobile,
            ),
            SizedBox(height: 16.h),
            _buildMenuItem(
              "AI Configuration",
              "Manage models, providers & keys",
              Icons.smart_toy_rounded,
              AppColors.accentAmber,
              () => Get.toNamed(AppRoutes.aiProvidersAdmin),
              isMobile,
            ),
            SizedBox(height: 16.h),
            _buildMenuItem(
              "🔧 AI Debug Tool",
              "Test & diagnose provider issues",
              Icons.bug_report_rounded,
              AppColors.accentRose,
              () => Get.to(() => const AiProviderDebugView()),
              isMobile,
            ),
            SizedBox(height: 16.h),
            _buildMenuItem(
              "Domain Management",
              "Add & manage interview domains",
              Icons.domain_rounded,
              AppColors.accentCyan,
              () => Get.toNamed(AppRoutes.domainManagement),
              isMobile,
            ),
            SizedBox(height: 16.h),
            _buildMenuItem(
              "Global Theme Config",
              "Update app colors & branding",
              Icons.palette_rounded,
              AppColors.primaryEnd,
              () => Get.toNamed(AppRoutes.adminTheme),
              isMobile,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(String title, String subtitle, IconData icon, Color color, VoidCallback onTap, bool isMobile) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 20.w : 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(isMobile ? 28.r : 28),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 12.w : 14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: isMobile ? 28.sp : 32),
            ),
            SizedBox(width: isMobile ? 20.w : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: isMobile ? 18.sp : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: isMobile ? 12.sp : 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: isMobile ? 16.sp : 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityHeader() {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isMobile = constraints.maxWidth < 600;
      return Text(
        "Recent Users",
        style: GoogleFonts.outfit(
          fontSize: isMobile ? 20.sp : 24,
          fontWeight: FontWeight.w800,
        ),
      );
    });
  }

  Widget _buildRecentUsersList(AdminController controller) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isMobile = constraints.maxWidth < 600;
      
      return Obx(() {
        if (controller.users.isEmpty) {
          return Center(
            child: Text("No users tracked yet.", style: GoogleFonts.outfit(color: Colors.grey)),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.users.length.clamp(0, 5),
          itemBuilder: (context, index) {
            final user = controller.users[index];
            return Container(
              margin: EdgeInsets.only(bottom: isMobile ? 12.h : 12),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.w : 16, 
                vertical: isMobile ? 12.h : 12,
              ),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(isMobile ? 20.r : 20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryStart.withOpacity(0.1),
                    child: Text(user.name.isNotEmpty ? user.name[0] : "U", 
                      style: TextStyle(color: AppColors.primaryStart)),
                  ),
                  SizedBox(width: isMobile ? 16.w : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: isMobile ? 14.sp : 16)),
                        Text(user.currentPrep, style: GoogleFonts.outfit(fontSize: isMobile ? 12.sp : 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("${(user.progress * 100).toInt()}%", 
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold, 
                          color: AppColors.primaryStart,
                          fontSize: isMobile ? 14.sp : 16,
                        )),
                      Text("Progress", style: GoogleFonts.outfit(fontSize: isMobile ? 10.sp : 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      });
    });
  }
}
