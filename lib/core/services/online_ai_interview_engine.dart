import '../../data/models/question_model.dart';
import 'interview_engine.dart';
import 'ai_api_service.dart';
import 'remote_config_service.dart';
import 'history_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../presentation/controllers/interview_controller.dart';

class OnlineAIInterviewEngine implements InterviewEngine {
  final AiApiService _aiService = Get.find<AiApiService>();
  final RemoteConfigService _configService = Get.find<RemoteConfigService>();
  final Logger _logger = Logger();

  @override
  Future<List<Question>> getQuestions(String domain, String difficulty) async {
    try {
      final providers = _configService.getActiveProviders();
      
      if (providers.isEmpty) {
        _logger.w('⚠️ No active AI providers found in Remote Config');
        return [];
      }

      // Fetch history to avoid repeated questions
      final historyService = Get.find<HistoryService>();
      final excluded = historyService.getMasteredQuestions(domain);
      
      // Artificial delay to ensure user sees loading state (as requested "wait atleast 10s")
      // We wait 2s here, and the API call takes more time anyway.
      await Future.delayed(const Duration(seconds: 2));

      // Try providers in order
      for (final providerConfig in providers) {
        try {
          _logger.i('💡 Fetching AI questions for $domain ($difficulty) using ${providerConfig.id}');

          final questions = await _aiService.generateQuestions(
            domain: domain,
            difficulty: difficulty,
            apiKey: providerConfig.apiKey,
            provider: providerConfig.provider,
            model: providerConfig.model,
            count: 5,
            excludedQuestions: excluded,
          );

          if (questions.isNotEmpty) {
            _logger.i('✅ Successfully generated questions with ${providerConfig.id}');
            return questions;
          }
        } catch (e) {
          _logger.e('Error with provider ${providerConfig.id}: $e');
          continue; 
        }
      }

      return [];
    } catch (e) {
      _logger.e('Error getting AI questions: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> evaluateAnswer(
    String questionId,
    String answer,
    List<Keyword> keywords,
  ) async {
    try {
      final providers = _configService.getActiveProviders();
      if (providers.isEmpty) return {"score": 0, "feedback": "No AI providers configured"};

      // Try first active provider for evaluation
      final providerConfig = providers.first;

      _logger.i('Evaluating answer using ${providerConfig.id}');

      return await _aiService.evaluateAnswer(
        question: questionId,
        answer: answer,
        apiKey: providerConfig.apiKey,
        provider: providerConfig.provider,
        model: providerConfig.model,
        keywords: keywords,
      );
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
