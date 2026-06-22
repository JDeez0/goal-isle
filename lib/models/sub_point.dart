class SubPoint {
  final String id;
  final String goalId;
  final String emoji;
  final String description;
  final int fillCount;
  final DateTime lastFilledAt;
  final List<DateTime> fillHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubPoint({
    required this.id,
    required this.goalId,
    required this.emoji,
    required this.description,
    this.fillCount = 0,
    required this.lastFilledAt,
    required this.fillHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubPoint.fromJson(Map<String, dynamic> json) {
    final lastFilledAtStr = json['last_filled_at'] as String?;
    return SubPoint(
      id: json['id'] as String,
      goalId: json['goal_id'] as String,
      emoji: json['emoji'] as String,
      description: json['description'] as String,
      fillCount: json['fill_count'] as int? ?? 0,
      lastFilledAt: lastFilledAtStr != null 
          ? DateTime.parse(lastFilledAtStr) 
          : DateTime.now(),
      fillHistory: (json['fill_history'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'emoji': emoji,
      'description': description,
      'fill_count': fillCount,
      'last_filled_at': lastFilledAt.toIso8601String(),
      'fill_history': fillHistory.map((e) => e.toIso8601String()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}