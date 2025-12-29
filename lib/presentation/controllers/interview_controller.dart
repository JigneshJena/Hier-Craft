import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/interview_engine.dart';
import '../../core/services/offline_interview_engine.dart';
import '../../core/services/online_ai_interview_engine.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/voice_service.dart';
import '../../data/models/question_model.dart';
import '../../app/routes/app_routes.dart';

enum AvatarState { idle, speaking, listening, thinking }

class InterviewController extends GetxController {
  final ConnectivityService _connectivityService = Get.find<ConnectivityService>();
  final VoiceService _voiceService = Get.find<VoiceService>();

  final RxList<Question> questions = <Question>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxString currentTranscription = ''.obs;
  final RxBool isDifficultySelected = false.obs;
  final RxString selectedDifficulty = ''.obs;
  final Rx<AvatarState> avatarState = AvatarState.idle.obs;
  
  final RxList<Map<String, dynamic>> results = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt totalScore = 0.obs;
  final RxString selectedProvider = 'gemini'.obs; // Default to gemini
  final answerController = TextEditingController();

  final List<String> difficulties = ['Fresher', 'Intermediate', 'Experienced'];

  late String domain;

  @override
  void onInit() {
    super.onInit();
    domain = Get.arguments['domain'] ?? 'Flutter';
    isLoading.value = false; // Don't load questions until difficulty selected
  }

  // Get the appropriate engine based on connectivity
  InterviewEngine _getEngine() {
    if (_connectivityService.isOnline.value) {
      print('✅ Using Online AI Engine');
      return OnlineAIInterviewEngine();
    } else {
      print('📝 Using Offline Practice Engine (JSON)');
      return OfflineInterviewEngine();
    }
  }

  Future<void> selectDifficulty(String level) async {
    selectedDifficulty.value = level;
    isDifficultySelected.value = true;
    await _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    isLoading.value = true;
    try {
      // ONLY AI MODE - NO FALLBACK
      print('✅ Using ONLY AI Engine');
      final engine = OnlineAIInterviewEngine();
      
      // Update provider in config service temporarily for this session if needed
      // Or we can just pass it to the engine
      final fetchedQuestions = await engine.getQuestions(domain, selectedDifficulty.value);
      
      if (fetchedQuestions.isEmpty) {
        print('❌ AI ERROR - No questions generated');
        Get.snackbar(
          '❌ AI Service Error',
          'Could not generate questions. Check API key and internet.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 10),
        );
        isLoading.value = false;
        return;
      }
      
      questions.assignAll(fetchedQuestions);
      
      if (questions.isNotEmpty) {
        _askCurrentQuestion();
      } else {
        Get.snackbar("Error", "No questions available for $domain ($selectedDifficulty)");
      }
    } catch (e) {
      print('❌ Error loading questions: $e');
      Get.snackbar("Error", "Failed to load questions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _askCurrentQuestion() async {
    if (currentQuestionIndex.value < questions.length) {
      final question = questions[currentQuestionIndex.value];
      avatarState.value = AvatarState.speaking;
      await _voiceService.speak(question.text);
      avatarState.value = AvatarState.idle;
    }
  }

  void startListening() {
    if (_voiceService.isListening.value) {
      stopListening();
      return;
    }
    avatarState.value = AvatarState.listening;
    _voiceService.startListening((text) {
      currentTranscription.value = text;
      answerController.text = text;
    });
  }

  void stopListening() {
    _voiceService.stopListening();
    avatarState.value = AvatarState.idle;
  }

  Future<void> submitAnswer() async {
    final answerText = answerController.text.isNotEmpty 
        ? answerController.text 
        : currentTranscription.value;

    if (answerText.trim().isEmpty) {
      Get.snackbar("Notice", "Please type or say something before submitting.");
      return;
    }

    avatarState.value = AvatarState.thinking;
    final question = questions[currentQuestionIndex.value];
    
    // Get engine based on current connectivity for evaluation
    final engine = _getEngine();
    
    final evaluation = await engine.evaluateAnswer(
      question.id, 
      answerText, 
      question.keywords
    );

    totalScore.value += (evaluation['score'] as int);
    
    results.add({
      'question': question.text,
      'answer': answerText,
      'score': evaluation['score'],
      'feedback': evaluation['feedback'],
    });

    currentTranscription.value = '';
    answerController.clear();
    
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      _askCurrentQuestion();
    } else {
      _finishInterview();
    }
  }

  void skipQuestion() {
    results.add({
      'question': questions[currentQuestionIndex.value].text,
      'answer': 'Skipped',
      'score': 0,
      'feedback': 'Question was skipped.',
    });

    currentTranscription.value = '';
    answerController.clear();

    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      _askCurrentQuestion();
    } else {
      _finishInterview();
    }
  }

  void _finishInterview() {
    Get.offNamed(AppRoutes.results, arguments: {
      'totalScore': totalScore.value,
      'maxScore': questions.length * 10,
      'results': results,
      'domain': domain,
    });
  }

  @override
  void onClose() {
    _voiceService.stopSpeaking();
    _voiceService.stopListening();
    answerController.dispose();
    super.onClose();
  }
}
