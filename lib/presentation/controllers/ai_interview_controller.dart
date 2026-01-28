import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/ai_interview_service.dart';
import '../../core/services/voice_service.dart';
import '../../app/routes/app_routes.dart';
import '../../core/services/history_service.dart';
import 'package:uuid/uuid.dart';

enum AvatarState { idle, speaking, listening, thinking }

/// AI Interview Controller - Conversational interview powered by Dynamic AI
class AIInterviewController extends GetxController {
  final AIInterviewService _aiService = Get.find<AIInterviewService>();
  final VoiceService _voiceService = Get.find<VoiceService>();
  
  final RxString currentQuestion = ''.obs;
  final RxString lastEvaluation = ''.obs;
  final RxInt questionNumber = 0.obs;
  final RxInt totalQuestions = 12.obs;
  final RxBool isLoading = false.obs;
  final RxBool isInterviewStarted = false.obs;
  final Rx<AvatarState> avatarState = AvatarState.idle.obs;
  
  final TextEditingController answerController = TextEditingController();
  final RxString currentTranscription = ''.obs;
  
  late String domain;
  late String level;
  late String sessionId;
  
  final RxList<Map<String, dynamic>> conversation = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    domain = Get.arguments['domain'] ?? 'Flutter';
    level = Get.arguments['level'] ?? 'Fresher';
    sessionId = const Uuid().v4();
    
    // Initial save (Empty session)
    _saveSessionProgress(isComplete: false);

    // Screen load hote hi interview start karo
    Future.delayed(const Duration(milliseconds: 500), () {
      startInterview();
    });
  }

  void _saveSessionProgress({required bool isComplete, double? score, Map<String, dynamic>? results}) {
    Get.find<HistoryService>().saveSession(
      sessionId: sessionId,
      domain: domain,
      level: level,
      conversation: conversation.toList(),
      isComplete: isComplete,
      score: score,
      results: results,
    );
  }
  
  /// Interview start karo
  Future<void> startInterview() async {
    isLoading.value = true;
    avatarState.value = AvatarState.thinking;
    
    try {
      // AI Mode - AI se pehla question lo
      final firstQuestion = await _aiService.startInterview(domain, level);
      currentQuestion.value = firstQuestion;
      questionNumber.value = 1;
      totalQuestions.value = _aiService.totalQuestions;
      
      conversation.add({
        'type': 'question',
        'text': firstQuestion,
        'number': 1,
      });
      
      // Speak the question
      avatarState.value = AvatarState.speaking;
      await _voiceService.speak(firstQuestion);
      avatarState.value = AvatarState.idle;
      
      isInterviewStarted.value = true;
    } catch (e) {
      print('❌ Error starting interview: $e');
      Get.snackbar(
        'AI Service Error',
        'Failed to start AI interview. Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Answer submit karo aur next question lo
  Future<void> submitAnswer() async {
    final answer = answerController.text.isNotEmpty 
        ? answerController.text 
        : currentTranscription.value;
    
    if (answer.trim().isEmpty) {
      Get.snackbar('Notice', 'Please provide an answer');
      return;
    }
    
    // Add user's answer to conversation
    conversation.add({
      'type': 'answer',
      'text': answer,
      'number': questionNumber.value,
    });
    
    isLoading.value = true;
    avatarState.value = AvatarState.thinking;
    
    try {
      // AI Mode - Submit answer aur next question lo
      final result = await _aiService.submitAnswerAndGetNext(answer);
      
      if (result['isComplete'] == true) {
        // Interview complete!
        await _finishInterview();
      } else {
        // Store evaluation
        lastEvaluation.value = result['evaluation'] ?? '';
        
        if (lastEvaluation.value.isNotEmpty) {
          conversation.add({
            'type': 'evaluation',
            'text': lastEvaluation.value,
          });
        }
        
        // Next question
        currentQuestion.value = result['nextQuestion'];
        questionNumber.value = result['questionNumber'];
        
        conversation.add({
          'type': 'question',
          'text': currentQuestion.value,
          'number': questionNumber.value,
        });
        
        // Speak evaluation and next question
        avatarState.value = AvatarState.speaking;
        if (lastEvaluation.value.isNotEmpty) {
          await _voiceService.speak(lastEvaluation.value);
        }
        await _voiceService.speak(currentQuestion.value);
        avatarState.value = AvatarState.idle;
      }
      
      // Save progress after each turn
      _saveSessionProgress(isComplete: false);
      
      // Clear answer field
      answerController.clear();
      currentTranscription.value = '';
      
    } catch (e) {
      print('❌ Error submitting answer: $e');
      Get.snackbar(
        'Submission Error',
        'Failed to process answer. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Interview finish karo
  Future<void> _finishInterview() async {
    avatarState.value = AvatarState.thinking;
    
    try {
      final finalEval = await _aiService.getFinalEvaluation();
      
      // Save final complete state
      _saveSessionProgress(
        isComplete: true, 
        score: (finalEval['score'] as num?)?.toDouble(),
        results: finalEval,
      );

      Get.offNamed(AppRoutes.results, arguments: {
        'score': finalEval['score'],
        'strengths': finalEval['strengths'],
        'weaknesses': finalEval['weaknesses'],
        'suggestions': finalEval['suggestions'],
        'domain': domain,
        'level': level,
        'conversation': conversation,
      });
      
    } catch (e) {
      print('Error in final evaluation: $e');
      Get.snackbar('Finalization Error', 'Could not generate final report.');
      Get.back();
    }
  }
  
  /// Voice listening start/stop
  void toggleListening() {
    if (_voiceService.isListening.value) {
      _voiceService.stopListening();
      avatarState.value = AvatarState.idle;
    } else {
      avatarState.value = AvatarState.listening;
      _voiceService.startListening((text) {
        currentTranscription.value = text;
        answerController.text = text;
      });
    }
  }
  
  @override
  void onClose() {
    _voiceService.stopSpeaking();
    _voiceService.stopListening();
    answerController.dispose();
    super.onClose();
  }
}
