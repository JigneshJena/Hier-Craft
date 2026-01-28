import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../data/models/question_model.dart';


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
    String? model,
    int count = 5,
    List<String>? excludedQuestions,
  }) async {
    try {
      final keyDisplay = apiKey.length > 8 ? "...${apiKey.substring(apiKey.length - 8)}" : "INVALID";
      _logger.i('🚀 Generating $count questions using $provider (Key: $keyDisplay)');

      if (provider.toLowerCase() == 'gemini') {
        return await _generateQuestionsGemini(
          domain: domain,
          difficulty: difficulty,
          apiKey: apiKey,
          count: count,
          model: model,
          excludedQuestions: excludedQuestions,
        );
      } else {
        // Handle OpenAI-compatible providers (Groq, OpenAI, HuggingFace, etc.)
        return await _generateQuestionsGeneric(
          domain: domain,
          difficulty: difficulty,
          apiKey: apiKey,
          count: count,
          model: model,
          excludedQuestions: excludedQuestions,
          provider: provider,
        );
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
    String? model,
    List<Keyword>? keywords,
  }) async {
    try {
      _logger.i('Evaluating answer using $provider');

      if (provider.toLowerCase() == 'gemini') {
        return await _evaluateAnswerGemini(
          question: question,
          answer: answer,
          apiKey: apiKey,
          keywords: keywords,
          model: model,
        );
      } else {
        // Handle OpenAI-compatible providers
        return await _evaluateAnswerGeneric(
          question: question,
          answer: answer,
          apiKey: apiKey,
          keywords: keywords,
          model: model,
          provider: provider,
        );
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
    String? model,
    String? base64Data,
    String? mimeType,
  }) async {
    try {
      _logger.i('Analyzing resume using $provider');

      if (provider.toLowerCase() == 'gemini') {
        return await _analyzeResumeGemini(
          resumeText: resumeText,
          apiKey: apiKey,
          base64Data: base64Data,
          mimeType: mimeType,
          model: model,
        );
      } else {
        // Handle OpenAI-compatible providers
        return await _analyzeResumeGeneric(
          resumeText: resumeText,
          apiKey: apiKey,
          model: model,
          provider: provider,
        );
      }
    } catch (e) {
      return {
        'overall_score': 0,
        'strengths': [],
        'weaknesses': [],
        'suggestions': [],
        'error': e.toString(),
      };
    }
  }

  /// Analyze personality based on interview transcript
  Future<Map<String, dynamic>> analyzePersonality({
    required List<Map<String, String>> transcript,
    required String apiKey,
    required String provider,
    String? model,
  }) async {
    try {
      if (provider.toLowerCase() == 'gemini') {
        return await _analyzePersonalityGemini(
          transcript: transcript,
          apiKey: apiKey,
          model: model,
        );
      } else {
        // Use generic analyze for other providers
        return await _analyzePersonalityGeneric(
          transcript: transcript,
          apiKey: apiKey,
          provider: provider,
          model: model,
        );
      }
    } catch (e) {
      _logger.e('Error in public analyzePersonality: $e');
      return {
        "traitName": "Analysis Interrupted",
        "description": "The profile generation was interrupted by a technical error.",
        "scores": {"analytical": 0, "creative": 0, "strategic": 0, "collaborative": 0, "detail": 0},
        "strengths": [],
        "advice": "Try completing another interview for a full profile."
      };
    }
  }

  // ==================== GEMINI API METHODS ====================

  Future<List<Question>> _generateQuestionsGemini({
    required String domain,
    required String difficulty,
    required String apiKey,
    required int count,
    String? model,
    List<String>? excludedQuestions,
  }) async {
    final modelName = model ?? 'gemini-1.5-flash';
    final cleanKey = apiKey.trim();
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/$modelName:generateContent?key=$cleanKey',
    );

    final timestamp = DateTime.now().millisecondsSinceEpoch;
final prompt = '''Generate $count HIGHLY SPECIFIC and DIVERSE interview questions for the $domain domain at a $difficulty level. 
Session ID: $timestamp

Return correctly formatted JSON in an array of EXACTLY $count objects.

REQUIRED JSON FORMAT:
[
  {
    "id": "q1",
    "question_text": "the actual question here",
    "ideal_answer": "a comprehensive correct answer for reference",
    "keywords": [{"word": "key1", "points": 5}, {"word": "key2", "points": 5}],
    "hints": ["progressive hint 1", "progressive hint 2"],
    "explanation": "concise explanation of why this matters",
    "estimated_time": 120,
    "tags": ["topic1", "topic2"],
    "difficulty": "Easy",
    "category": "sub-domain"
  }
]

Requirements:
1. First 2 questions: Fundamental concepts (Easy)
2. Next 2 questions: Implementation & Scenarios (Medium)
3. Final question: Optimization & Architecture (Advanced)
4. Keywords should be essential technical terms.
5. Hints should be progressive (start vague, end specific).
6. Return ONLY pure raw JSON.
7. ${excludedQuestions != null && excludedQuestions.isNotEmpty ? "DO NOT ask: ${excludedQuestions.join(', ')}" : ""}''';

    try {
      
      _logger.i('🤖 Calling Gemini API (Flash) with key suffix: ...${cleanKey.substring(cleanKey.length - 4)}');

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
          },
          'safetySettings': [
            {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_NONE'},
            {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_NONE'},
            {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold': 'BLOCK_NONE'},
            {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold': 'BLOCK_NONE'}
          ]
        }),
      );

      if (response.statusCode == 200) {
        _logger.i('✅ Gemini response received successfully');
        final data = jsonDecode(response.body);
        
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          _logger.w('⚠️ Gemini returned no candidates. Possibly safety blocked.');
          return [];
        }
        
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Robust JSON extraction
        String jsonText = text.trim();
        
        // Find the first '[' and the last ']'
        int startIndex = jsonText.indexOf('[');
        int endIndex = jsonText.lastIndexOf(']');
        
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          jsonText = jsonText.substring(startIndex, endIndex + 1);
        }

        try {
          final List<dynamic> questionsJson = jsonDecode(jsonText);
          return questionsJson.map((q) => Question.fromJson(q)).toList();
        } catch (parseError) {
          _logger.e('Failed to parse extracted JSON: $parseError');
          _logger.e('Extracted text was: $jsonText');
          rethrow;
        }
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

  Future<Map<String, dynamic>> _evaluateAnswerGemini({
    required String question,
    required String answer,
    required String apiKey,
    List<Keyword>? keywords,
    String? model,
  }) async {
    final modelName = model ?? 'gemini-1.5-flash';
    final cleanKey = apiKey.trim();
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/$modelName:generateContent?key=$cleanKey',
    );

    final prompt = '''Evaluate this interview answer:

Question: $question
Answer: $answer
${keywords != null && keywords.isNotEmpty ? "Target Keywords: ${keywords.map((k) => k.word).join(', ')}" : ""}

Provide evaluation in JSON format:
{
  "score": <number 0-10>,
  "matchedKeywords": [<list of important concepts mentioned>],
  "feedback": "<detailed constructive feedback>",
  "correct_answer": "<the ideal detailed answer for this question>"
}

Return ONLY the JSON object.''';

    try {
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
          'safetySettings': [
            {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_NONE'},
            {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_NONE'},
            {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold': 'BLOCK_NONE'},
            {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold': 'BLOCK_NONE'}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          _logger.w('⚠️ Gemini Evaluation returned no candidates.');
          return {'score': 0, 'matchedKeywords': [], 'feedback': 'Gemini blocked or returned no result.'};
        }
        
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        String jsonText = text.trim();
        // Robust extraction: find first '{' and last '}'
        int startIndex = jsonText.indexOf('{');
        int endIndex = jsonText.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          jsonText = jsonText.substring(startIndex, endIndex + 1);
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

  Future<Map<String, dynamic>> _analyzeResumeGemini({
    required String resumeText,
    required String apiKey,
    String? base64Data,
    String? mimeType,
    String? model,
  }) async {
    final modelName = model ?? 'gemini-1.5-flash';
    final cleanKey = apiKey.trim();
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/$modelName:generateContent?key=$cleanKey',
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

  Future<Map<String, dynamic>> _analyzePersonalityGemini({
    required List<Map<String, String>> transcript,
    required String apiKey,
    String? model,
  }) async {
    final modelName = model ?? 'gemini-1.5-flash';
    final cleanKey = apiKey.trim();
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/$modelName:generateContent?key=$cleanKey',
    );

    final transcriptText = transcript.map((m) => "${m['role']}: ${m['content']}").join("\n");

    final prompt = '''Analyze this interview transcript and create a professional personality profile.
    
    Transcript:
    $transcriptText
    
    Instructions:
    1. Determine a unique "traitName" (e.g., "The Strategic Architect", "The Creative Problem Solver").
    2. Provide a 2-sentence "description" of their behavioral style.
    3. Score these dimensions (1-100): analytical, creative, strategic, collaborative, detail.
    4. List 3 key "strengths".
    5. Provide actionable "advice" for improvement.
    
    Return ONLY JSON:
    {
      "traitName": "string",
      "description": "string",
      "scores": {
        "analytical": number,
        "creative": number,
        "strategic": number,
        "collaborative": number,
        "detail": number
      },
      "strengths": ["string", "string", "string"],
      "advice": "string"
    }''';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey.trim(),
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
        
        String jsonText = text.trim();
        int startIndex = jsonText.indexOf('{');
        int endIndex = jsonText.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          jsonText = jsonText.substring(startIndex, endIndex + 1);
        }

        return jsonDecode(jsonText);
      } else {
        throw Exception('Gemini API Error: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error in personality analysis: $e');
      return {
        "traitName": "The Resilient Candidate",
        "description": "Displays persistence despite technical challenges.",
        "scores": {"analytical": 50, "creative": 50, "strategic": 50, "collaborative": 50, "detail": 50},
        "strengths": ["Persistence"],
        "advice": "Try again to get a deeper AI analysis."
      };
    }
  }

  // ==================== GROQ (OpenAI Compatible) API METHODS ====================

  Future<List<Question>> _generateQuestionsGeneric({
    required String domain,
    required String difficulty,
    required String apiKey,
    required int count,
    required String provider,
    String? baseUrl,
    String? model,
    List<String>? excludedQuestions,
  }) async {
    final modelName = model ?? (provider.toLowerCase() == 'groq' ? 'llama-3.3-70b-versatile' : 'gpt-3.5-turbo');
    final String apiUrl = baseUrl != null ? "$baseUrl/chat/completions" : 'https://api.groq.com/openai/v1/chat/completions';

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final prompt = '''Generate $count HIGHLY SPECIFIC and DIVERSE interview questions for the $domain domain at a $difficulty level.
Session ID: $timestamp

REQUIRED JSON FORMAT:
[
  {
    "id": "unique_id",
    "question_text": "the actual question here",
    "ideal_answer": "a comprehensive correct answer for reference",
    "keywords": [{"word": "key1", "points": 5}, {"word": "key2", "points": 5}],
    "hints": ["progressive hint 1", "progressive hint 2"],
    "explanation": "concise explanation of why this matters",
    "estimated_time": 120,
    "tags": ["topic1", "topic2"],
    "difficulty": "Easy",
    "category": "technical"
  }
]

Requirements:
1. PROGRESSION: Beginner to Advanced (Easy -> Medium -> Hard).
2. AVOID basic definitions for advanced questions.
3. Return ONLY pure raw JSON.
4. ${excludedQuestions != null && excludedQuestions.isNotEmpty ? "DO NOT ask: ${excludedQuestions.join(', ')}" : ""}''';

    try {
      _logger.i('📡 Calling Groq API with model: $modelName');
      _logger.i('🔑 API Key (last 8 chars): ...${apiKey.substring(apiKey.length - 8)}');
      _logger.i('🌐 API URL: $apiUrl');
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${apiKey.trim()}',
        },
        body: jsonEncode({
          'model': modelName,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.9,
        }),
      );

      _logger.i('📥 Groq Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['choices'][0]['message']['content'];

        // Robust JSON extraction
        String jsonText = text.trim();
        
        // Remove markdown code blocks if present
        if (jsonText.contains('```json')) {
          jsonText = jsonText.split('```json')[1].split('```')[0].trim();
        } else if (jsonText.contains('```')) {
          jsonText = jsonText.split('```')[1].split('```')[0].trim();
        }
        
        // Final fallback: find first '[' and last ']'
        if (!jsonText.startsWith('[')) {
          int startIndex = jsonText.indexOf('[');
          int endIndex = jsonText.lastIndexOf(']');
          if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
            jsonText = jsonText.substring(startIndex, endIndex + 1);
          }
        }

        final List<dynamic> questionsJson = jsonDecode(jsonText);
        _logger.i('✅ Successfully generated ${questionsJson.length} questions from Groq');
        return questionsJson.map((q) => Question.fromJson(q)).toList();
      } else {
        _logger.e('❌ Groq API error: ${response.statusCode}');
        _logger.e('❌ Response body: ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      _logger.e('💥 Error calling Groq API: $e');
      _logger.e('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<Map<String, dynamic>> _evaluateAnswerGeneric({
    required String question,
    required String answer,
    required String apiKey,
    required String provider,
    String? baseUrl,
    List<Keyword>? keywords,
    String? model,
  }) async {
    final modelName = model ?? (provider.toLowerCase() == 'groq' ? 'llama-3.3-70b-versatile' : 'gpt-3.5-turbo');
    final String apiUrl = baseUrl != null ? "$baseUrl/chat/completions" : 'https://api.groq.com/openai/v1/chat/completions';

    final prompt = '''Evaluate this interview answer:

Question: $question
Answer: $answer
${keywords != null && keywords.isNotEmpty ? "Target Keywords: ${keywords.map((k) => k.word).join(', ')}" : ""}

Provide evaluation in JSON format:
{
  "score": <number 0-10>,
  "matchedKeywords": [<list of important concepts mentioned>],
  "feedback": "<detailed constructive feedback>",
  "correct_answer": "<the ideal detailed answer for this question>"
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
          'model': modelName,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['choices'][0]['message']['content'];

        String jsonText = text.trim();
        
        // Remove markdown code blocks if present
        if (jsonText.contains('```json')) {
          jsonText = jsonText.split('```json')[1].split('```')[0].trim();
        } else if (jsonText.contains('```')) {
          jsonText = jsonText.split('```')[1].split('```')[0].trim();
        }

        // Final fallback: find first '{' and last '}'
        if (!jsonText.startsWith('{')) {
          int startIndex = jsonText.indexOf('{');
          int endIndex = jsonText.lastIndexOf('}');
          if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
            jsonText = jsonText.substring(startIndex, endIndex + 1);
          }
        }

        return jsonDecode(jsonText);
      } else {
        _logger.e('Groq API error: ${response.statusCode}');
        return {'score': 0, 'matchedKeywords': [], 'feedback': 'API Error'};
      }
    } catch (e) {
      _logger.e('Error calling Groq API: $e');
      return {'score': 0, 'matchedKeywords': [], 'feedback': 'Evaluation failed'};
    }
  }

  Future<Map<String, dynamic>> _analyzeResumeGeneric({
    required String resumeText,
    required String apiKey,
    required String provider,
    String? baseUrl,
    String? model,
  }) async {
    final modelName = model ?? (provider.toLowerCase() == 'groq' ? 'llama-3.3-70b-versatile' : 'gpt-3.5-turbo');
    final String apiUrl = baseUrl != null ? "$baseUrl/chat/completions" : 'https://api.groq.com/openai/v1/chat/completions';

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
          'model': modelName,
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
    int count) async {
    // Similar implementation for OpenAI
    // Using GPT-3.5-turbo or GPT-4
    _logger.w('OpenAI integration not yet implemented, returning empty list');
    return [];
  }

  Future<Map<String, dynamic>> _evaluateAnswerOpenAI(
    String question,
    String answer,
    String apiKey,
    List<Keyword>? keywords) async {
    _logger.w('OpenAI integration not yet implemented');
    return {'score': 0, 'matchedKeywords': [], 'feedback': 'OpenAI not implemented yet'};
  }

  Future<Map<String, dynamic>> _analyzeResumeOpenAI(
    String resumeText,
    String apiKey, {
    String? model,
  }) async {
    _logger.w('OpenAI integration not yet implemented');
    return {
      'overall_score': 0,
      'strengths': [],
      'weaknesses': [],
      'suggestions': ['OpenAI not implemented yet'],
      'formatting_issues': [],
    };
  }

  /// Analyze resume using Groq (text-based, no multimodal)
  Future<Map<String, dynamic>> _analyzeResumeGroq({
    required String resumeText,
    required String apiKey,
    required String model,
    String? base64Data,
    String? mimeType,
  }) async {
    const url = 'https://api.groq.com/openai/v1/chat/completions';

    String contentToAnalyze = resumeText;
    
    // If we have base64 data but Groq doesn't support it, provide guidance
    if (base64Data != null && resumeText.isEmpty) {
      contentToAnalyze = '''[Resume uploaded as ${mimeType ?? 'file'}]

Note: This is a file-based resume. Please extract text content first before analysis.
For now, providing general resume analysis guidance.''';
    }

    final prompt = '''Analyze this resume and provide a detailed assessment in JSON format with these exact keys:
{
  "overall_score": <number 0-100>,
  "strengths": [<list of 3-5 key strengths>],
  "weaknesses": [<list of 3-5 areas for improvement>],
  "suggestions": [<list of 3-5 specific actionable recommendations>],
  "formatting_issues": [<list of formatting problems, empty array if none>],
  "ats_score": <number 0-100 for ATS compatibility>,
  "keywords_found": [<list of relevant keywords found>],
  "missing_keywords": [<list of important keywords missing>]
}

Resume to analyze:
$contentToAnalyze

Provide ONLY valid JSON, no markdown, no code blocks, no other text.''';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
        'max_tokens': 2048,
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'] ?? '';
      
      _logger.i('✅ Groq resume analysis completed');
      
      // Parse JSON response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch != null) {
        final result = jsonDecode(jsonMatch.group(0)!);
        
        // Add a note if it was a file
        if (base64Data != null && resumeText.isEmpty) {
          result['note'] = 'Analysis based on general resume best practices. For detailed analysis, please use text-based resume or Gemini provider which supports image/PDF.';
        }
        
        return result;
      }
      
      // Try parsing the content directly
      return jsonDecode(content);
    } else {
      _logger.e('❌ Groq API error: ${response.statusCode} - ${response.body}');
      throw Exception('Groq API error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _analyzePersonalityGeneric({
    required List<Map<String, String>> transcript,
    required String apiKey,
    required String provider,
    String? model,
  }) async {
    final modelName = model ?? (provider.toLowerCase() == 'groq' ? 'llama-3.3-70b-versatile' : 'gpt-3.5-turbo');
    final String apiUrl = provider.toLowerCase() == 'groq' 
        ? 'https://api.groq.com/openai/v1/chat/completions' 
        : 'https://api.openai.com/v1/chat/completions';

    final transcriptText = transcript.map((m) => "${m['role']}: ${m['content']}").join("\n");

    final prompt = '''Analyze this interview transcript and create a professional personality profile.
    
    Transcript:
    $transcriptText
    
    Instructions:
    1. Determine a unique "traitName" (e.g., "The Strategic Architect", "The Creative Problem Solver").
    2. Provide a 2-sentence "description" of their behavioral style.
    3. Score these dimensions (1-100): analytical, creative, strategic, collaborative, detail.
    4. List 3 key "strengths".
    5. Provide actionable "advice" for improvement.
    
    Return ONLY JSON:
    {
      "traitName": "string",
      "description": "string",
      "scores": {
        "analytical": number,
        "creative": number,
        "strategic": number,
        "collaborative": number,
        "detail": number
      },
      "strengths": ["string", "string", "string"],
      "advice": "string"
    }''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${apiKey.trim()}',
        },
        body: jsonEncode({
          'model': modelName,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['choices'][0]['message']['content'];
        
        String jsonText = text.trim();
        int startIndex = jsonText.indexOf('{');
        int endIndex = jsonText.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          jsonText = jsonText.substring(startIndex, endIndex + 1);
        }

        return jsonDecode(jsonText);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error in generic personality analysis: $e');
      return {
        "traitName": "The Resilient Candidate",
        "description": "Displays persistence despite technical challenges.",
        "scores": {"analytical": 55, "creative": 55, "strategic": 55, "collaborative": 55, "detail": 55},
        "strengths": ["Persistence", "Adaptability", "Composure"],
        "advice": "Try completing another interview for a deeper analysis."
      };
    }
  }
}

