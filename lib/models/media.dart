class Media {
  final String id;
  final String messageId;
  final String type;
  final String url;
  final String? thumbnailUrl;
  final int? duration;
  final int? width;
  final int? height;
  final int? fileSize;
  final DateTime createdAt;

  Media({
    required this.id,
    required this.messageId,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.duration,
    this.width,
    this.height,
    this.fileSize,
    required this.createdAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] as String,
      messageId: json['message_id'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      duration: json['duration'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      fileSize: json['file_size'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_id': messageId,
      'type': type,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'width': width,
      'height': height,
      'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
    };
  }
}