import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/ai_interview_service.dart';
import '../../core/services/offline_interview_engine.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/voice_service.dart';
import '../../app/routes/app_routes.dart';

enum InterviewMode { aiMode, offlineMode }
enum AvatarState { idle, speaking, listening, thinking }

/// AI Interview Controller - Conversational interview chalata hai
class AIInterviewController extends GetxController {
  final AIInterviewService _aiService = Get.find<AIInterviewService>();
  final ConnectivityService _connectivityService = Get.find<ConnectivityService>();
  final VoiceService _voiceService = Get.find<VoiceService>();
  final OfflineInterviewEngine _offlineEngine = OfflineInterviewEngine();
  
  final RxString currentQuestion = ''.obs;
  final RxString lastEvaluation = ''.obs;
  final RxInt questionNumber = 0.obs;
  final RxInt totalQuestions = 12.obs;
  final RxBool isLoading = false.obs;
  final RxBool isInterviewStarted = false.obs;
  final Rx<InterviewMode> mode = InterviewMode.aiMode.obs;
  final Rx<AvatarState> avatarState = AvatarState.idle.obs;
  
  final TextEditingController answerController = TextEditingController();
  final RxString currentTranscription = ''.obs;
  
  late String domain;
  late String level;
  
  final RxList<Map<String, dynamic>> conversation = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    domain = Get.arguments['domain'] ?? 'Flutter';
    level = Get.arguments['level'] ?? 'Fresher';
    
    // Check mode - online ya offline
    if (_connectivityService.isOnline.value) {
      mode.value = InterviewMode.aiMode;
    } else {
      mode.value = InterviewMode.offlineMode;
    }
    
    // Screen load hote hi interview start karo
    Future.delayed(Duration(milliseconds: 500), () {
      startInterview();
    });
  }
  
  /// Interview start karo
  Future<void> startInterview() async {
    isLoading.value = true;
    avatarState.value = AvatarState.thinking;
    
    try {
      if (mode.value == InterviewMode.aiMode) {
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
        
      } else {
        // Offline Mode - JSON se questions lo
        final questions = await _offlineEngine.getQuestions(domain, level);
        if (questions.isNotEmpty) {
          currentQuestion.value = questions[0].text;
          questionNumber.value = 1;
          totalQuestions.value = questions.length;
          
          conversation.add({
            'type': 'question',
            'text': questions[0].text,
            'number': 1,
            'keywords': questions[0].keywords,
          });
          
          avatarState.value = AvatarState.speaking;
          await _voiceService.speak(questions[0].text);
          avatarState.value = AvatarState.idle;
        }
      }
      
      isInterviewStarted.value = true;
    } catch (e) {
      print('❌ Error starting interview: $e');
      
      // Fallback to offline mode
      Get.snackbar(
        'Switching to Offline Mode',
        'AI unavailable. Using practice questions.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      
      mode.value = InterviewMode.offlineMode;
      await startInterview(); // Retry in offline mode
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
      if (mode.value == InterviewMode.aiMode) {
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
        
      } else {
        // Offline mode - Simple keyword matching
        // Implementation same as before
        questionNumber.value++;
        if (questionNumber.value <= totalQuestions.value) {
          final questions = await _offlineEngine.getQuestions(domain, level);
          if (questionNumber.value <= questions.length) {
            currentQuestion.value = questions[questionNumber.value - 1].text;
            
            conversation.add({
              'type': 'question',
              'text': currentQuestion.value,
              'number': questionNumber.value,
            });
            
            avatarState.value = AvatarState.speaking;
            await _voiceService.speak(currentQuestion.value);
            avatarState.value = AvatarState.idle;
          }
        } else {
          await _finishInterview();
        }
      }
      
      // Clear answer field
      answerController.clear();
      currentTranscription.value = '';
      
    } catch (e) {
      print('❌ Error submitting answer: $e');
      
      // Fallback to offline
      if (mode.value == InterviewMode.aiMode) {
        Get.snackbar(
          'Switching to Offline',
          'API limit reached. Using offline questions.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        mode.value = InterviewMode.offlineMode;
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Interview finish karo
  Future<void> _finishInterview() async {
    avatarState.value = AvatarState.thinking;
    
    try {
      Map<String, dynamic> finalEval;
      
      if (mode.value == InterviewMode.aiMode) {
        finalEval = await _aiService.getFinalEvaluation();
      } else {
        // Offline basic evaluation
        finalEval = {
          'score': 75,
          'strengths': ['Completed all questions', 'Good effort'],
          'weaknesses': ['Practice more'],
          'suggestions': ['Review key concepts']
        };
      }
      
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
