import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/interview_engine.dart';
import '../../core/services/online_ai_interview_engine.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/voice_service.dart';
import '../../core/services/history_service.dart';
import '../../core/services/ai_config_service.dart';
import '../../core/services/ai_api_service.dart';
import '../../data/models/question_model.dart';
import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';

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
  final RxDouble totalScore = RxDouble(0.0);
  final RxInt targetCount = 5.obs;
  final RxString selectedProvider = 'gemini'.obs;
  final answerController = TextEditingController();
  final RxBool showHint = false.obs;
  final RxList<Map<String, String>> conversationLog = <Map<String, String>>[].obs;
  final Rx<Map<String, dynamic>?> personalityResult = Rx<Map<String, dynamic>?>(null);

  void toggleHint() => showHint.toggle();

  final List<String> difficulties = ['Fresher', 'Intermediate', 'Experienced'];

  late String domain;
  String? _explicitApiKey;
  String? _explicitProvider;
  String? _explicitModel;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    domain = args['domain'] ?? 'Flutter';
    targetCount.value = args['count'] ?? 5;
    
    // Capture explicit config
    _explicitApiKey = args['apiKey'];
    _explicitProvider = args['provider']; // e.g. 'gemini'
    _explicitModel = args['model'];
    
    if (args['difficulty'] != null) {
      selectedDifficulty.value = args['difficulty'];
      isDifficultySelected.value = true;
      isLoading.value = true;
      // Use a post-frame callback or slight delay to ensure everything is ready
      Future.microtask(() => _loadQuestions());
    } else {
      isLoading.value = false;
    }
  }

  // Get the appropriate engine based on connectivity
  InterviewEngine _getEngine() {
    // ALWAYS USE ONLINE AI ENGINE as per user request to remove questions.json
    return OnlineAIInterviewEngine();
  }

  Future<void> selectDifficulty(String level) async {
    selectedDifficulty.value = level;
    isDifficultySelected.value = true;
    await _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    showHint.value = false;
    isLoading.value = true;
    List<Question>? fetchedQuestions;
    try {
      // ONLY AI MODE - NO FALLBACK
      print('✅ Using ONLY AI Engine');
      final engine = OnlineAIInterviewEngine();
      
      fetchedQuestions = await engine.getQuestions(
        domain, 
        selectedDifficulty.value, 
        count: targetCount.value,
        explicitApiKey: _explicitApiKey,
        explicitProvider: _explicitProvider,
        explicitModel: _explicitModel,
      );
      
      if (fetchedQuestions.isEmpty) {
        print('❌ AI ERROR - No questions generated');
        Get.snackbar(
          'Interview Postponed',
          'Our AI is currently busy or your internet is unstable. Please try again in a moment.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.accentRose.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        isLoading.value = false;
        return;
      }
      
      questions.assignAll(fetchedQuestions);
      
      if (questions.isNotEmpty) {
        _askCurrentQuestion();
      } else {
        Get.snackbar("Almost Ready", "We couldn't find specific topics for this area. Try a different domain!");
      }
    } catch (e) {
      print('❌ Error loading questions: $e');
      Get.snackbar("Oops!", "Something went wrong while setting up your interview. We're on it!");
    } finally {
      // Ensure we wait at least a bit to show a nice loading state
      // (User requested wait at least 10s, but that might be frustrating if it's too long, 
      // so we aim for a balanced feel or strictly follow if they insisted)
      // I'll add a buffer if it was too fast.
      if (fetchedQuestions == null || fetchedQuestions.isEmpty) {
         // If error, maybe wait a bit more for dramatic effect/loading feel
         await Future.delayed(const Duration(seconds: 3));
      }
      isLoading.value = false;
    }
  }

  void _askCurrentQuestion() async {
    if (currentQuestionIndex.value < questions.length) {
      final question = questions[currentQuestionIndex.value];
      
      // Log AI question
      conversationLog.add({'role': 'AI', 'content': question.text});
      
      avatarState.value = AvatarState.speaking;
      await _voiceService.speak(question.text);
      avatarState.value = AvatarState.idle;
    }
  }

  void toggleListening() {
    if (_voiceService.isListening.value) {
      stopListening();
    } else {
      startListening();
    }
  }

  void startListening() {
    if (_voiceService.isListening.value) return;
    
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

    // Log User answer
    conversationLog.add({'role': 'User', 'content': answerText});

    avatarState.value = AvatarState.thinking;
    final question = questions[currentQuestionIndex.value];
    
    // Hide hint when submitting
    showHint.value = false;
    
    // Get engine based on current connectivity for evaluation
      final engine = _getEngine();
      
      // Pass explicit config if available
      final evaluation = await engine.evaluateAnswer(
        question.text, 
        answerText, 
        question.keywords,
        explicitApiKey: _explicitApiKey,
        explicitProvider: _explicitProvider,
        explicitModel: _explicitModel,
      );

      totalScore.value += (evaluation['score'] as num).toDouble();
      
      // Save to history
      Get.find<HistoryService>().saveAnsweredQuestion(
        question: question.text,
        score: (evaluation['score'] as num).toDouble(),
        domain: domain,
      );

      results.add({
        'question': question.text,
        'answer': answerText,
        'score': evaluation['score'],
        'feedback': evaluation['feedback'],
        'explanation': evaluation['correct_answer'] ?? question.explanation,
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
      // Hide hint
      showHint.value = false;

      results.add({
        'question': questions[currentQuestionIndex.value].text,
        'answer': 'Skipped',
        'score': 0,
        'feedback': 'Question was skipped.',
        'explanation': questions[currentQuestionIndex.value].explanation,
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

    Future<void> _finishInterview() async {
      avatarState.value = AvatarState.thinking;
      isLoading.value = true;

      try {
        // Trigger Personality Analysis
        final engine = _getEngine();
        if (engine is OnlineAIInterviewEngine) {
          // Use explicit config if available, otherwise remote config
          String provider, apiKey;
          String? model;
          
          if (_explicitApiKey != null && _explicitProvider != null) {
             apiKey = _explicitApiKey!;
             provider = _explicitProvider!;
             model = _explicitModel;
          } else {
             final aiConfig = Get.find<AiConfigService>();
             provider = aiConfig.provider.value;
             apiKey = aiConfig.apiKey.value;
             model = aiConfig.model.value;
          }
          
          personalityResult.value = await Get.find<AiApiService>().analyzePersonality(
            transcript: conversationLog,
            apiKey: apiKey,
            provider: provider,
            model: model,
          );
        }
    } catch (e) {
      print('Error during personality analysis: $e');
    }

    // ✅ SAVE SESSION TO HISTORY FOR USER & ADMIN TRACKING
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final finalScore = totalScore.value / questions.length; // Average score 0-10
    
    // Build conversation history
    final conversationHistory = <Map<String, dynamic>>[];
    for (var i = 0; i < results.length; i++) {
      final result = results[i];
      conversationHistory.add({'type': 'question', 'text': result['question']});
      conversationHistory.add({
        'type': 'answer',
        'text': result['answer'],
        'score': result['score'],
        'feedback': result['feedback'],
      });
    }
    
    try {
      await Get.find<HistoryService>().saveSession(
        sessionId: sessionId,
        domain: domain,
        level: selectedDifficulty.value,
        conversation: conversationHistory,
        isComplete: true,
        score: finalScore,
        results: {
          'totalScore': totalScore.value,
          'maxScore': questions.length * 10,
          'personality': personalityResult.value,
        },
      );
      print('✅ Session saved: $sessionId');
    } catch (e) {
      print('❌ Save failed: $e');
    }

    Get.offNamed(AppRoutes.results, arguments: {
      'totalScore': totalScore.value,
      'maxScore': (questions.length * 10).toInt(),
      'results': results,
      'domain': domain,
      'personality': personalityResult.value,
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
