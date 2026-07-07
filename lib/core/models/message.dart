/// A single emoji reaction and the user ids that applied it.
class MessageReaction {
  const MessageReaction({
    required this.emoji,
    this.users = const [],
  });

  final String emoji;
  final List<String> users;

  MessageReaction copyWith({
    String? emoji,
    List<String>? users,
  }) =>
      MessageReaction(
        emoji: emoji ?? this.emoji,
        users: users ?? this.users,
      );

  factory MessageReaction.fromJson(Map<String, dynamic> json) => MessageReaction(
        emoji: json['emoji'] as String,
        users: (json['users'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'users': users,
      };
}

/// Message — a chat message in either an Isle room or a per-Spark thread.
/// `content` holds the text body; `big` is used for emoji-only messages
/// rendered at a larger size.
class Message {
  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    this.content,
    this.big,
    this.contentType = 'text',
    this.reactions = const [],
    this.imageUrl,
    required this.createdAt,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String? content;
  final String? big;
  final String contentType;
  final List<MessageReaction> reactions;
  final String? imageUrl;
  final DateTime createdAt;

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    String? big,
    String? contentType,
    List<MessageReaction>? reactions,
    String? imageUrl,
    DateTime? createdAt,
  }) =>
      Message(
        id: id ?? this.id,
        chatId: chatId ?? this.chatId,
        senderId: senderId ?? this.senderId,
        senderName: senderName ?? this.senderName,
        senderAvatar: senderAvatar ?? this.senderAvatar,
        content: content ?? this.content,
        big: big ?? this.big,
        contentType: contentType ?? this.contentType,
        reactions: reactions ?? this.reactions,
        imageUrl: imageUrl ?? this.imageUrl,
        createdAt: createdAt ?? this.createdAt,
      );

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        chatId: json['chat_id'] as String,
        senderId: json['sender_id'] as String,
        senderName: json['sender_name'] as String,
        senderAvatar: json['sender_avatar'] as String,
        content: json['content'] as String?,
        big: json['big'] as String?,
        contentType: json['content_type'] as String? ?? 'text',
        reactions: (json['reactions'] as List<dynamic>?)
                ?.map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        imageUrl: json['image_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'chat_id': chatId,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_avatar': senderAvatar,
        if (content != null) 'content': content,
        if (big != null) 'big': big,
        'content_type': contentType,
        'reactions': reactions.map((e) => e.toJson()).toList(),
        if (imageUrl != null) 'image_url': imageUrl,
        'created_at': createdAt.toIso8601String(),
      };
}
