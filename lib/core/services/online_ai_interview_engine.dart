import '../../data/models/question_model.dart';
import 'interview_engine.dart';
import 'ai_api_service.dart';
import 'remote_config_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class OnlineAIInterviewEngine implements InterviewEngine {
  final AiApiService _aiService = Get.find<AiApiService>();
  final RemoteConfigService _configService = Get.find<RemoteConfigService>();
  final Logger _logger = Logger();

  @override
  Future<List<Question>> getQuestions(String domain, String difficulty) async {
    try {
      final provider = _configService.getApiProvider();
      final apiKey = _configService.getApiKey(difficulty);
      
      if (apiKey.isEmpty || apiKey.startsWith('AIzaSyDefault')) {
        _logger.w('⚠️ Valid API key not found in Remote Config for $provider');
        // If it's groq and key is empty, it might be that the user hasn't pasted it yet
        if (provider == 'groq') {
          throw Exception('Groq API key is missing. Please add "groq_api_key" to Remote Config.');
        }
        throw Exception('Invalid API key');
      }
      
      _logger.i('💡 Fetching AI questions for $domain ($difficulty) using $provider');
      _logger.i('🔑 Key (partial): ${apiKey.length > 10 ? apiKey.substring(0, 10) : apiKey}...');

      // Generate questions using AI
      final questions = await _aiService.generateQuestions(
        domain: domain,
        difficulty: difficulty,
        apiKey: apiKey,
        provider: provider,
        count: 5, // Generate 5 questions
      );

      if (questions.isEmpty) {
        _logger.w('No questions generated from AI');
      }

      return questions;
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
      // Get the question text from the keywords context
      final String questionText = questionId; // Using ID as question text temporarily

      final provider = _configService.getApiProvider();
      final apiKey = _configService.getApiKey('easy'); // Use default key for evaluation

      _logger.i('Evaluating answer using $provider AI');

      // Evaluate using AI
      final evaluation = await _aiService.evaluateAnswer(
        question: questionText,
        answer: answer,
        apiKey: apiKey,
        provider: provider,
        keywords: keywords,
      );

      return evaluation;
    } catch (e) {
      _logger.e('Error evaluating answer with AI: $e');
      return {
        "score": 0,
        "matchedKeywords": [],
        "feedback": "AI evaluation failed: ${e.toString()}",
      };
    }
  }
}
