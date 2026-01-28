import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for AI Provider configuration from Firestore
class AiProviderModel {
  final String id;
  final String provider;
  final String model;
  final String apiKey;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AiProviderModel({
    required this.id,
    required this.provider,
    required this.model,
    required this.apiKey,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from Firestore document
  factory AiProviderModel.fromMap(Map<String, dynamic> map, String docId) {
    return AiProviderModel(
      id: docId,
      provider: map['provider'] as String? ?? '',
      model: map['model'] as String? ?? '',
      apiKey: map['apiKey'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'provider': provider,
      'model': model,
      'apiKey': apiKey,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with updated fields
  AiProviderModel copyWith({
    String? id,
    String? provider,
    String? model,
    String? apiKey,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AiProviderModel(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      model: model ?? this.model,
      apiKey: apiKey ?? this.apiKey,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AiProviderModel(id: $id, provider: $provider, model: $model, isActive: $isActive)';
  }
}
