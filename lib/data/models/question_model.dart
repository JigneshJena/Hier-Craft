class Question {
  final String id;
  final String category;
  final String text;
  final List<Keyword> keywords;
  final int maxPoints;
  final String? hint;
  final String difficulty;

  Question({
    required this.id,
    required this.category,
    required this.text,
    required this.keywords,
    required this.maxPoints,
    this.difficulty = 'Fresher',
    this.hint,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      category: json['category'] ?? 'general',
      text: json['text'],
      difficulty: json['difficulty'] ?? 'Fresher',
      keywords: (json['keywords'] as List)
          .map((k) => Keyword.fromJson(k))
          .toList(),
      maxPoints: json['maxPoints'] ?? 10,
      hint: json['hint'],
    );
  }
}

class Keyword {
  final String word;
  final int points;
  final List<String> synonyms;

  Keyword({
    required this.word,
    required this.points,
    this.synonyms = const [],
  });

  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(
      word: json['word'],
      points: json['points'],
      synonyms: List<String>.from(json['synonyms'] ?? []),
    );
  }
}

class InterviewDomain {
  final String name;
  final String icon;
  final List<String> subdomains;

  InterviewDomain({
    required this.name,
    required this.icon,
    required this.subdomains,
  });
}
