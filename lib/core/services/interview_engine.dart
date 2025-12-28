import '../../data/models/question_model.dart';

abstract class InterviewEngine {
  Future<List<Question>> getQuestions(String domain, String difficulty);
  Future<Map<String, dynamic>> evaluateAnswer(String questionId, String answer, List<Keyword> keywords);
}
