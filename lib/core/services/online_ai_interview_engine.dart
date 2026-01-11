import '../../data/models/question_model.dart';
import 'interview_engine.dart';
import 'ai_api_service.dart';
import 'remote_config_service.dart';
import 'history_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../data/models/ai_provider_model.dart';
import '../../presentation/controllers/interview_controller.dart';

class OnlineAIInterviewEngine implements InterviewEngine {
  final AiApiService _aiService = Get.find<AiApiService>();
  final RemoteConfigService _configService = Get.find<RemoteConfigService>();
  final Logger _logger = Logger();

  @override
  Future<List<Question>> getQuestions(String domain, String difficulty, {
    int count = 5,
    String? explicitApiKey,
    String? explicitProvider,
    String? explicitModel,
  }) async {
    try {
      // If explicit config is provided, use it directly
      if (explicitApiKey != null && explicitProvider != null) {
         _logger.i('💡 Fetching AI questions for $domain ($difficulty) using EXPLICIT ${explicitProvider} model: ${explicitModel}');
         return await _aiService.generateQuestions(
            domain: domain,
            difficulty: difficulty,
            apiKey: explicitApiKey,
            provider: explicitProvider,
            model: explicitModel,
            count: count,
          );
      }

      final providers = _configService.getActiveProviders();
      
      if (providers.isEmpty) {
        _logger.w('⚠️ No active AI providers found in Remote Config');
        return [];
      }

      // Sort providers to put the preferred one (specific ID override or api_provider type) first
      final preferred = _configService.getProvider();
      providers.sort((a, b) {
        if (preferred != null) {
          if (a.id == preferred.id) return -1;
          if (b.id == preferred.id) return 1;
        }
        
        final preferredType = _configService.getApiProvider();
        final aType = a.provider.toLowerCase();
        final bType = b.provider.toLowerCase();
        if (aType == preferredType) return -1;
        if (bType == preferredType) return 1;
        return 0;
      });

      // Fetch history to avoid repeated questions
      final historyService = Get.find<HistoryService>();
      final excluded = historyService.getMasteredQuestions(domain);
      
      // Artificial delay to ensure user sees loading state
      await Future.delayed(const Duration(seconds: 2));

      // Try providers in order (preferred first)
      for (final providerConfig in providers) {
        try {
          _logger.i('💡 Fetching AI questions for $domain ($difficulty) using ${providerConfig.id} (${providerConfig.provider})');

          final questions = await _aiService.generateQuestions(
            domain: domain,
            difficulty: difficulty,
            apiKey: providerConfig.apiKey,
            provider: providerConfig.provider,
            model: providerConfig.model,
            count: count,
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
    String questionText,
    String answer,
    List<Keyword> keywords, {
    String? explicitApiKey,
    String? explicitProvider,
    String? explicitModel,
  }) async {
    try {
      // Use explicit config if available
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

      final providers = _configService.getActiveProviders();
      if (providers.isEmpty) return {"score": 0, "feedback": "No AI providers configured"};

      // Use the preferred provider for evaluation
      final providerConfig = _configService.getProvider();
      if (providerConfig == null) return {"score": 0, "feedback": "No active provider found"};

      _logger.i('Evaluating answer using ${providerConfig.id} (${providerConfig.provider})');

      return await _aiService.evaluateAnswer(
        question: questionText,
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
