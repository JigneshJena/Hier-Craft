import 'package:flutter/material.dart';
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Select Your Domain",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Mode Indicator
          Obx(() => Container(
            margin: EdgeInsets.only(right: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: connectivityService.isOnline.value
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: connectivityService.isOnline.value
                    ? AppColors.success
                    : AppColors.warning,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: connectivityService.isOnline.value
                        ? AppColors.success
                        : AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  connectivityService.isOnline.value ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: connectivityService.isOnline.value
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              ],
            ),
          )),
          IconButton(
            onPressed: () {
              Get.find<ThemeController>().switchTheme();
            },
            icon: Obx(() => Icon(
              Get.find<ThemeController>().theme == ThemeMode.dark 
                ? Icons.light_mode_outlined 
                : Icons.dark_mode_outlined
            )),
          ),
        ],
      ),
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
              SizedBox(height: 8.h),
              _buildSearchBar(controller),
              Expanded(child: _buildDomainGrid(controller)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.resumeChecker),
        icon: const Icon(Icons.description),
        label: const Text('Resume Checker'),
        backgroundColor: AppColors.gradientStart,
        elevation: 4,
      ),
    );
  }

  Widget _buildSearchBar(DomainSelectionController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: TextField(
        onChanged: controller.filterDomains,
        decoration: InputDecoration(
          hintText: "Search domain...",
          prefixIcon: Icon(Icons.search, color: Get.theme.colorScheme.primary),
          filled: true,
          fillColor: Get.theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.w),
        ),
      ),
    );
  }

  Widget _buildDomainGrid(DomainSelectionController controller) {
    return Obx(() {
      if (controller.filteredDomains.isEmpty) {
        return const Center(child: Text("No domains found"));
      }
      return GridView.builder(
        padding: EdgeInsets.all(20.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15.w,
          mainAxisSpacing: 15.h,
          childAspectRatio: 0.9,
        ),
        itemCount: controller.filteredDomains.length,
        itemBuilder: (context, index) {
          final domain = controller.filteredDomains[index];
          return _buildDomainCard(domain, index);
        },
      );
    });
  }

  Widget _buildDomainCard(dynamic domain, int index) {
    // Use different gradient colors for visual variety
    final gradients = [
      AppColors.primaryGradient,
      AppColors.accentGradient,
      LinearGradient(colors: [AppColors.accentEmerald, AppColors.gradientEnd]),
      LinearGradient(colors: [AppColors.gradientMid, AppColors.accentPink]),
    ];
    final gradient = gradients[index % gradients.length];

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)), // Stagger animation
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut, // Bouncy curve
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.interview, arguments: {
            'domain': domain.name,
          });
        },
        borderRadius: BorderRadius.circular(20.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              width: 2,
              color: Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gradient Border Effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    gradient: gradient,
                  ),
                  child: Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'domain_icon_${domain.name}',
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          gradient: gradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Get.theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          IconHelper.getIcon(domain.icon),
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      domain.name,
                      textAlign: TextAlign.center,
                      style: Get.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "${domain.subdomains.length} Subdomains",
                      style: Get.theme.textTheme.bodySmall?.copyWith(fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
