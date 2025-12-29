import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../data/models/question_model.dart';
import 'remote_config_service.dart';

/// Service for calling AI APIs (Gemini, OpenAI, DeepSeek)
/// Provides methods for question generation, answer evaluation, and resume analysis
class AiApiService extends GetxService {
  final Logger _logger = Logger();

  /// Generate interview questions using AI
  Future<List<Question>> generateQuestions({
    required String domain,
    required String difficulty,
    required String apiKey,
    required String provider,
    int count = 5,
  }) async {
    try {
      _logger.i('Generating $count questions for $domain ($difficulty) using $provider');

      if (provider.toLowerCase() == 'gemini') {
        return await _generateQuestionsGemini(domain, difficulty, apiKey, count);
      } else if (provider.toLowerCase() == 'openai' || provider.toLowerCase() == 'groq') {
        return await _generateQuestionsGroq(domain, difficulty, apiKey, count);
      } else {
        _logger.w('Unsupported provider: $provider, falling back to empty list');
        return [];
      }
    } catch (e) {
      _logger.e('Error generating questions: $e');
      return [];
    }
  }

  /// Evaluate user's answer using AI
  Future<Map<String, dynamic>> evaluateAnswer({
    required String question,
    required String answer,
    required String apiKey,
    required String provider,
    List<Keyword>? keywords,
  }) async {
    try {
      _logger.i('Evaluating answer using $provider');

      if (provider.toLowerCase() == 'gemini') {
        return await _evaluateAnswerGemini(question, answer, apiKey, keywords);
      } else if (provider.toLowerCase() == 'openai' || provider.toLowerCase() == 'groq') {
        return await _evaluateAnswerGroq(question, answer, apiKey, keywords);
      } else {
        return {
          'score': 0,
          'matchedKeywords': [],
          'feedback': 'Unsupported AI provider',
        };
      }
    } catch (e) {
      _logger.e('Error evaluating answer: $e');
      return {
        'score': 0,
        'matchedKeywords': [],
        'feedback': 'Error evaluating answer: ${e.toString()}',
      };
    }
  }

  /// Analyze resume using AI
  Future<Map<String, dynamic>> analyzeResume({
    required String resumeText,
    required String apiKey,
    required String provider,
    String? base64Data,
    String? mimeType,
  }) async {
    try {
      _logger.i('Analyzing resume using $provider');

      String activeProvider = provider;
      String activeApiKey = apiKey;

      // Force Gemini for multimodal analysis (Images/PDFs) since Groq doesn't support it natively here
      if (base64Data != null && provider.toLowerCase() != 'gemini') {
        _logger.i('Switching to Gemini for multimodal resume analysis');
        activeProvider = 'gemini';
        // Need to get Gemini key specifically
        activeApiKey = Get.find<RemoteConfigService>().getApiKey('resume', provider: 'gemini');
      }

      if (activeProvider.toLowerCase() == 'gemini') {
        return await _analyzeResumeGemini(resumeText, activeApiKey, base64Data, mimeType);
      } else if (activeProvider.toLowerCase() == 'openai' || activeProvider.toLowerCase() == 'groq') {
        return await _analyzeResumeGroq(resumeText, activeApiKey);
      } else {
        return {
          'overall_score': 0,
          'strengths': [],
          'weaknesses': [],
          'suggestions': [],
          'error': 'Unsupported AI provider',
        };
      }
    } catch (e) {
      _logger.e('Error analyzing resume: $e');
      return {
        'overall_score': 0,
        'strengths': [],
        'weaknesses': [],
        'suggestions': [],
        'error': e.toString(),
      };
    }
  }

  // ==================== GEMINI API METHODS ====================

