class DomainModel {
  final String id;
  final String name;
  final String iconName;
  final String category;
  final String description;
  final List<String> subdomains;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DomainModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.category,
    required this.description,
    this.subdomains = const [],
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory DomainModel.fromMap(Map<String, dynamic> map, String id) {
    return DomainModel(
      id: id,
      name: map['name'] ?? '',
      iconName: map['iconName'] ?? 'default',
      category: map['category'] ?? 'Other',
      description: map['description'] ?? '',
      subdomains: List<String>.from(map['subdomains'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconName': iconName,
      'category': category,
      'description': description,
      'subdomains': subdomains,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  DomainModel copyWith({
    String? id,
    String? name,
    String? iconName,
    String? category,
    String? description,
    List<String>? subdomains,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DomainModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      category: category ?? this.category,
      description: description ?? this.description,
      subdomains: subdomains ?? this.subdomains,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
