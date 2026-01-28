import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../controllers/interview_controller.dart';
import '../../app/themes/app_colors.dart';
import '../widgets/common_background.dart';

class InterviewView extends StatelessWidget {
  const InterviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterviewController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Handle keyboard properly
      body: CommonBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Obx(() {
                if (!controller.isDifficultySelected.value) {
                  return _buildDifficultySelection(controller, isDark);
                }
                return _buildInterviewSession(controller, isDark);
              }),
            ),
            
            // Header Actions
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                      ),
                    ),
                    const Spacer(),
                    Obx(() => controller.isDifficultySelected.value 
                      ? _buildSessionStatus(controller)
                      : const SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionStatus(InterviewController controller) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
      ),
      child: Text(
        "Q ${controller.currentQuestionIndex.value + 1}/${controller.questions.length}",
        style: GoogleFonts.outfit(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildDifficultySelection(InterviewController controller, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          SizedBox(height: 60.h),
          Text(
            "Configure Session",
            style: GoogleFonts.outfit(
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 32.h),
          
          // Model Selection
          _buildModelSelection(controller, isDark),
          
          SizedBox(height: 32.h),
          
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDifficultyCard(controller, 'Fresher', 'Entry Level', Icons.school_rounded, AppColors.accentEmerald),
                SizedBox(height: 16.h),
                _buildDifficultyCard(controller, 'Intermediate', 'Mid Level', Icons.work_rounded, AppColors.primaryStart),
                SizedBox(height: 16.h),
                _buildDifficultyCard(controller, 'Experienced', 'Senior Level', Icons.military_tech_rounded, AppColors.accentRose),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelSelection(InterviewController controller, bool isDark) {
    // Hidden because provider is globally managed via Firestore
    return const SizedBox.shrink();
  }

  Widget _buildDifficultyCard(InterviewController controller, String level, String sub, IconData icon, Color color) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    final context = Get.context!;
    return GestureDetector(
      onTap: () => controller.selectDifficulty(level),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: color.withOpacity(isDark ? 0.3 : 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16.r)),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 20.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(level, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface)),
                Text(sub, style: GoogleFonts.outfit(fontSize: 12.sp, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewSession(InterviewController controller, bool isDark) {
    return Obx(() {
      if (controller.isLoading.value) return _buildLoading();
      if (controller.questions.isEmpty) return _buildEmptyState();

      final currentQuestion = controller.questions[controller.currentQuestionIndex.value];

      return Column(
        children: [
          // Scrollable content area (Avatar + Question)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  
                  // AI Avatar
                  RepaintBoundary(child: _buildAIAvatar(controller, isDark)),
                  
                  SizedBox(height: 24.h),
                  
                  // Question
                  _buildQuestionDisplay(currentQuestion.text),
                  
                  // Hint
                  _buildHintDisplay(controller, currentQuestion),
                  
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          
          // Fixed bottom section (Input + Controls)
          Container(
            decoration: BoxDecoration(
              color: Get.theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Answer Input
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 8.h),
                  child: _buildAnswerInput(controller),
                ),
                
                // Controls (Mic, Hint, Submit)
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
                  child: _buildControls(controller),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _TalkingWave(color: AppColors.primaryStart),
          SizedBox(height: 24.h),
          Text("Generating Questions...", style: GoogleFonts.outfit(color: AppColors.primaryStart)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60.sp, color: AppColors.accentRose),
          SizedBox(height: 16.h),
          Text("Failed to load questions"),
          TextButton(onPressed: () => Get.back(), child: const Text("Try Again")),
        ],
      ),
    );
  }

  Widget _buildAIAvatar(InterviewController controller, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 70.h,
          child: Obx(() {
            switch (controller.avatarState.value) {
              case AvatarState.speaking:
                return _TalkingWave(color: AppColors.primaryStart);
              case AvatarState.listening:
                return AvatarGlow(
                  glowColor: AppColors.accentEmerald,
                  child: Icon(Icons.mic_rounded, color: AppColors.accentEmerald, size: 32.sp),
                );
              case AvatarState.thinking:
                return const CircularProgressIndicator(strokeWidth: 2);
              default:
                return Icon(Icons.face_retouching_natural_rounded, color: Colors.grey, size: 32.sp);
            }
          }),
        ),
        SizedBox(height: 8.h),
        Obx(() => Text(
          controller.avatarState.value.name.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 9.sp, 
            fontWeight: FontWeight.bold, 
            letterSpacing: 1.5, 
            color: isDark ? AppColors.primaryEnd : AppColors.primaryStart
          ),
        )),
      ],
    );
  }

  Widget _buildQuestionDisplay(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: AnimatedTextKit(
        key: ValueKey(text),
        animatedTexts: [
          TypewriterAnimatedText(
            text,
            textAlign: TextAlign.center,
            textStyle: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w700, height: 1.4),
            speed: const Duration(milliseconds: 40),
          ),
        ],
        totalRepeatCount: 1,
      ),
    );
  }

  Widget _buildHintDisplay(InterviewController controller, dynamic question) {
    return Obx(() {
      if (!controller.showHint.value) return const SizedBox.shrink();
      return Container(
        margin: EdgeInsets.all(24.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.05), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.amber.withOpacity(0.2))),
        child: Text(question.displayHint, style: GoogleFonts.outfit(fontSize: 13.sp, fontStyle: FontStyle.italic)),
      );
    });
  }

  Widget _buildAnswerInput(InterviewController controller) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller.answerController,
        maxLines: 3,
        minLines: 1,
        style: GoogleFonts.outfit(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: "Type or speak your answer...",
          hintStyle: GoogleFonts.outfit(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildControls(InterviewController controller) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Row(
      children: [
        _CircleAction(
          icon: Icons.lightbulb_outline_rounded, 
          onTap: controller.toggleHint,
          tooltip: "Get Hint",
        ),
        SizedBox(width: 12.w),
        _CircleAction(
          icon: Icons.skip_next_rounded, 
          onTap: controller.skipQuestion,
          tooltip: "Skip Question",
        ),
        const Spacer(),
        _MainMic(controller: controller),
        const Spacer(),
        _CircleAction(
          icon: Icons.send_rounded, 
          color: Colors.white,
          backgroundColor: AppColors.primaryStart,
          onTap: controller.submitAnswer,
          tooltip: "Submit Answer",
        ),
      ],
    );
  }
}

