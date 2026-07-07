/// Membership — links a user to an Isle.
/// role is 'creator' | 'member'.
class Membership {
  const Membership({
    required this.isleId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.role,
    required this.joinedAt,
  });

  final String isleId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String role;
  final DateTime joinedAt;

  Membership copyWith({
    String? isleId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? role,
    DateTime? joinedAt,
  }) =>
      Membership(
        isleId: isleId ?? this.isleId,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        userAvatar: userAvatar ?? this.userAvatar,
        role: role ?? this.role,
        joinedAt: joinedAt ?? this.joinedAt,
      );

  factory Membership.fromJson(Map<String, dynamic> json) => Membership(
        isleId: json['isle_id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        userAvatar: json['user_avatar'] as String,
        role: json['role'] as String,
        joinedAt: DateTime.parse(json['joined_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'isle_id': isleId,
        'user_id': userId,
        'user_name': userName,
        'user_avatar': userAvatar,
        'role': role,
        'joined_at': joinedAt.toIso8601String(),
      };
}
