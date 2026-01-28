enum PracticeMode { offline, online, hybrid }

enum DifficultyLevel { easy, medium, hard }

class EvaluationResult {
  final int score;
  final List<String> matchedKeywords;
  final String feedback;
  final String? idealAnswer;
  final List<String>? strengths;
  final List<String>? improvements;

  EvaluationResult({
    required this.score,
    required this.matchedKeywords,
    required this.feedback,
    this.idealAnswer,
    this.strengths,
    this.improvements,
  });

  factory EvaluationResult.fromJson(Map<String, dynamic> json) {
    return EvaluationResult(
      score: json['score'] != null ? (json['score'] is num ? (json['score'] as num).toInt() : int.tryParse(json['score'].toString()) ?? 0) : 0,
      matchedKeywords: List<String>.from(json['matched_keywords'] ?? json['matchedKeywords'] ?? []),
      feedback: json['feedback'] ?? '',
      idealAnswer: json['ideal_answer'] ?? json['correct_answer'] ?? json['idealAnswer'],
      strengths: List<String>.from(json['strengths'] ?? []),
      improvements: List<String>.from(json['improvements'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'matched_keywords': matchedKeywords,
      'feedback': feedback,
      'ideal_answer': idealAnswer,
      'strengths': strengths,
      'improvements': improvements,
    };
  }
}
