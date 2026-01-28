import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/domain_management_controller.dart';
import '../widgets/widgets_export.dart';
import '../../app/themes/app_colors.dart';
import '../../data/models/domain_model.dart';
import '../../core/utils/icon_helper.dart';

class DomainManagementView extends StatelessWidget {
  const DomainManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DomainManagementController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CommonAppBar(
        title: "Domain Management",
      ),
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.all(24.w),
                child: CommonTextField(
                  hint: "Search domains...",
                  prefixIcon: Icons.search,
                  onChanged: (value) => controller.searchQuery.value = value,
                ),
              ),

              // Stats Cards
              _buildStatsRow(controller, isDark),
              
              SizedBox(height: 16.h),

              // Domains List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDark ? AppColors.primaryEnd : AppColors.primaryStart,
                      ),
                    );
                  }

                  if (controller.filteredDomains.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 50.h),
                          CommonEmptyState(
                            icon: Icons.domain_disabled,
                            title: "No Domains Found",
                            message: controller.searchQuery.value.isEmpty
                                ? "Restore the default categories to get started immediately, or create a custom one."
                                : "No domains match your search query.",
                          ),
                          if (controller.searchQuery.value.isEmpty) ...[
                            SizedBox(height: 24.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40.w),
                              child: CommonButton(
                                label: "Restore Default Domains",
                                icon: Icons.auto_awesome,
                                onPressed: () => controller.seedDefaults(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: controller.filteredDomains.length,
                    itemBuilder: (context, index) {
                      final domain = controller.filteredDomains[index];
                      return _buildDomainCard(domain, controller, isDark);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDomainDialog(controller, isDark),
        backgroundColor: isDark ? AppColors.primaryEnd : AppColors.primaryStart,
        icon: const Icon(Icons.add),
        label: const Text("Add Domain"),
      ),
    );
  }

  Widget _buildStatsRow(DomainManagementController controller, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => CommonCard(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  Icon(
                    Icons.domain,
                    color: AppColors.accentCyan,
                    size: 32.r,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${controller.domains.length}',
                    style: GoogleFonts.outfit(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Total',
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Obx(() => CommonCard(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.accentEmerald,
                    size: 32.r,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${controller.domains.where((d) => d.isActive).length}',
                    style: GoogleFonts.outfit(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Active',
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Obx(() => CommonCard(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  Icon(
                    Icons.category,
                    color: AppColors.accentAmber,
                    size: 32.r,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${controller.categories.length}',
                    style: GoogleFonts.outfit(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Categories',
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainCard(
    DomainModel domain,
    DomainManagementController controller,
    bool isDark,
  ) {
    return CommonCard(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: domain.isActive
                      ? AppColors.primaryStart.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  IconHelper.getIcon(domain.iconName),
                  color: domain.isActive ? AppColors.primaryStart : Colors.grey,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 16.w),
              
              // Name and Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      domain.name,
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        domain.category,
                        style: GoogleFonts.outfit(
                          fontSize: 10.sp,
                          color: AppColors.accentCyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Active Toggle
              Switch(
                value: domain.isActive,
                onChanged: (_) => controller.toggleStatus(domain),
                activeColor: AppColors.accentEmerald,
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // Description and Subdomains
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                domain.description,
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (domain.subdomains.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 4.w,
                  runSpacing: 4.h,
                  children: domain.subdomains.map((sub) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryStart.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      sub,
                      style: GoogleFonts.outfit(
                        fontSize: 9.sp,
                        color: AppColors.primaryStart,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  controller.startEdit(domain);
                  _showDomainDialog(controller, isDark);
                },
                icon: Icon(Icons.edit_outlined, size: 20.r),
                color: AppColors.accentCyan,
              ),
              IconButton(
                onPressed: () => controller.deleteDomain(domain),
                icon: Icon(Icons.delete_outline, size: 20.r),
                color: AppColors.accentRose,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDomainDialog(DomainManagementController controller, bool isDark) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 500.w, maxHeight: 600.h),
          padding: EdgeInsets.all(24.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.editingDomain.value == null
                          ? "Add New Domain"
                          : "Edit Domain",
                      style: GoogleFonts.outfit(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        controller.cancelEdit();
                        Get.back();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                
                SizedBox(height: 24.h),
                
                // Name Field
                CommonTextField(
                  label: "Domain Name",
                  hint: "e.g., Flutter Development",
                  controller: controller.nameController,
                  prefixIcon: Icons.title,
                ),
                
                SizedBox(height: 16.h),
                
                // Category Dropdown
                Text(
                  "Category",
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: DropdownButton<String>(
                    value: controller.selectedCategory.value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: controller.defaultCategories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedCategory.value = value;
                      }
                    },
                  ),
                )),
                
                SizedBox(height: 16.h),
                
                // Icon Selection
                Text(
                  "Icon",
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: DropdownButton<String>(
                    value: controller.selectedIcon.value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: controller.iconOptions.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Row(
                          children: [
                            Icon(IconHelper.getIcon(entry.key), size: 20.r),
                            SizedBox(width: 12.w),
                            Text(entry.value),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedIcon.value = value;
                      }
                    },
                  ),
                )),
                
                SizedBox(height: 16.h),
                
                // Description Field
                CommonTextField(
                  label: "Description",
                  hint: "Brief description of this domain",
                  controller: controller.descriptionController,
                  maxLines: 2,
                  prefixIcon: Icons.description,
                ),
                
                SizedBox(height: 16.h),

                // Subdomains Field (New)
                CommonTextField(
                  label: "Topics / Subdomains",
                  hint: "e.g., Widgets, State Management, Navigation",
                  controller: controller.subdomainsController,
                  maxLines: 2,
                  prefixIcon: Icons.list_alt_rounded,
                ),
                
                SizedBox(height: 8.h),
                Text(
                  "Separate topics with commas",
                  style: GoogleFonts.outfit(
                    fontSize: 10.sp,
                    color: Colors.grey,
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // Active Toggle
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Active",
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Switch(
                      value: controller.isActive.value,
                      onChanged: (value) => controller.isActive.value = value,
                      activeColor: AppColors.accentEmerald,
                    ),
                  ],
                )),
                
                SizedBox(height: 24.h),
                
                // Save Button
                Obx(() => CommonButton(
                  label: controller.editingDomain.value == null
                      ? "Add Domain"
                      : "Update Domain",
                  onPressed: controller.saveDomain,
                  isLoading: controller.isSaving.value,
                  icon: Icons.save,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
