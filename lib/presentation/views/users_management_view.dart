import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/themes/app_colors.dart';
import '../controllers/admin_controller.dart';
import '../widgets/responsive_admin_layout.dart';
import '../../data/models/user_model.dart';
import 'package:intl/intl.dart';

class UsersManagementView extends StatelessWidget {
  const UsersManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return ResponsiveAdminLayout(
      title: 'User Management',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.w : 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(controller, isMobile),
            SizedBox(height: 24.h),
            _buildUsersList(controller, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AdminController controller, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Users",
                style: GoogleFonts.outfit(
                  fontSize: isMobile ? 22.sp : 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Obx(() => Text(
                    "${controller.users.length} registered users",
                    style: GoogleFonts.outfit(
                      fontSize: isMobile ? 12.sp : 14.sp,
                      color: Colors.grey,
                    ),
                  )),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryStart, AppColors.primaryEnd],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people, color: Colors.white, size: 18.sp),
              SizedBox(width: 8.w),
              Obx(() => Text(
                    "${controller.users.length}",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 16.sp : 18.sp,
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsersList(AdminController controller, bool isMobile) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.users.isEmpty) {
        return _buildEmptyState(isMobile);
      }

      return isMobile
          ? _buildMobileList(controller)
          : _buildDesktopTable(controller);
    });
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            "No users found",
            style: GoogleFonts.outfit(fontSize: 18.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Mobile Card View
  Widget _buildMobileList(AdminController controller) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.users.length,
      itemBuilder: (context, index) {
        final user = controller.users[index];
        return _buildUserCard(user, controller, true);
      },
    );
  }

  // Desktop Table View
  Widget _buildDesktopTable(AdminController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryStart.withOpacity(0.1), AppColors.primaryEnd.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildHeaderCell("Name")),
                Expanded(flex: 2, child: _buildHeaderCell("Email")),
                Expanded(flex: 2, child: _buildHeaderCell("Practice Field")),
                Expanded(flex: 1, child: _buildHeaderCell("Progress")),
                Expanded(flex: 2, child: _buildHeaderCell("Last Active")),
                Expanded(flex: 1, child: _buildHeaderCell("Actions")),
              ],
            ),
          ),
          // Table Body
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.users.length,
            itemBuilder: (context, index) {
              final user = controller.users[index];
              return _buildTableRow(user, controller, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontWeight: FontWeight.bold,
        fontSize: 13.sp,
        color: AppColors.primaryStart,
      ),
    );
  }

  Widget _buildTableRow(UserModel user, AdminController controller, int index) {
    final isEven = index % 2 == 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isEven ? Colors.grey.shade50 : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildNameCell(user)),
          Expanded(flex: 2, child: _buildTextCell(user.email)),
          Expanded(flex: 2, child: _buildPracticeCell(user.currentPrep)),
          Expanded(flex: 1, child: _buildProgressCell(user.progress)),
          Expanded(flex: 2, child: _buildDateCell(user.lastActive)),
          Expanded(flex: 1, child: _buildActionsCell(user, controller)),
        ],
      ),
    );
  }

  Widget _buildNameCell(UserModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16.r,
          backgroundColor: AppColors.primaryStart.withOpacity(0.1),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: GoogleFonts.outfit(
              color: AppColors.primaryStart,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            user.name,
            style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTextCell(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey.shade700),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPracticeCell(String field) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryStart.withOpacity(0.1), AppColors.primaryEnd.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        field,
        style: GoogleFonts.outfit(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryStart,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildProgressCell(double progress) {
    final percentage = (progress * 100).toInt();
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.7 ? Colors.green : (progress > 0.4 ? Colors.orange : Colors.red),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          "$percentage%",
          style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDateCell(DateTime? date) {
    if (date == null) return _buildTextCell('Never');
    final formatter = DateFormat('dd MMM, HH:mm');
    return _buildTextCell(formatter.format(date));
  }

  Widget _buildActionsCell(UserModel user, AdminController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
          iconSize: 20.sp,
          onPressed: () => _showEditDialog(user, controller),
          tooltip: "Edit User",
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        SizedBox(width: 4.w),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          iconSize: 20.sp,
          onPressed: () => _confirmDelete(user, controller),
          tooltip: "Delete User",
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  // Mobile Card
  Widget _buildUserCard(UserModel user, AdminController controller, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.primaryStart.withOpacity(0.1),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: GoogleFonts.outfit(
                    color: AppColors.primaryStart,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                onPressed: () => _showEditDialog(user, controller),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(user, controller),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: Colors.grey.shade200),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.work_outline, "Practice Field", user.currentPrep),
          SizedBox(height: 8.h),
          _buildProgressRow(user.progress),
          SizedBox(height: 8.h),
          _buildInfoRow(
            Icons.access_time,
            "Last Active",
            DateFormat('dd MMM yyyy, HH:mm').format(user.lastActive!),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey),
        SizedBox(width: 8.w),
        Text(
          "$label: ",
          style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow(double progress) {
    final percentage = (progress * 100).toInt();
    return Row(
      children: [
        Icon(Icons.trending_up, size: 16.sp, color: Colors.grey),
        SizedBox(width: 8.w),
        Text(
          "Progress: ",
          style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.7 ? Colors.green : (progress > 0.4 ? Colors.orange : Colors.red),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          "$percentage%",
          style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _confirmDelete(UserModel user, AdminController controller) {
    Get.defaultDialog(
      title: "Delete User",
      titleStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      middleText: "Are you sure you want to delete ${user.name}?\n\nThis will remove:\n• User profile\n• Progress data\n• Presence status\n\nThis action cannot be undone.",
      middleTextStyle: GoogleFonts.outfit(fontSize: 13.sp),
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.grey,
      onConfirm: () async {
        await controller.deleteUser(user.id);
        Get.back();
        Get.snackbar(
          "Success",
          "${user.name} has been deleted",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  void _showEditDialog(UserModel user, AdminController controller) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final practiceController = TextEditingController(text: user.currentPrep);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 400.w),
          padding: EdgeInsets.all(24.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edit User",
                      style: GoogleFonts.outfit(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                // Name Field
                Text(
                  "Name",
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Enter name",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  style: GoogleFonts.outfit(fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),
                // Email Field
                Text(
                  "Email",
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Enter email",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  style: GoogleFonts.outfit(fontSize: 14.sp),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.h),
                // Practice Field
                Text(
                  "Practice Field",
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: practiceController,
                  decoration: InputDecoration(
                    hintText: "e.g., Java, Flutter, DSA",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.work_outline),
                  ),
                  style: GoogleFonts.outfit(fontSize: 14.sp),
                ),
                SizedBox(height: 32.h),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.outfit(fontSize: 14.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            Get.snackbar("Error", "Name cannot be empty");
                            return;
                          }
                          if (emailController.text.trim().isEmpty) {
                            Get.snackbar("Error", "Email cannot be empty");
                            return;
                          }

                          await controller.updateUser(
                            userId: user.id,
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            currentPrep: practiceController.text.trim(),
                          );
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryStart,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Save Changes",
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
