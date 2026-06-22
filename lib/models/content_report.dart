class ContentReport {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final String? messageId;
  final String reason;
  final String status;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  ContentReport({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    this.messageId,
    required this.reason,
    this.status = 'pending',
    this.adminNotes,
    required this.createdAt,
    this.reviewedAt,
  });

  factory ContentReport.fromJson(Map<String, dynamic> json) {
    final reviewedAtStr = json['reviewed_at'] as String?;
    return ContentReport(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      reportedUserId: json['reported_user_id'] as String,
      messageId: json['message_id'] as String?,
      reason: json['reason'] as String,
      status: json['status'] as String? ?? 'pending',
      adminNotes: json['admin_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewedAt: reviewedAtStr != null 
          ? DateTime.parse(reviewedAtStr) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'reported_user_id': reportedUserId,
      'message_id': messageId,
      'reason': reason,
      'status': status,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }
}