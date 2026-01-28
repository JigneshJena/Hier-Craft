class Question {
  final String id;
  final String category;
  final String text;
  final String? idealAnswer;
  final List<Keyword> keywords;
  final List<String> hints;
  final String? explanation;
  final String difficulty;
  final int estimatedTime; // In seconds
  final List<String> tags;
  final num maxPoints;

  Question({
    required this.id,
    required this.category,
    required this.text,
    this.idealAnswer,
    required this.keywords,
    this.hints = const [],
    this.explanation,
    this.difficulty = 'Fresher',
    this.estimatedTime = 120,
    this.tags = const [],
    this.maxPoints = 10.0,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      category: json['category'] ?? 'general',
      text: json['question_text'] ?? json['text'] ?? '',
      idealAnswer: json['ideal_answer'],
      difficulty: json['difficulty'] ?? 'Fresher',
      keywords: (json['keywords'] as List?)
              ?.map((k) => k is String ? Keyword(word: k, points: 2) : Keyword.fromJson(k))
              .toList() ??
          [],
      hints: List<String>.from(json['hints'] ?? (json['hint'] != null ? [json['hint']] : [])),
      explanation: json['explanation'],
      estimatedTime: json['estimated_time'] ?? 120,
      tags: List<String>.from(json['tags'] ?? []),
      maxPoints: (json['maxPoints'] ?? 10.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'question_text': text,
      'ideal_answer': idealAnswer,
      'keywords': keywords.map((k) => k.toJson()).toList(),
      'hints': hints,
      'explanation': explanation,
      'difficulty': difficulty,
      'estimated_time': estimatedTime,
      'tags': tags,
      'maxPoints': maxPoints,
    };
  }

  String get displayHint {
    if (hints.isNotEmpty) return hints.first;
    if (keywords.isNotEmpty) {
      return "Try to use these keywords: ${keywords.map((k) => k.word).join(', ')}";
    }
    return "No hint available for this question.";
  }
}

class Keyword {
  final String word;
  final num points;
  final List<String> synonyms;

  Keyword({
    required this.word,
    required this.points,
    this.synonyms = const [],
  });

  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(
      word: json['word'],
      points: json['points'] ?? 1.0,
      synonyms: List<String>.from(json['synonyms'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'points': points,
        'synonyms': synonyms,
      };
}

class InterviewDomain {
  final String name;
  final String icon;
  final List<String> subdomains;
  final String category; // e.g., 'BTech', 'MBBS', 'CS', 'General'

  InterviewDomain({
    required this.name,
    required this.icon,
    required this.subdomains,
    this.category = 'Professional',
  });
}