  Future<List<Question>> _generateQuestionsGemini(
    String domain,
    String difficulty,
    String apiKey,
    int count,
  ) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent',
    );

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final prompt = '''Generate $count UNIQUE and DIVERSE interview questions for $domain domain with $difficulty difficulty level.
Session ID: $timestamp (Ensure questions are different from previous sessions).

Return in JSON format as an array with each question having:
- id: unique identifier
- difficulty: "$difficulty"
- category: relevant category
- text: the question
- keywords: array of {word, points} for evaluation
- maxPoints: 10

Example format:
[{"id":"q1","difficulty":"$difficulty","category":"Core","text":"What is...?","keywords":[{"word":"example","points":5}],"maxPoints":10}]

Return ONLY the JSON array, no other text.''';

    try {
      final cleanKey = apiKey.trim();
      
      // Diagnostic: List available models
      _logger.i('🔍 Diagnostic: Checking available models for this key...');
      final modelsResponse = await http.get(
        Uri.parse('https://generativelanguage.googleapis.com/v1/models?key=$cleanKey'),
      );
      _logger.i('Diag Response: ${modelsResponse.body}');

      _logger.i('🤖 Calling Gemini API (Flash) with key: ${cleanKey.substring(0, 10)}...');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': cleanKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.9,
          }
        }),
      );

      if (response.statusCode == 200) {
        _logger.i('✅ Gemini response received successfully');
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extract JSON from markdown code blocks if present
        String jsonText = text;
        if (jsonText.contains('```json')) {
          jsonText = jsonText.split('```json')[1].split('```')[0].trim();
        } else if (jsonText.contains('```')) {
          jsonText = jsonText.split('```')[1].split('```')[0].trim();
        }

        final List<dynamic> questionsJson = jsonDecode(jsonText);
        return questionsJson.map((q) => Question.fromJson(q)).toList();
      } else {
        _logger.e('❌ Gemini API error: ${response.statusCode}');
        _logger.e('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      _logger.e('Error calling Gemini API: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> _evaluateAnswerGemini(
    String question,
    String answer,
    String apiKey,
    List<Keyword>? keywords,
  ) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent',
    );

    final prompt = '''Evaluate this interview answer:

Question: $question
Answer: $answer

Provide evaluation in JSON format:
{
  "score": <number 0-10>,
  "matchedKeywords": [<list of important concepts mentioned>],
  "feedback": "<detailed constructive feedback>"
}

Return ONLY the JSON object.''';

    try {
      final cleanKey = apiKey.trim();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': cleanKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        String jsonText = text;
        if (jsonText.contains('```json')) {
          jsonText = jsonText.split('```json')[1].split('```')[0].trim();
        } else if (jsonText.contains('```')) {
          jsonText = jsonText.split('```')[1].split('```')[0].trim();
        }

        return jsonDecode(jsonText);
      } else {
        _logger.e('Gemini API error: ${response.statusCode}');
        return {'score': 0, 'matchedKeywords': [], 'feedback': 'API Error'};
      }
    } catch (e) {
      _logger.e('Error calling Gemini API: $e');
      return {'score': 0, 'matchedKeywords': [], 'feedback': 'Evaluation failed'};
    }
  }

  Future<Map<String, dynamic>> _analyzeResumeGemini(
    String resumeText,
    String apiKey, [
    String? base64Data,
    String? mimeType,
  ]) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent',
    );

    final prompt = resumeText.isNotEmpty && base64Data == null
        ? '''Analyze this resume and provide feedback:
\n$resumeText'''
        : '''Analyze the attached resume and provide detailed feedback. 
Focus on structure, content, keywords, and overall impression.''';

    final systemInstruction = '''Provide analysis in JSON format:
{
  "overall_score": <number 0-100>,
  "strengths": [<list of strong points>],
  "weaknesses": [<list of areas to improve>],
  "suggestions": [<list of actionable improvements>],
  "formatting_issues": [<list of formatting problems if any>]
}

Return ONLY the JSON object.''';

    final List<Map<String, dynamic>> parts = [
      {'text': '$prompt\n\n$systemInstruction'}
    ];

    if (base64Data != null && mimeType != null) {
      parts.add({
        'inline_data': {
          'mime_type': mimeType,
          'data': base64Data,
        }
      });
    }

    try {
      final cleanKey = apiKey.trim();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': cleanKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': parts
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        String jsonText = text;
        
        // Robust JSON extraction
        if (jsonText.contains('```json')) {
          jsonText = jsonText.split('```json')[1].split('```')[0].trim();
        } else if (jsonText.contains('```')) {
          jsonText = jsonText.split('```')[1].split('```')[0].trim();
        } else if (!jsonText.trim().startsWith('{')) {
          // Find first { and last }
          final start = jsonText.indexOf('{');
          final end = jsonText.lastIndexOf('}');
          if (start != -1 && end != -1 && end > start) {
            jsonText = jsonText.substring(start, end + 1);
          }
        }

        return jsonDecode(jsonText);
      } else {
        _logger.e('Gemini API error: ${response.statusCode}');
        return {
          'overall_score': 0,
          'strengths': [],
          'weaknesses': [],
          'suggestions': ['API Error occurred'],
          'formatting_issues': [],
        };
      }
    } catch (e) {
      _logger.e('Error calling Gemini API: $e');
      return {
        'overall_score': 0,
        'strengths': [],
        'weaknesses': [],
        'suggestions': ['Analysis failed: ${e.toString()}'],
        'formatting_issues': [],
      };
    }
  }

  // ==================== GROQ (OpenAI Compatible) API METHODS ====================

  Future<List<Question>> _generateQuestionsGroq(
    String domain,
    String difficulty,
    String apiKey,
    int count,
  ) async {
    const String apiUrl = 'https://api.groq.com/openai/v1/chat/completions';

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final prompt = '''Generate $count UNIQUE and DIVERSE interview questions for $domain domain with $difficulty difficulty level. 
Session ID: $timestamp (Ensure questions are different from previous sessions).

Return in JSON format as an array with each question having:
- id: unique identifier
- difficulty: "$difficulty"
- category: relevant category
- text: the question
- keywords: array of {word, points} for evaluation
- maxPoints: 10

Example format:
[{"id":"q1","difficulty":"$difficulty","category":"Core","text":"What is...?","keywords":[{"word":"example","points":5}],"maxPoints":10}]

Return ONLY the JSON array, no other text.''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${apiKey.trim()}',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['choices'][0]['message']['content'];

        // Extract JSON from markdown code blocks if present
        if (text.contains('```json')) {
          text = text.split('```json')[1].split('```')[0].trim();
        } else if (text.contains('```')) {
          text = text.split('```')[1].split('```')[0].trim();
        }

        final List<dynamic> questionsJson = jsonDecode(text);
        return questionsJson.map((q) => Question.fromJson(q)).toList();
      } else {
        _logger.e('Groq API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      _logger.e('Error calling Groq API: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> _evaluateAnswerGroq(
    String question,
    String answer,
    String apiKey,
    List<Keyword>? keywords,
  ) async {
    const String apiUrl = 'https://api.groq.com/openai/v1/chat/completions';

    final prompt = '''Evaluate this interview answer:

Question: $question
Answer: $answer

Provide evaluation in JSON format:
{
  "score": <number 0-10>,
  "matchedKeywords": [<list of important concepts mentioned>],
  "feedback": "<detailed constructive feedback>"
}

Return ONLY the JSON object.''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${apiKey.trim()}',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['choices'][0]['message']['content'];

        if (text.contains('```json')) {
          text = text.split('```json')[1].split('```')[0].trim();
        } else if (text.contains('```')) {
          text = text.split('```')[1].split('```')[0].trim();
        }

        return jsonDecode(text);
      } else {
        _logger.e('Groq API error: ${response.statusCode}');
        return {'score': 0, 'matchedKeywords': [], 'feedback': 'API Error'};
      }
    } catch (e) {
      _logger.e('Error calling Groq API: $e');
      return {'score': 0, 'matchedKeywords': [], 'feedback': 'Evaluation failed'};
    }
  }

  Future<Map<String, dynamic>> _analyzeResumeGroq(
    String resumeText,
    String apiKey,
  ) async {
    const String apiUrl = 'https://api.groq.com/openai/v1/chat/completions';

    final prompt = '''Analyze this resume and provide feedback:

$resumeText

Provide analysis in JSON format:
{
  "overall_score": <number 0-100>,
  "strengths": [<list of strong points>],
  "weaknesses": [<list of areas to improve>],
  "suggestions": [<list of actionable improvements>],
  "formatting_issues": [<list of formatting problems if any>]
}

Return ONLY the JSON object.''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${apiKey.trim()}',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['choices'][0]['message']['content'];

        String jsonText = text;

        if (jsonText.contains('```json')) {
          jsonText = jsonText.split('```json')[1].split('```')[0].trim();
        } else if (jsonText.contains('```')) {
          jsonText = jsonText.split('```')[1].split('```')[0].trim();
        } else if (!jsonText.trim().startsWith('{')) {
          final start = jsonText.indexOf('{');
          final end = jsonText.lastIndexOf('}');
          if (start != -1 && end != -1 && end > start) {
            jsonText = jsonText.substring(start, end + 1);
          }
        }

        return jsonDecode(jsonText);
      } else {
        _logger.e('Groq API error: ${response.statusCode}');
        return {
          'overall_score': 0,
          'strengths': [],
          'weaknesses': [],
          'suggestions': ['API Error occurred'],
          'formatting_issues': [],
        };
      }
    } catch (e) {
      _logger.e('Error calling Groq API: $e');
      return {
        'overall_score': 0,
        'strengths': [],
        'weaknesses': [],
        'suggestions': ['Analysis failed: ${e.toString()}'],
        'formatting_issues': [],
      };
    }
  }

  // ==================== OPENAI API METHODS ====================

  Future<List<Question>> _generateQuestionsOpenAI(
    String domain,
    String difficulty,
    String apiKey,
    int count,
  ) async {
    // Similar implementation for OpenAI
    // Using GPT-3.5-turbo or GPT-4
    _logger.w('OpenAI integration not yet implemented, returning empty list');
    return [];
  }

  Future<Map<String, dynamic>> _evaluateAnswerOpenAI(
    String question,
    String answer,
    String apiKey,
    List<Keyword>? keywords,
  ) async {
    _logger.w('OpenAI integration not yet implemented');
    return {'score': 0, 'matchedKeywords': [], 'feedback': 'OpenAI not implemented yet'};
  }

  Future<Map<String, dynamic>> _analyzeResumeOpenAI(
    String resumeText,
    String apiKey,
  ) async {
    _logger.w('OpenAI integration not yet implemented');
    return {
      'overall_score': 0,
      'strengths': [],
      'weaknesses': [],
      'suggestions': ['OpenAI not implemented yet'],
      'formatting_issues': [],
    };
  }
}
