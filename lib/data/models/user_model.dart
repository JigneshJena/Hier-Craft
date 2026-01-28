import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin' or 'user'
  final String currentPrep;
  final double progress;
  final DateTime lastActive;
  final Map<String, dynamic> metadata;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    required this.currentPrep,
    required this.progress,
    required this.lastActive,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'currentPrep': currentPrep,
      'progress': progress,
      'lastActive': lastActive.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return UserModel(
      id: id,
      name: map['name'] ?? 'Anonymous',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      currentPrep: map['currentPrep'] ?? 'None',
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      lastActive: parseDate(map['lastActive']),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    String? currentPrep,
    double? progress,
    DateTime? lastActive,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      currentPrep: currentPrep ?? this.currentPrep,
      progress: progress ?? this.progress,
      lastActive: lastActive ?? this.lastActive,
      metadata: metadata ?? this.metadata,
    );
  }
}
