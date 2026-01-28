class AiModel {
  final String id;
  final String provider;
  final String apiKey;
  final String model;
  final bool isActive;

  AiModel({
    required this.id,
    required this.provider,
    required this.apiKey,
    required this.model,
    required this.isActive,
  });

  factory AiModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AiModel(
      id: documentId,
      provider: map['provider'] ?? '',
      apiKey: map['apiKey'] ?? '',
      model: map['model'] ?? '',
      isActive: map['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'provider': provider,
      'apiKey': apiKey,
      'model': model,
      'isActive': isActive,
    };
  }

  AiModel copyWith({
    String? id,
    String? provider,
    String? apiKey,
    String? model,
    bool? isActive,
  }) {
    return AiModel(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      isActive: isActive ?? this.isActive,
    );
  }
}
