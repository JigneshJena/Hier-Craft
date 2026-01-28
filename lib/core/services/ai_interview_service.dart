 import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'ai_config_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// AI Interview Master Service
/// Ek ek karke questions puchta hai aur answers ko evaluate karta hai
class AIInterviewService extends GetxService {
  final Logger _logger = Logger();
  
  String? _conversationHistory;
  int _questionCount = 0;
  final int _totalQuestions = 12; // 10-15 questions
  
  /// Interview start karo with system instruction
  Future<String> startInterview(String domain, String level) async {
    _questionCount = 0;
    _conversationHistory = null;
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final systemInstruction = '''You are an expert HR Interviewer conducting a technical interview.
Session ID: $timestamp (Generate unique questions for this session).

Domain: $domain
Level: $level
Total Questions: $_totalQuestions

Instructions:
1. Ask technical questions one by one based on $domain and $level difficulty
2. Start with question 1
3. Keep questions relevant to $domain
4. Match difficulty to $level (Fresher=Basic, Intermediate=Moderate, Experienced=Advanced)
5. After receiving an answer, evaluate it briefly and ask a UNIQUE next question
6. Number each question (e.g., "Question 1:", "Question 2:")
7. DO NOT repeat common or previous questions.

Now ask your FIRST question (Question 1):''';

    try {
      final response = await _callAIAPI(systemInstruction);
      _questionCount = 1;
      _conversationHistory = systemInstruction + "\n\nAI: " + response;
      return response;
    } catch (e) {
      _logger.e('Error starting interview: $e');
      rethrow;
    }
  }
  
  /// User ka answer submit karo aur next question lo
  Future<Map<String, dynamic>> submitAnswerAndGetNext(String userAnswer) async {
    if (_questionCount >= _totalQuestions) {
      return {
        'isComplete': true,
        'message': 'Interview complete! Thank you for participating.',
        'totalQuestions': _questionCount,
      };
    }
    
    _questionCount++;
    
    final prompt = '''User's Answer: $userAnswer

Now:
1. Briefly evaluate this answer (1-2 lines)
2. Ask Question $_questionCount (A UNIQUE technical question different from previous ones)

Format:
Evaluation: [Your evaluation]
Question $_questionCount: [Your next question]''';
    
    try {
      final response = await _callAIAPI(prompt);
      _conversationHistory = (_conversationHistory ?? '') + "\n\nUser: $userAnswer\n\nAI: $response";
      
      // Parse evaluation aur question
      final parts = response.split('Question $_questionCount:');
      String evaluation = parts.length > 0 ? parts[0].replaceAll('Evaluation:', '').trim() : '';
      String nextQuestion = parts.length > 1 ? parts[1].trim() : response;
      
      return {
        'isComplete': false,
        'evaluation': evaluation,
        'nextQuestion': nextQuestion,
        'questionNumber': _questionCount,
        'totalQuestions': _totalQuestions,
      };
    } catch (e) {
      _logger.e('Error getting next question: $e');
      rethrow;
    }
  }
  
  /// AI API call karo (Global Config)
  Future<String> _callAIAPI(String prompt) async {
    final aiConfig = Get.find<AiConfigService>();
    final provider = aiConfig.provider.value;
    final apiKey = aiConfig.apiKey.value;
    
    if (apiKey.isEmpty) {
      _logger.w('⚠️ Global AI API key not found in Firestore');
      throw Exception('API key not configured');
    }

    if (provider == 'gemini') {
      return await _callGeminiAPI(prompt, apiKey, aiConfig.model.value);
    } else if (provider == 'groq') {
      return await _callGroqAPI(prompt, apiKey, aiConfig.model.value);
    } else {
      throw Exception('Unsupported provider: $provider');
    }
  }

  Future<String> _callGeminiAPI(String prompt, String apiKey, String model) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/$model:generateContent',
    );
    // ... rest follows
    
    final cleanKey = apiKey.trim();
    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': (_conversationHistory ?? '') + '\n\n' + prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 500,
      }
    };
    
    _logger.i('🤖 Calling Gemini API (Flash) with key: ${cleanKey.substring(0, 10)}...');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': cleanKey,
      },
      body: jsonEncode(requestBody),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'].trim();
    } else {
      _logger.e('❌ Gemini API error: ${response.statusCode}');
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  Future<String> _callGroqAPI(String prompt, String apiKey, String model) async {
    const String apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
    
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${apiKey.trim()}',
      },
      body: jsonEncode({
        'model': model.isNotEmpty ? model : 'llama-3.3-70b-versatile',
        'messages': [
          {'role': 'user', 'content': (_conversationHistory ?? '') + '\n\n' + prompt}
        ],
        'temperature': 0.9,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      _logger.e('❌ Groq API error: ${response.statusCode}');
      throw Exception('API Error: ${response.statusCode}');
    }
  }
  
  /// Final evaluation lo
  Future<Map<String, dynamic>> getFinalEvaluation() async {
    final prompt = '''Based on all ${_totalQuestions} questions and answers in this interview, provide:
1. Overall Score: X/100
2. Strengths: 2-3 points
3. Weaknesses: 2-3 points
4. Suggestions: 2-3 actionable tips

Format as JSON:
{
  "score": 85,
  "strengths": ["point1", "point2"],
  "weaknesses": ["point1", "point2"],
  "suggestions": ["tip1", "tip2"]
}''';
    
    try {
      final response = await _callAIAPI(prompt);
      
      // Extract JSON from response
      String jsonText = response;
      if (jsonText.contains('```json')) {
        jsonText = jsonText.split('```json')[1].split('```')[0].trim();
      } else if (jsonText.contains('```')) {
        jsonText = jsonText.split('```')[1].split('```')[0].trim();
      } else if (jsonText.contains('{')) {
        jsonText = jsonText.substring(jsonText.indexOf('{'));
        jsonText = jsonText.substring(0, jsonText.lastIndexOf('}') + 1);
      }
      
      return jsonDecode(jsonText);
    } catch (e) {
      _logger.e('Error getting final evaluation: $e');
      // Return default evaluation
      return {
        'score': 70,
        'strengths': ['Completed the interview', 'Attempted all questions'],
        'weaknesses': ['Could provide more detailed answers'],
        'suggestions': ['Practice more technical questions', 'Study core concepts']
      };
    }
  }
  
  int get currentQuestionNumber => _questionCount;
  int get totalQuestions => _totalQuestions;
  bool get isInterviewComplete => _questionCount >= _totalQuestions;
}
