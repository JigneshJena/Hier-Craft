import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../controllers/interview_controller.dart';
import '../../core/services/voice_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../app/themes/app_colors.dart';

class InterviewView extends StatelessWidget {
  const InterviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterviewController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          _buildBackground(isDark),
          
          SafeArea(
            child: Obx(() {
              if (!controller.isDifficultySelected.value) {
                return _buildDifficultySelection(controller, isDark);
              }
              return _buildInterviewSession(controller, isDark);
            }),
          ),
          
          // Header Actions (Always visible)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                  Obx(() => controller.isDifficultySelected.value 
                    ? _buildSessionStatus(controller)
                    : const SizedBox.shrink()),
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
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 100.h,
            left: -50.w,
            child: _buildBlurCircle(AppColors.meshIndigo, 250.w),
          ),
          Positioned(
            bottom: 100.h,
            right: -50.w,
            child: _buildBlurCircle(AppColors.meshRose, 250.w),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.15), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildSessionStatus(InterviewController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        "Question ${controller.currentQuestionIndex.value + 1}/${controller.questions.length}",
        style: TextStyle(
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 80.h),
          Text(
            "Configure Session",
            style: Get.theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Setting up your AI environment for optimal performance",
            textAlign: TextAlign.center,
            style: Get.theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 40.h),
          
          // Model Selection (Professional Toggle)
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                _buildModelToggle(controller, 'gemini', 'Gemini AI'),
                _buildModelToggle(controller, 'groq', 'Groq Ultra'),
              ],
            ),
          ),
          
          SizedBox(height: 32.h),
          
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDifficultyCard(controller, 'Fresher', 'Junior Role', Icons.school_rounded, AppColors.accentEmerald),
                SizedBox(height: 16.h),
                _buildDifficultyCard(controller, 'Intermediate', 'Pro Specialist', Icons.work_rounded, AppColors.primaryStart),
                SizedBox(height: 16.h),
                _buildDifficultyCard(controller, 'Experienced', 'Senior Lead', Icons.military_tech_rounded, AppColors.accentRose),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelToggle(InterviewController controller, String provider, String label) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedProvider.value == provider;
        return GestureDetector(
          onTap: () => controller.selectedProvider.value = provider,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryStart : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: isSelected ? [
                BoxShadow(color: AppColors.primaryStart.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
              ] : [],
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDifficultyCard(InterviewController controller, String level, String sub, IconData icon, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.selectDifficulty(level),
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Get.theme.cardTheme.color?.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(icon, color: color, size: 28.sp),
              ),
              SizedBox(width: 20.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level, style: Get.theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  Text(sub, style: Get.theme.textTheme.bodySmall),
                ],
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: Colors.grey.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterviewSession(InterviewController controller, bool isDark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildAdvancedLoading();
      }

      if (controller.questions.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, color: AppColors.accentRose, size: 64.sp),
                SizedBox(height: 24.h),
                Text(
                  "No Questions Available",
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                Text(
                  "We couldn't generate questions for this session. Please check your internet or try a different model.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 32.h),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryStart,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  child: const Text("Go Back"),
                ),
              ],
            ),
          ),
        );
      }

      final currentQuestion = controller.questions[controller.currentQuestionIndex.value];

      return Column(
        children: [
          SizedBox(height: 60.h),
          
          // AI Avatar Section
          _buildAIAvatar(controller, isDark),
          
          SizedBox(height: 24.h),
          
          // Question Section
          Expanded(
            child: _buildQuestionSection(currentQuestion.text, isDark),
          ),
          
          // Input Section
          _buildFloatingInputSection(controller, isDark),
          
          // Actions Section
          _buildActionDock(controller, isDark),
          
          SizedBox(height: 24.h),
        ],
      );
    });
  }

  Widget _buildAdvancedLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTalkingWave(AppColors.primaryStart),
          SizedBox(height: 40.h),
          Text(
            "Initializing neural engine...",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: AppColors.primaryStart,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAvatar(InterviewController controller, bool isDark) {
    return Obx(() {
      Color color;
      String status;
      Widget effect;

      switch (controller.avatarState.value) {
        case AvatarState.speaking:
          color = AppColors.primaryStart;
          status = "EXPLAINING CONTEXT";
          effect = _buildTalkingWave(color);
          break;
        case AvatarState.listening:
          color = AppColors.accentEmerald;
          status = "LISTENING INTENTLY";
          effect = _buildListeningPulse(color);
          break;
        case AvatarState.thinking:
          color = AppColors.accentAmber;
          status = "EVALUATING RESPONSE";
          effect = _buildThinkingOrbit(color);
          break;
        default:
          color = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
          status = "AWAITING INPUT";
          effect = _buildIdleGlow(color);
      }

      return Column(
        children: [
          SizedBox(height: 120.h, child: effect),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTalkingWave(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) => _WaveBar(index: index, color: color)),
    );
  }

  Widget _buildListeningPulse(Color color) {
    return AvatarGlow(
      glowColor: color,
      duration: const Duration(seconds: 2),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1)),
        child: Icon(Icons.mic_rounded, color: color, size: 40.sp),
      ),
    );
  }

  Widget _buildThinkingOrbit(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80.w,
          height: 80.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Icon(Icons.psychology_rounded, color: color, size: 32.sp),
      ],
    );
  }

  Widget _buildIdleGlow(Color color) {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.2), width: 2),
      ),
      child: Center(
        child: Icon(Icons.circle, color: color.withOpacity(0.5), size: 12.sp),
      ),
    );
  }

  Widget _buildQuestionSection(String text, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.primaryStart.withOpacity(0.5), size: 32.sp),
            SizedBox(height: 16.h),
            DefaultTextStyle(
              style: Get.theme.textTheme.titleLarge!.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                height: 1.4,
                letterSpacing: -0.5,
              ),
              child: AnimatedTextKit(
                key: ValueKey(text),
                animatedTexts: [
                  TypewriterAnimatedText(
                    text,
                    textAlign: TextAlign.center,
                    speed: const Duration(milliseconds: 30),
                  ),
                ],
                totalRepeatCount: 1,
                displayFullTextOnTap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingInputSection(InterviewController controller, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Container(
        decoration: BoxDecoration(
          color: Get.theme.cardTheme.color?.withOpacity(0.8),
          borderRadius: BorderRadius.circular(32.r),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20))
          ],
        ),
        child: Column(
          children: [
            // Voice Activity Bar
            _buildVoiceActivityBar(controller),
            
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
              child: TextField(
                controller: controller.answerController,
                maxLines: 5,
                minLines: 2,
                style: TextStyle(fontSize: 15.sp, height: 1.5),
                decoration: InputDecoration(
                  hintText: "Refine your thoughts or speak naturally...",
                  hintStyle: TextStyle(fontSize: 14.sp, fontStyle: FontStyle.italic, color: Colors.grey.withOpacity(0.5)),
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceActivityBar(InterviewController controller) {
    return Obx(() {
      final isListening = Get.find<VoiceService>().isListening.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isListening ? 40.h : 12.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isListening ? AppColors.accentEmerald.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: isListening 
          ? Center(
              child: Text(
                "CAPTURING VOICE DATA...",
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentEmerald,
                  letterSpacing: 2,
                ),
              ),
            )
          : Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
      );
    });
  }

  Widget _buildActionDock(InterviewController controller, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDockButton(
            onTap: controller.skipQuestion,
            icon: Icons.fast_forward_rounded,
            color: Colors.grey,
          ),
          
          _buildMainMicButton(controller),
          
          _buildDockButton(
            onTap: controller.submitAnswer,
            icon: Icons.send_rounded,
            color: AppColors.primaryStart,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMainMicButton(InterviewController controller) {
    return Obx(() {
      final isListening = controller.avatarState.value == AvatarState.listening;
      return GestureDetector(
        onTap: controller.toggleListening,
        onLongPressStart: (_) => controller.startListening(),
        onLongPressEnd: (_) => controller.stopListening(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isListening ? AppColors.accentEmerald : AppColors.primaryStart,
            boxShadow: [
              BoxShadow(
                color: (isListening ? AppColors.accentEmerald : AppColors.primaryStart).withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Icon(
            isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
            color: Colors.white,
            size: 32.sp,
          ),
        ),
      );
    });
  }

  Widget _buildDockButton({required VoidCallback onTap, required IconData icon, required Color color, bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60.w,
        height: 60.w,
        decoration: BoxDecoration(
          color: isPrimary ? color.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: isPrimary ? color : Colors.grey, size: 24.sp),
      ),
    );
  }
}

class _WaveBar extends StatefulWidget {
  final int index;
  final Color color;
  const _WaveBar({required this.index, required this.color});

  @override
  State<_WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<_WaveBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (widget.index * 150)),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 6.w,
          height: 30.h * _animation.value + 10.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}