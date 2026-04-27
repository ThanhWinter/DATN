class NotificationModel {
  final String id;
  final String title;
  final String message; // maps from JSON field 'body'
  final DateTime timestamp; // maps from JSON field 'createdAt'
  final bool isRead;
  final String type; // 'order' if orderId != null, else 'system'
  final String? orderId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.orderId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final orderId = json['orderId'] as String?;
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      message: json['body'] as String? ?? '',
      timestamp: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      orderId: orderId,
      type: orderId != null ? 'order' : 'system',
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    String? orderId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      orderId: orderId ?? this.orderId,
    );
  }
}
