import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/resume_builder_controller.dart';
import '../../app/themes/app_colors.dart';
import '../widgets/common_background.dart';
import '../widgets/common_card.dart';

class ResumeBuilderView extends StatelessWidget {
  const ResumeBuilderView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResumeBuilderController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildModernStepper(controller),
              Expanded(
                child: Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(animation),
                      child: child,
                    ));
                  },
                  child: _buildStepContent(controller, isDark),
                )),
              ),
              _buildBottomDock(controller, isDark),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          const Spacer(),
          Text(
            "BUILDER PROTOCOL",
            style: GoogleFonts.outfit(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: AppColors.primaryStart,
            ),
          ),
          const Spacer(),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  Widget _buildModernStepper(ResumeBuilderController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
      child: Obx(() => Row(
        children: [
          _buildStepNode(0, controller.currentStep.value >= 0),
          _buildStepLine(controller.currentStep.value >= 1),
          _buildStepNode(1, controller.currentStep.value >= 1),
          _buildStepLine(controller.currentStep.value >= 2),
          _buildStepNode(2, controller.currentStep.value >= 2),
          _buildStepLine(controller.currentStep.value >= 3),
          _buildStepNode(3, controller.currentStep.value >= 3),
        ],
      )),
    );
  }

  Widget _buildStepNode(int step, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 14.w,
      height: 14.w,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryStart : Colors.grey.withOpacity(0.2),
        shape: BoxShape.circle,
        boxShadow: isActive ? [
          BoxShadow(color: AppColors.primaryStart.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)
        ] : [],
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 2.h,
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryStart : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildStepContent(ResumeBuilderController controller, bool isDark) {
    switch (controller.currentStep.value) {
      case 0: return _buildPersonalInfoStep(controller, isDark);
      case 1: return _buildEducationStep(controller, isDark);
      case 2: return _buildExperienceStep(controller, isDark);
      case 3: return _buildSkillsStep(controller, isDark);
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalInfoStep(ResumeBuilderController controller, bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey(0),
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader("Builder Protocol", "Choose your professional architecture"),
          SizedBox(height: 32.h),
          
          // Smart Prompt Section
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.primaryStart.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.primaryStart.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: AppColors.primaryStart, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text("SMART GENERATE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10.sp, letterSpacing: 1, color: AppColors.primaryStart)),
                  ],
                ),
                SizedBox(height: 12.h),
                Text("Describe your career in a few sentences, and our AI will architect the rest.", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                SizedBox(height: 16.h),
                _buildStudioField(controller.summaryController, "e.g. I am a Flutter dev with 3 years exp in fintech...", Icons.psychology_rounded, maxLines: 4),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.generateResumeTemplate(), 
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryStart, foregroundColor: Colors.white),
                    child: const Text("GENERATE FROM AI"),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 32.h),
          _buildDivider(),
          SizedBox(height: 32.h),
          
          _buildStepHeader("Identity", "Your basic professional identifiers"),
          SizedBox(height: 20.h),
          _buildStudioField(controller.nameController, "Full Identity", Icons.person_rounded),
          SizedBox(height: 20.h),
          _buildStudioField(controller.emailController, "Primary Email", Icons.alternate_email_rounded, type: TextInputType.emailAddress),
          SizedBox(height: 20.h),
          _buildStudioField(controller.phoneController, "Contact Number", Icons.phone_iphone_rounded, type: TextInputType.phone),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.grey.withOpacity(0.1))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text("OR MANUAL ENTRY", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.grey.withOpacity(0.5))),
        ),
        Expanded(child: Container(height: 1, color: Colors.grey.withOpacity(0.1))),
      ],
    );
  }

  Widget _buildEducationStep(ResumeBuilderController controller, bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey(1),
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepHeader("Academics", "Your educational background"),
              _buildAddButton(controller.addEducation),
            ],
          ),
          SizedBox(height: 24.h),
          Obx(() => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.educationList.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
            itemBuilder: (context, idx) {
              return _buildRepeaterBlock(
                onDelete: () => controller.removeEducation(idx),
                children: [
                  _buildInlineField("Institution Name", (v) => controller.educationList[idx]['school'] = v, val: controller.educationList[idx]['school']),
                  SizedBox(height: 12.h),
                  _buildInlineField("Certification / Degree", (v) => controller.educationList[idx]['degree'] = v, val: controller.educationList[idx]['degree']),
                  SizedBox(height: 12.h),
                  _buildInlineField("Graduation Year", (v) => controller.educationList[idx]['year'] = v, val: controller.educationList[idx]['year']),
                ],
              );
            },
          )),
          if (controller.educationList.isEmpty) _buildEmptyBlock("No Academic Records", Icons.school_rounded),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildExperienceStep(ResumeBuilderController controller, bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey(2),
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepHeader("Experience", "Professional work history"),
              _buildAddButton(controller.addExperience),
            ],
          ),
          SizedBox(height: 24.h),
          Obx(() => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.experienceList.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
            itemBuilder: (context, idx) {
              return _buildRepeaterBlock(
                onDelete: () => controller.removeExperience(idx),
                children: [
                  _buildInlineField("Organization Name", (v) => controller.experienceList[idx]['company'] = v, val: controller.experienceList[idx]['company']),
                  SizedBox(height: 12.h),
                  _buildInlineField("Assigned Role", (v) => controller.experienceList[idx]['role'] = v, val: controller.experienceList[idx]['role']),
                  SizedBox(height: 12.h),
                  _buildInlineField("Timeline (e.g. 2021 - Present)", (v) => controller.experienceList[idx]['duration'] = v, val: controller.experienceList[idx]['duration']),
                  SizedBox(height: 12.h),
                  _buildInlineField("Accomplishments", (v) => controller.experienceList[idx]['description'] = v, val: controller.experienceList[idx]['description'], lines: 3),
                ],
              );
            },
          )),
          if (controller.experienceList.isEmpty) _buildEmptyBlock("No Professional Records", Icons.work_history_rounded),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSkillsStep(ResumeBuilderController controller, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader("Capabilities", "Core professional skills"),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(child: _buildStudioField(controller.skillController, "Add Technical Skill", Icons.bolt_rounded)),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: controller.addSkill,
                child: Container(
                  height: 56.h,
                  width: 56.h,
                  decoration: BoxDecoration(color: AppColors.primaryStart, borderRadius: BorderRadius.circular(16.r)),
                  child: const Icon(Icons.add_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: Obx(() => Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.skills.map(_buildSkillChip).toList(),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primaryStart.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryStart.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(skill, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.primaryStart)),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => Get.find<ResumeBuilderController>().removeSkill(skill),
            child: Icon(Icons.close_rounded, size: 14.sp, color: AppColors.primaryStart),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Get.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1)),
        Text(sub, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStudioField(TextEditingController ctrl, String hint, IconData icon, {TextInputType? type, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryStart, size: 20.sp),
        filled: true,
        fillColor: Get.theme.cardTheme.color?.withOpacity(0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
    );
  }

  Widget _buildInlineField(String hint, Function(String) onC, {String? val, int lines = 1}) {
    return TextFormField(
      initialValue: val,
      onChanged: onC,
      maxLines: lines,
      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        fillColor: Colors.transparent,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
    );
  }

  Widget _buildRepeaterBlock({required List<Widget> children, required VoidCallback onDelete}) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Get.theme.cardTheme.color?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.remove_circle_outline_rounded, color: AppColors.accentRose, size: 18.sp),
              ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAddButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(color: AppColors.primaryStart.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
        child: Row(
          children: [
            Icon(Icons.add_rounded, size: 16.sp, color: AppColors.primaryStart),
            SizedBox(width: 4.w),
            Text("ADD", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: AppColors.primaryStart, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBlock(String msg, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          Icon(icon, size: 40.sp, color: Colors.grey.withOpacity(0.2)),
          SizedBox(height: 12.h),
          Text(msg, style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildBottomDock(ResumeBuilderController controller, bool isDark) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          Obx(() => controller.currentStep.value > 0
            ? Row(
                children: [
                  _buildDockCircle(controller.previousStep, Icons.chevron_left_rounded),
                  SizedBox(width: 16.w),
                ],
              )
            : const SizedBox.shrink()),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryStart,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 18.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                elevation: 0,
              ),
              child: Obx(() => Text(
                controller.currentStep.value == 3 ? "EXECUTE ANALYSIS" : "CONTINUE",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp, letterSpacing: 1),
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockCircle(VoidCallback onTap, IconData icon) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.grey, size: 24.sp),
      ),
    );
  }
}
