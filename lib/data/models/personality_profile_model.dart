import 'dart:convert';

class PersonalityProfile {
  final String traitName;
  final String description;
  final Map<String, int> scores; // analytical, creative, strategic, collaborative, etc.
  final List<String> strengths;
  final String advice;

  PersonalityProfile({
    required this.traitName,
    required this.description,
    required this.scores,
    required this.strengths,
    required this.advice,
  });

  Map<String, dynamic> toJson() {
    return {
      'traitName': traitName,
      'description': description,
      'scores': scores,
      'strengths': strengths,
      'advice': advice,
    };
  }

  factory PersonalityProfile.fromJson(Map<String, dynamic> json) {
    return PersonalityProfile(
      traitName: json['traitName'] ?? 'The Observer',
      description: json['description'] ?? 'An insightful and steady participant.',
      scores: Map<String, int>.from(json['scores'] ?? {}),
      strengths: List<String>.from(json['strengths'] ?? []),
      advice: json['advice'] ?? 'Continue practicing to refine your communication style.',
    );
  }
}
