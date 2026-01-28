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
                _buildHeader(context),
                _buildSearchBar(controller),
                _buildCategoryList(controller),
                Expanded(
                  child: _buildDashboardGrid(controller),
                ),
              ],
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Your Domain",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "Choose a field to start your AI mock interview",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.lightTextSecondary,
            ),
          ),
        ],
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
        child: Obx(() => TextField(
          onChanged: controller.filterDomains,
          decoration: InputDecoration(
            hintText: "Search your professional domain...",
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryStart, size: 20.sp),
            suffixIcon: controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, size: 20.sp),
                    onPressed: () => controller.filterDomains(''),
                  )
                : null,
            filled: true,
            fillColor: Get.theme.cardTheme.color,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          ),
        )),
      ),
    );
  }

  Widget _buildCategoryList(DomainSelectionController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            "Categories",
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryStart,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          child: Obx(() => Row(
            children: controller.categories.map((category) {
              final isSelected = controller.selectedCategory.value == category;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => controller.selectCategory(category),
                  selectedColor: AppColors.primaryStart.withOpacity(0.15),
                  checkmarkColor: AppColors.primaryStart,
                  labelStyle: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primaryStart : AppColors.lightTextSecondary,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryStart.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid(DomainSelectionController controller) {
    return Obx(() {
      // Show loading indicator while fetching domains
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryStart),
              SizedBox(height: 16.h),
              Text(
                "Loading domains...",
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  color: AppColors.primaryStart,
                ),
              ),
            ],
          ),
        );
      }
      
      if (controller.filteredDomains.isEmpty) {
        return _buildEmptyState();
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2;
          double aspectRatio = 0.85;
          
          if (constraints.maxWidth > 1200) {
            crossAxisCount = 4;
            aspectRatio = 1.0;
          } else if (constraints.maxWidth > 800) {
            crossAxisCount = 3;
            aspectRatio = 0.95;
          } else {
            crossAxisCount = 2;
            aspectRatio = 0.78; // Increased depth for mobile
          }

          return RepaintBoundary(
            child: GridView.builder(
              padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 100.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: aspectRatio,
              ),
              itemCount: controller.filteredDomains.length,
              itemBuilder: (context, index) {
                return _buildDomainCard(controller.filteredDomains[index], index);
              },
            ),
          );
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
      child: RepaintBoundary(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.toNamed(AppRoutes.practiceMode, arguments: {'domain': domain.name}),
            borderRadius: BorderRadius.circular(28.r),
            child: Container(
              decoration: BoxDecoration(
                color: Get.theme.cardColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(color: color.withOpacity(0.1), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28.r),
                child: Stack(
                  children: [
                    Positioned(
                      top: -15.r,
                      right: -15.r,
                      child: Icon(
                        IconHelper.getIcon(domain.iconName),
                        color: color.withOpacity(0.04),
                        size: 100.r,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              IconHelper.getIcon(domain.iconName),
                              color: color,
                              size: 22.sp,
                            ),
                          ),
                          const Spacer(),
                          Hero(
                            tag: 'domain_name_${domain.name}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                domain.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          if (domain.subdomains.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Wrap(
                                spacing: 4.w,
                                runSpacing: 4.h,
                                children: (domain.subdomains as List<dynamic>).take(2).map((sub) => Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    sub.toString(),
                                    style: GoogleFonts.outfit(
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ),
                          Row(
                            children: [
                              Text(
                                "Start Training",
                                style: GoogleFonts.outfit(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: color.withOpacity(0.7),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    final controller = Get.find<DomainSelectionController>();
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded, 
              size: 64.sp, 
              color: AppColors.lightTextSecondary.withOpacity(0.3)
            ),
            SizedBox(height: 16.h),
            Text(
              "No domains found", 
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextSecondary.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 8.h),
            if (controller.searchQuery.value.isNotEmpty)
              Text(
                'No results for "${controller.searchQuery.value}"',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.lightTextSecondary.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 16.h),
            if (controller.searchQuery.value.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => controller.filterDomains(''),
                icon: Icon(Icons.clear_rounded, size: 18.sp),
                label: Text('Clear Search'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
