class User {
  final String id;
  final String email;
  final String? phoneNumber;
  final String? username;
  final String? profilePhotoUrl;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.phoneNumber,
    this.username,
    this.profilePhotoUrl,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      username: json['username'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_number': phoneNumber,
      'username': username,
      'profile_photo_url': profilePhotoUrl,
      'settings': settings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}