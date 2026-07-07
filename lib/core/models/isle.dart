import 'enums.dart';
import 'message.dart';
import 'post.dart';
import 'spark.dart';

/// Isle — a community. Contains sparks, posts, messages, members.
/// Per ISLE_SPARKS_SPEC_v2 §4.
class Isle {
  const Isle({
    required this.id,
    required this.name,
    required this.emoji,
    this.purpose,
    required this.color, // color name: 'blue' | 'green' | ...
    this.visibility = IsleVisibility.private,
    required this.createdBy,
    required this.createdAt,
    this.sparks = const [],
    this.posts = const [],
    this.msgs = const [],
  });

  final String id;
  final String name;
  final String emoji;
  final String? purpose;
  final String color;
  final IsleVisibility visibility;
  final String createdBy;
  final DateTime createdAt;
  final List<Spark> sparks;
  final List<Post> posts;
  final List<Message> msgs;

  Isle copyWith({
    String? id,
    String? name,
    String? emoji,
    String? purpose,
    String? color,
    IsleVisibility? visibility,
    String? createdBy,
    DateTime? createdAt,
    List<Spark>? sparks,
    List<Post>? posts,
    List<Message>? msgs,
  }) =>
      Isle(
        id: id ?? this.id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        purpose: purpose ?? this.purpose,
        color: color ?? this.color,
        visibility: visibility ?? this.visibility,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        sparks: sparks ?? this.sparks,
        posts: posts ?? this.posts,
        msgs: msgs ?? this.msgs,
      );

  factory Isle.fromJson(Map<String, dynamic> json) => Isle(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['main_emoji'] as String,
        purpose: json['purpose'] as String?,
        color: json['color'] as String,
        visibility: enumFromString(
          IsleVisibility.values,
          json['visibility'] as String? ?? 'private',
        ),
        createdBy: json['created_by'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        sparks: (json['sparks'] as List<dynamic>?)
                ?.map((e) => Spark.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        posts: (json['posts'] as List<dynamic>?)
                ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        msgs: (json['msgs'] as List<dynamic>?)
                ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'main_emoji': emoji,
        if (purpose != null) 'purpose': purpose,
        'color': color,
        'visibility': visibility.name,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'sparks': sparks.map((e) => e.toJson()).toList(),
        'posts': posts.map((e) => e.toJson()).toList(),
        'msgs': msgs.map((e) => e.toJson()).toList(),
      };

  /// Law #2: only active Isles appear on Home.
  bool get isActive => sparks.isNotEmpty;
}
