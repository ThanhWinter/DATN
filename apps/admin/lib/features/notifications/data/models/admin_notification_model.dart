import 'package:core_utils/core_utils.dart';

class AdminNotificationModel {
  const AdminNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.orderId,
  });

  final int id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? orderId;

  factory AdminNotificationModel.fromJson(Map<String, dynamic> json) =>
      AdminNotificationModel(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String,
        body: json['body'] as String,
        isRead: json['isRead'] as bool? ?? false,
        createdAt: parseApiDateTime(json['createdAt']),
        orderId: json['orderId'] as String?,
      );

  AdminNotificationModel copyWith({bool? isRead}) => AdminNotificationModel(
        id: id,
        title: title,
        body: body,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        orderId: orderId,
      );
}
