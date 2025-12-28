import 'dart:convert';
import 'package:flutter/services.dart';
import 'interview_engine.dart';
import '../../data/models/question_model.dart';
import 'scoring_service.dart';
import 'package:get/get.dart';

class OfflineInterviewEngine implements InterviewEngine {
  final ScoringService _scoringService = Get.find<ScoringService>();

  @override
  Future<List<Question>> getQuestions(String domain, String difficulty) async {
    // In a real app, this would load from a JSON file based on the domain
    // For now, loading from assets/questions.json
    final String response = await rootBundle.loadString('assets/questions.json');
    final data = await json.decode(response);
    
    // Flexible domain matching
    dynamic domainData;
    final lowerDomain = domain.toLowerCase();
    
    // Try exact match first
    if (data.containsKey(domain)) {
      domainData = data[domain];
    } else {
      // Try partial case-insensitive match
      final matchingKey = data.keys.firstWhere(
        (key) => key.toString().toLowerCase().contains(lowerDomain) || 
                  lowerDomain.contains(key.toString().toLowerCase()),
        orElse: () => 'Flutter',
      );
      domainData = data[matchingKey];
    }

    List<dynamic> questionsList = domainData ?? [];
    return questionsList
        .map((q) => Question.fromJson(q))
        .where((q) => q.difficulty.toLowerCase() == difficulty.toLowerCase())
        .toList();
  }

  @override
  Future<Map<String, dynamic>> evaluateAnswer(String questionId, String answer, List<Keyword> keywords) async {
    // Transitioning from keywords to contextual elements
    List<Map<String, dynamic>> contextElements = keywords.map((k) => {
      'word': k.word,
      'points': k.points,
      'synonyms': k.synonyms,
    }).toList();
    
    return _scoringService.evaluateAnswer(answer, contextElements);
  }
}
