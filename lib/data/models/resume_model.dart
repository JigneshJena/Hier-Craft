class ResumeAnalysis {
  final int overallScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> suggestions;
  final List<String> formattingIssues;

  ResumeAnalysis({
    required this.overallScore,
    required this.strengths,
    required this.weaknesses,
    required this.suggestions,
    this.formattingIssues = const [],
  });

  factory ResumeAnalysis.fromJson(Map<String, dynamic> json) {
    return ResumeAnalysis(
      overallScore: json['overall_score'] as int? ?? 0,
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      weaknesses: (json['weaknesses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      formattingIssues: (json['formatting_issues'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_score': overallScore,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'suggestions': suggestions,
      'formatting_issues': formattingIssues,
    };
  }

  // Get score grade (A, B, C, D, F)
  String get grade {
    if (overallScore >= 90) return 'A';
    if (overallScore >= 80) return 'B';
    if (overallScore >= 70) return 'C';
    if (overallScore >= 60) return 'D';
    return 'F';
  }

  // Get score color
  String get scoreColor {
    if (overallScore >= 80) return 'green';
    if (overallScore >= 60) return 'orange';
    return 'red';
  }
}
