import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/themes/app_colors.dart';
import '../controllers/ai_provider_controller.dart';
import '../../data/models/ai_model.dart';
import '../../app/routes/app_routes.dart';
import '../widgets/common_background.dart';
import '../widgets/common_card.dart';
import '../widgets/common_button.dart';

class PracticeModeSelectionView extends StatefulWidget {
  const PracticeModeSelectionView({super.key});

  @override
  State<PracticeModeSelectionView> createState() => _PracticeModeSelectionViewState();
}

class _PracticeModeSelectionViewState extends State<PracticeModeSelectionView> {
  String selectedDomain = 'Flutter';
  String selectedDifficulty = 'medium';
  String selectedProviderId = '';
  int questionCount = 5;

  final List<String> difficulties = ['easy', 'medium', 'hard'];
  final aiController = Get.put(AiProviderController());

  @override
  void initState() {
    super.initState();
    // Use domain from arguments if available
    if (Get.arguments != null && Get.arguments['domain'] != null) {
      selectedDomain = Get.arguments['domain'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 32.h),
                  
                  _buildSectionTitle(
                    "AI Interviewer",
                    onRefresh: () async {
                      Get.snackbar("Syncing", "Fetching latest models...", 
                        snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
                      // Since it's a stream, it updates automatically, but we can re-verify if needed
                    }
                  ),
                  
                  // Firestore-based Provider Dropdown
                  Obx(() {
                     if (aiController.isLoading.value) {
                       return const Center(child: CircularProgressIndicator());
                     }
                     
                     // ONLY show active models - don't fallback to showing all
                     final activeModels = aiController.aiModels.where((m) => m.isActive).toList();
                     
                     if (activeModels.isEmpty) {
                       return _buildNoProvidersFound();
                     }
                     
                     // Use target ID or default to first active model
                     String currentId = selectedProviderId;
                     if (currentId.isEmpty || !activeModels.any((m) => m.id == currentId)) {
                        currentId = activeModels.first.id;
                        // Schedule selection update for the next frame to avoid build error
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                           if (mounted) setState(() => selectedProviderId = currentId);
                        });
                     }
                     
                     return _buildProviderDropdown(activeModels, currentId);
                  }),
                  
                  SizedBox(height: 32.h),
                  _buildSectionTitle("Difficulty & Count"),
                  _buildSettingsRow(),
                  SizedBox(height: 48.h),
                  _buildStartButton(),
                ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Practice Hub",
          style: GoogleFonts.outfit(
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryStart,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Choose how you want to sharpen your skills.",
          style: GoogleFonts.outfit(
            fontSize: 16.sp,
            color: AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onRefresh}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onRefresh != null)
            IconButton(
              icon: Icon(Icons.sync, size: 20.sp, color: AppColors.primaryStart),
              onPressed: onRefresh,
              tooltip: "Sync with Server",
            ),
        ],
      ),
    );
  }

  Widget _buildProviderDropdown(List<AiModel> models, String currentId) {
    if (models.isEmpty) return const SizedBox.shrink();

    return CommonCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentId,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryStart),
          items: models.map<DropdownMenuItem<String>>((model) {
            final isGemini = model.provider.toLowerCase() == 'gemini';
            return DropdownMenuItem<String>(
              value: model.id,
              child: Row(
                children: [
                  Icon(
                    isGemini ? Icons.auto_awesome : Icons.bolt,
                    size: 18.sp,
                    color: isGemini ? Colors.blue : Colors.orange,
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        model.provider.toUpperCase(),
                        style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        model.model,
                        style: GoogleFonts.outfit(fontSize: 10.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (id) {
            if (id != null) {
              setState(() => selectedProviderId = id);
            }
          },
        ),
      ),
    );
  }

  Widget _buildNoProvidersFound() {
    return CommonCard(
      padding: EdgeInsets.all(16.w),
      backgroundColor: Colors.red.withOpacity(0.1),
      useGlassmorphism: false,
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              "No AI Providers found in database. Please configure them in Admin Panel.",
              style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDifficultySelection(),
        SizedBox(height: 24.h),
        Row(
          children: [
            Icon(Icons.format_list_numbered_rounded, color: AppColors.primaryStart, size: 20.sp),
            SizedBox(width: 12.w),
            Text("Number of Questions: $questionCount", style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600)),
          ],
        ),
        Slider(
          value: questionCount.toDouble(),
          min: 3,
          max: 15,
          divisions: 12,
          activeColor: AppColors.primaryStart,
          inactiveColor: AppColors.primaryStart.withOpacity(0.2),
          onChanged: (val) => setState(() => questionCount = val.toInt()),
        ),
      ],
    );
  }

  Widget _buildDifficultySelection() {
    return Row(
      children: difficulties.map((d) {
        final isSelected = selectedDifficulty == d;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedDifficulty = d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryStart : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected ? AppColors.primaryStart : Colors.grey.withOpacity(0.3),
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.primaryStart.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] : [],
              ),
              child: Center(
                child: Text(
                  d.capitalizeFirst!,
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.white : null,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStartButton() {
    return CommonButton(
      label: "Start Practice Session",
      type: ButtonType.primary,
      icon: Icons.play_arrow_rounded,
      onPressed: () {
        // Identify selected model from Firestore List
        final selectedModel = aiController.aiModels.firstWhereOrNull((m) => m.id == selectedProviderId);
        
        if (selectedModel == null) {
          Get.snackbar("Error", "Please select a valid AI Provider");
          return;
        }

        Get.toNamed(AppRoutes.interview, arguments: {
          'domain': selectedDomain,
          'difficulty': selectedDifficulty,
          'count': questionCount,
          // PASS EXPLICIT CREDENTIALS from Firestore
          'provider': selectedModel.provider,
          'apiKey': selectedModel.apiKey,
          'model': selectedModel.model,
        });
      },
    );
  }
}
