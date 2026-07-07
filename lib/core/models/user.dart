/// User — the signed-in account.
/// Avatar is an emoji string. `bio` is optional.
class User {
  const User({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatar,
    this.bio,
  });

  final String id;
  final String name;
  final String handle;
  final String avatar;
  final String? bio;

  User copyWith({
    String? id,
    String? name,
    String? handle,
    String? avatar,
    String? bio,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        handle: handle ?? this.handle,
        avatar: avatar ?? this.avatar,
        bio: bio ?? this.bio,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        handle: json['handle'] as String,
        avatar: json['avatar'] as String,
        bio: json['bio'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'handle': handle,
        'avatar': avatar,
        if (bio != null) 'bio': bio,
      };
}
