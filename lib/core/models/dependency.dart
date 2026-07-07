/// Dependency — a ritual spark's ingredient emoji.
/// `label` is an optional human-readable name for the ingredient.
class Dependency {
  const Dependency({
    required this.id,
    required this.sparkId,
    required this.emoji,
    this.label,
    this.satisfied = false,
    required this.createdAt,
  });

  final String id;
  final String sparkId;
  final String emoji;
  final String? label;
  final bool satisfied;
  final DateTime createdAt;

  Dependency copyWith({
    String? id,
    String? sparkId,
    String? emoji,
    String? label,
    bool? satisfied,
    DateTime? createdAt,
  }) =>
      Dependency(
        id: id ?? this.id,
        sparkId: sparkId ?? this.sparkId,
        emoji: emoji ?? this.emoji,
        label: label ?? this.label,
        satisfied: satisfied ?? this.satisfied,
        createdAt: createdAt ?? this.createdAt,
      );

  factory Dependency.fromJson(Map<String, dynamic> json) => Dependency(
        id: json['id'] as String,
        sparkId: json['spark_id'] as String,
        emoji: json['emoji'] as String,
        label: json['label'] as String?,
        satisfied: json['satisfied'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'spark_id': sparkId,
        'emoji': emoji,
        if (label != null) 'label': label,
        'satisfied': satisfied,
        'created_at': createdAt.toIso8601String(),
      };
}
