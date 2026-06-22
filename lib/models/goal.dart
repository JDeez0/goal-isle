class Goal {
  final String id;
  final String isleId;
  final String emoji;
  final String text;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.isleId,
    required this.emoji,
    required this.text,
    required this.metadata,
    required this.createdAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      isleId: json['isle_id'] as String,
      emoji: json['emoji'] as String,
      text: json['text'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isle_id': isleId,
      'emoji': emoji,
      'text': text,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }
}