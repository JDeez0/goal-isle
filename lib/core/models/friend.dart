/// Friend — models a friend request between two users.
/// status is 'accepted' | 'pending_in' | 'pending_out'.
class Friend {
  const Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friendName,
    required this.friendAvatar,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String friendId;
  final String friendName;
  final String friendAvatar;
  final String status;
  final DateTime createdAt;

  Friend copyWith({
    String? id,
    String? userId,
    String? friendId,
    String? friendName,
    String? friendAvatar,
    String? status,
    DateTime? createdAt,
  }) =>
      Friend(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        friendId: friendId ?? this.friendId,
        friendName: friendName ?? this.friendName,
        friendAvatar: friendAvatar ?? this.friendAvatar,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        friendId: json['friend_id'] as String,
        friendName: json['friend_name'] as String,
        friendAvatar: json['friend_avatar'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'friend_id': friendId,
        'friend_name': friendName,
        'friend_avatar': friendAvatar,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };
}