class _MainMic extends StatelessWidget {
  final InterviewController controller;
  const _MainMic({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isListening = controller.avatarState.value == AvatarState.listening;
      return GestureDetector(
        onTap: controller.toggleListening,
        child: AvatarGlow(
          animate: isListening,
          glowColor: AppColors.primaryStart,
          duration: const Duration(milliseconds: 2000),
          repeat: true,
          child: Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle, 
              gradient: AppColors.primaryGradient, 
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryStart.withOpacity(0.3), 
                  blurRadius: 15, 
                  offset: const Offset(0, 5)
                )
              ]
            ),
            child: Icon(
              isListening ? Icons.stop_rounded : Icons.mic_rounded, 
              color: Colors.white, 
              size: 28.sp
            ),
          ),
        ),
      );
    });
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback onTap;
  final String? tooltip;

  const _CircleAction({
    required this.icon, 
    this.color, 
    this.backgroundColor,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip ?? "",
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: backgroundColor ?? (isDark ? Colors.white : Colors.black).withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
          ),
          child: Icon(icon, color: color ?? (isDark ? Colors.white70 : Colors.black54), size: 22.sp),
        ),
      ),
    );
  }
}

class _TalkingWave extends StatefulWidget {
  final Color color;
  const _TalkingWave({required this.color});

  @override
  State<_TalkingWave> createState() => _TalkingWaveState();
}

class _TalkingWaveState extends State<_TalkingWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Container(
          width: 6.w,
          height: 10.h + (20.h * _controller.value * (1 - i*0.2)).abs(),
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(color: widget.color.withOpacity(0.6), borderRadius: BorderRadius.circular(3)),
        ),
      )),
    );
  }
}