class Message {
  final String id;
  final String isleId;
  final String senderId;
  final String? content;
  final String contentType;
  final List<Map<String, dynamic>> reactions;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.isleId,
    required this.senderId,
    this.content,
    this.contentType = 'text',
    this.reactions = const [],
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      isleId: json['isle_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String?,
      contentType: json['content_type'] as String? ?? 'text',
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isle_id': isleId,
      'sender_id': senderId,
      'content': content,
      'format': contentType,
      'reactions': reactions,
      'created_at': createdAt.toIso8601String(),
    };
  }
}