class ClassGroup {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  ClassGroup({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClassGroup.fromJson(Map<String, dynamic> json) {
    return ClassGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
