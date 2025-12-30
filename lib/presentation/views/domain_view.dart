import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/domain_selection_controller.dart';
import '../controllers/theme_controller.dart';
import '../../core/utils/icon_helper.dart';
import '../../core/services/connectivity_service.dart';
import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';

class DomainView extends StatelessWidget {
  const DomainView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DomainSelectionController());
    final connectivityService = Get.find<ConnectivityService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient/Mesh
          _buildBackground(isDark),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, connectivityService),
                _buildSearchBar(controller),
                Expanded(
                  child: _buildDashboardGrid(controller),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
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
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.meshIndigo.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ConnectivityService connectivityService) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Ready to Excel?",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildStatusIndicator(connectivityService),
              SizedBox(width: 8.w),
              _buildThemeToggle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(ConnectivityService connectivityService) {
    return Obx(() {
      final isOnline = connectivityService.isOnline.value;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: (isOnline ? AppColors.success : AppColors.warning).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: (isOnline ? AppColors.success : AppColors.warning).withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.success : AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              isOnline ? "Online" : "Offline",
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: isOnline ? AppColors.success : AppColors.warning,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildThemeToggle() {
    return IconButton(
      onPressed: () => Get.find<ThemeController>().switchTheme(),
      icon: Obx(() => Icon(
        Get.find<ThemeController>().theme == ThemeMode.dark 
          ? Icons.light_mode_rounded 
          : Icons.dark_mode_rounded,
        size: 22.sp,
      )),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.05),
        padding: EdgeInsets.all(8.w),
      ),
    );
  }

  Widget _buildSearchBar(DomainSelectionController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          onChanged: controller.filterDomains,
          decoration: InputDecoration(
            hintText: "Search your professional domain...",
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryStart, size: 20.sp),
            filled: true,
            fillColor: Get.theme.cardTheme.color,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(DomainSelectionController controller) {
    return Obx(() {
      if (controller.filteredDomains.isEmpty) {
        return _buildEmptyState();
      }
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 100.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 0.85,
        ),
        itemCount: controller.filteredDomains.length,
        itemBuilder: (context, index) {
          return _buildDomainCard(controller.filteredDomains[index], index);
        },
      );
    });
  }

  Widget _buildDomainCard(dynamic domain, int index) {
    final colors = [
      AppColors.primaryStart,
      AppColors.accentRose,
      AppColors.accentEmerald,
      AppColors.accentAmber,
      AppColors.accentCyan,
      AppColors.primaryEnd,
    ];
    final color = colors[index % colors.length];

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 40)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(AppRoutes.interview, arguments: {'domain': domain.name}),
          borderRadius: BorderRadius.circular(28.r),
          child: Container(
            decoration: BoxDecoration(
              color: Get.theme.cardTheme.color,
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(color: color.withOpacity(0.1), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.r),
              child: Stack(
                children: [
                  // Decorative background element
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.05),
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            IconHelper.getIcon(domain.icon),
                            color: color,
                            size: 24.sp,
                          ),
                        ),
                        const Spacer(),
                        Hero(
                          tag: 'domain_name_${domain.name}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              domain.name,
                              style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Text(
                              "${domain.subdomains.length} paths",
                              style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_forward_rounded, 
                              size: 14.sp, 
                              color: color.withOpacity(0.5)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.lightTextSecondary.withOpacity(0.2)),
          SizedBox(height: 16.h),
          Text("No domains match your search", 
            style: TextStyle(color: AppColors.lightTextSecondary.withOpacity(0.5))
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.resumeChecker),
        icon: const Icon(Icons.rocket_launch_rounded, color: Colors.white),
        label: Text('Resume Studio', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primaryStart,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      ),
    );
  }
}
