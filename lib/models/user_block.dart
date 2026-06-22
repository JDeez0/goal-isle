class UserBlock {
  final String id;
  final String blockerId;
  final String blockedId;
  final DateTime blockedAt;

  UserBlock({
    required this.id,
    required this.blockerId,
    required this.blockedId,
    required this.blockedAt,
  });

  factory UserBlock.fromJson(Map<String, dynamic> json) {
    return UserBlock(
      id: json['id'] as String,
      blockerId: json['blocker_id'] as String,
      blockedId: json['blocked_id'] as String,
      blockedAt: DateTime.parse(json['blocked_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'blocker_id': blockerId,
      'blocked_id': blockedId,
      'blocked_at': blockedAt.toIso8601String(),
    };
  }
}
