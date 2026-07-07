/// Post — a one-off broadcast to one or more Isles.
/// Per ISLE_SPARKS_SPEC_v2 §5.
class Post {
  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    this.text,
    this.emoji, // big emoji like in messages
    this.imageUrl,
    this.audience = const [], // isleIds, or ['all'] for all
    required this.createdAt,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String? text;
  final String? emoji;
  final String? imageUrl;
  final List<String> audience;
  final DateTime createdAt;

  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? text,
    String? emoji,
    String? imageUrl,
    List<String>? audience,
    DateTime? createdAt,
  }) =>
      Post(
        id: id ?? this.id,
        authorId: authorId ?? this.authorId,
        authorName: authorName ?? this.authorName,
        authorAvatar: authorAvatar ?? this.authorAvatar,
        text: text ?? this.text,
        emoji: emoji ?? this.emoji,
        imageUrl: imageUrl ?? this.imageUrl,
        audience: audience ?? this.audience,
        createdAt: createdAt ?? this.createdAt,
      );

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as String,
        authorId: json['author_id'] as String,
        authorName: json['author_name'] as String,
        authorAvatar: json['author_avatar'] as String,
        text: json['text'] as String?,
        emoji: json['emoji'] as String?,
        imageUrl: json['image_url'] as String?,
        audience: (json['audience'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'author_id': authorId,
        'author_name': authorName,
        'author_avatar': authorAvatar,
        if (text != null) 'text': text,
        if (emoji != null) 'emoji': emoji,
        if (imageUrl != null) 'image_url': imageUrl,
        'audience': audience,
        'created_at': createdAt.toIso8601String(),
      };
}
