import '../../data/models/question_model.dart';
import 'interview_engine.dart';
import 'ai_api_service.dart';
import 'history_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'ai_config_service.dart';

class OnlineAIInterviewEngine implements InterviewEngine {
  final AiApiService _aiService = Get.find<AiApiService>();
  final AiConfigService _aiConfig = Get.find<AiConfigService>();
  final Logger _logger = Logger();

  @override
  Future<List<Question>> getQuestions(String domain, String difficulty, {
    int count = 5,
    String? explicitApiKey,
    String? explicitProvider,
    String? explicitModel,
  }) async {
    try {
      // 1. Explicit config from arguments (high priority)
      if (explicitApiKey != null && explicitProvider != null) {
         _logger.i('💡 Using EXPLICIT provider: $explicitProvider');
         return await _aiService.generateQuestions(
            domain: domain,
            difficulty: difficulty,
            apiKey: explicitApiKey,
            provider: explicitProvider,
            model: explicitModel,
            count: count,
          );
      }

      // 2. Firestore Provider (Admin defined)
      if (_aiConfig.apiKey.value.isNotEmpty && _aiConfig.provider.value != 'none') {
        _logger.i('🔥 Using FIRESTORE provider: ${_aiConfig.provider.value}');
        
        // Fetch history to avoid repeated questions
        final historyService = Get.find<HistoryService>();
        final excluded = historyService.getMasteredQuestions(domain);

        return await _aiService.generateQuestions(
          domain: domain,
          difficulty: difficulty,
          apiKey: _aiConfig.apiKey.value,
          provider: _aiConfig.provider.value,
          model: _aiConfig.model.value,
          count: count,
          excludedQuestions: excluded,
        );
      }

      // 3. Fallback/Error
      _logger.w('⚠️ No active AI provider found in Firestore');
      return [];
    } catch (e) {
      _logger.e('Error getting AI questions: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> evaluateAnswer(
    String questionText,
    String answer,
    List<Keyword> keywords, {
    String? explicitApiKey,
    String? explicitProvider,
    String? explicitModel,
  }) async {
    try {
      // 1. Explicit config from arguments
      if (explicitApiKey != null && explicitProvider != null) {
        _logger.i('Evaluating answer using EXPLICIT ${explicitProvider}');
        return await _aiService.evaluateAnswer(
          question: questionText,
          answer: answer,
          apiKey: explicitApiKey,
          provider: explicitProvider,
          model: explicitModel,
          keywords: keywords,
        );
      }

      // 2. Firestore Provider (Admin defined)
      if (_aiConfig.apiKey.value.isNotEmpty && _aiConfig.provider.value != 'none') {
        _logger.i('🔥 Evaluating with FIRESTORE: ${_aiConfig.provider.value}');
        return await _aiService.evaluateAnswer(
          question: questionText,
          answer: answer,
          apiKey: _aiConfig.apiKey.value,
          provider: _aiConfig.provider.value,
          model: _aiConfig.model.value,
          keywords: keywords,
        );
      }

      return {"score": 0, "feedback": "No AI configuration found in Firestore"};
    } catch (e) {
      _logger.e('Error evaluating answer: $e');
      return {
        "score": 0,
        "matchedKeywords": [],
        "feedback": "Evaluation failed: ${e.toString()}",
      };
    }
  }
}
