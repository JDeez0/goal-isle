class Isle {
  final String id;
  final String name;
  final String mainEmoji;
  final int mass;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? settings;

  Isle({
    required this.id,
    required this.name,
    required this.mainEmoji,
    required this.mass,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.settings,
  });

  factory Isle.fromJson(Map<String, dynamic> json) {
    return Isle(
      id: json['id'] as String,
      name: json['name'] as String,
      mainEmoji: json['main_emoji'] as String,
      mass: json['mass'] as int,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'main_emoji': mainEmoji,
      'mass': mass,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'settings': settings,
    };
  }
}