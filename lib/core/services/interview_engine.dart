import '../../data/models/question_model.dart';

abstract class InterviewEngine {
  Future<List<Question>> getQuestions(String domain, String difficulty, {
    int count = 5,
    String? explicitApiKey,
    String? explicitProvider,
    String? explicitModel,
  });
  
  Future<Map<String, dynamic>> evaluateAnswer(
    String questionId, 
    String answer, 
    List<Keyword> keywords, {
    String? explicitApiKey,
    String? explicitProvider,
    String? explicitModel,
  });
}
