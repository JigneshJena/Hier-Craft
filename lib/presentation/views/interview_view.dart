import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../controllers/interview_controller.dart';
import '../../core/services/voice_service.dart';
import '../../core/services/connectivity_service.dart';

class InterviewView extends StatelessWidget {
  const InterviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterviewController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() => Column(
              children: [
                Text(
                  "Question ${controller.currentQuestionIndex.value + 1}/${controller.questions.length}",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16.sp),
                ),
                Obx(() => controller.isDifficultySelected.value 
                  ? Text(
                      "Level: ${controller.selectedDifficulty.value}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Get.theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const SizedBox.shrink()),
              ],
            )),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (!controller.isDifficultySelected.value) {
          return _buildDifficultySelection(controller);
        }
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.questions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("No questions found for this domain."),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text("Go Back"),
                ),
              ],
            ),
          );
        }

        final currentQuestion = controller.questions[controller.currentQuestionIndex.value];

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildProgressIndicator(controller),
              _buildHRSection(controller),
              _buildQuestionSection(currentQuestion.text),
              SizedBox(height: 20.h),
              _buildInputSection(controller),
              _buildControlsSection(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDifficultySelection(InterviewController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Choose Interview Level",
              style: Get.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Text(
              "Select a difficulty to begin your mock interview",
              style: Get.theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),
            ...controller.difficulties.map((diff) => _buildLevelCard(controller, diff)),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(InterviewController controller, String level) {
    IconData icon;
    Color color;
    String desc;

    switch (level) {
      case 'Fresher':
        icon = Icons.star_outline;
        color = Colors.green;
        desc = "Perfect for beginners & recent graduates";
        break;
      case 'Intermediate':
        icon = Icons.star_half;
        color = Colors.orange;
        desc = "For professionals with 2-4 years of experience";
        break;
      case 'Experienced':
        icon = Icons.star;
        color = Colors.red;
        desc = "Advanced concepts for senior roles";
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
        desc = "";
    }

    return GestureDetector(
      onTap: () => controller.selectDifficulty(level),
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30.sp),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: Get.theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    desc,
                    style: Get.theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(InterviewController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: LinearProgressIndicator(
          value: (controller.currentQuestionIndex.value + 1) / controller.questions.length,
          minHeight: 8.h,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(Get.theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildHRSection(InterviewController controller) {
    return Container(
      height: 220.h,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 20.h),
      child: Center(
        child: Obx(() {
          Color color;
          String label;
          Widget avatar;

          switch (controller.avatarState.value) {
            case AvatarState.speaking:
              color = Colors.blue;
              label = "HR is Speaking...";
              avatar = _buildTalkingAvatar(color);
              break;
            case AvatarState.listening:
              color = Colors.green;
              label = "HR is Listening...";
              avatar = _buildListeningAvatar(color);
              break;
            case AvatarState.thinking:
              color = Colors.orange;
              label = "HR is Thinking...";
              avatar = _buildThinkingAvatar(color);
              break;
            default:
              color = Colors.grey;
              final connectivityService = Get.find<ConnectivityService>();
              label = connectivityService.isOnline.value ? "AI HR is ready" : "HR is ready (Offline)";
              avatar = _buildIdleAvatar(color);
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 140.h,
                child: avatar,
              ),
              SizedBox(height: 15.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  label,
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTalkingAvatar(Color color) {
    return AvatarGlow(
      animate: true,
      glowColor: color,
      duration: const Duration(milliseconds: 1000),
      repeat: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(Icons.record_voice_over, size: 50.sp, color: color),
          ),
          // Simple Voice Wave Animation
          ...List.generate(3, (index) {
            return _VoiceWave(index: index, color: color);
          }),
        ],
      ),
    );
  }

  Widget _buildListeningAvatar(Color color) {
    return AvatarGlow(
      animate: true,
      glowColor: color,
      duration: const Duration(milliseconds: 1500),
      repeat: true,
      child: Container(
        width: 100.w,
        height: 100.h,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(Icons.hearing, size: 50.sp, color: color),
      ),
    );
  }

  Widget _buildThinkingAvatar(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100.w,
          height: 100.h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(Icons.psychology, size: 50.sp, color: color),
        ),
        const CircularProgressIndicator(strokeWidth: 2),
      ],
    );
  }

  Widget _buildIdleAvatar(Color color) {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Icon(Icons.face, size: 50.sp, color: color),
    );
  }

  Widget _buildQuestionSection(String questionText) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Column(
        children: [
          Icon(Icons.format_quote_rounded, color: Get.theme.colorScheme.primary.withOpacity(0.3), size: 30.sp),
          SizedBox(
            height: 100.h,
            child: DefaultTextStyle(
              style: Get.theme.textTheme.titleLarge!.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              child: AnimatedTextKit(
                key: ValueKey(questionText),
                animatedTexts: [
                  TypewriterAnimatedText(
                    questionText,
                    textAlign: TextAlign.center,
                    speed: const Duration(milliseconds: 50),
                  ),
                ],
                totalRepeatCount: 1,
                displayFullTextOnTap: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(InterviewController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Get.theme.colorScheme.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Answer:",
                style: Get.theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Obx(() => Get.find<VoiceService>().isListening.value
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Obx(() {
                                final level = Get.find<VoiceService>().soundLevel.value;
                                final height = 3 + (level.abs() * (index + 1) * 2).clamp(2, 12).toDouble();
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  width: 2,
                                  height: height,
                                  color: Colors.green,
                                );
                              });
                            }),
                            const SizedBox(width: 8),
                            const Text("Listening...", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink()),
            ],
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: controller.answerController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Type your answer here or long-press the mic button below to speak...",
              hintStyle: TextStyle(fontSize: 14.sp, fontStyle: FontStyle.italic),
              fillColor: Get.theme.colorScheme.background.withOpacity(0.5),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(15.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsSection(InterviewController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.h, left: 20.w, right: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(
            onTap: controller.skipQuestion,
            icon: Icons.skip_next_rounded,
            label: "Skip",
          ),
          Obx(() => AvatarGlow(
                animate: controller.avatarState.value == AvatarState.listening,
                glowColor: Get.theme.colorScheme.primary,
                duration: const Duration(milliseconds: 1500),
                repeat: true,
                child: GestureDetector(
                  onTap: () => controller.startListening(),
                  onLongPressStart: (_) => controller.startListening(),
                  onLongPressEnd: (_) => controller.stopListening(),
                  child: Container(
                    height: 70.h,
                    width: 70.w,
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Get.theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      controller.avatarState.value == AvatarState.listening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 35.sp,
                    ),
                  ),
                ),
              )),
          _buildCircleButton(
            onTap: controller.submitAnswer,
            icon: Icons.check_rounded,
            label: "Submit",
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30.r),
          child: Container(
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: isPrimary 
                  ? Get.theme.colorScheme.primary.withOpacity(0.1) 
                  : Get.theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isPrimary 
                    ? Get.theme.colorScheme.primary.withOpacity(0.3) 
                    : Get.theme.colorScheme.primary.withOpacity(0.1),
              ),
            ),
            child: Icon(
              icon,
              color: Get.theme.colorScheme.primary,
              size: 25.sp,
            ),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          style: Get.theme.textTheme.bodySmall?.copyWith(fontSize: 12.sp),
        ),
      ],
    );
  }
}

class _VoiceWave extends StatefulWidget {
  final int index;
  final Color color;
  const _VoiceWave({required this.index, required this.color});

  @override
  State<_VoiceWave> createState() => _VoiceWaveState();
}

class _VoiceWaveState extends State<_VoiceWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800 + (widget.index * 200)),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 120.w + (widget.index * 20.w) * _controller.value,
          height: 120.h + (widget.index * 20.h) * _controller.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withOpacity(0.3 - (widget.index * 0.1)),
              width: 1,
            ),
          ),
        );
      },
    );
  }
}