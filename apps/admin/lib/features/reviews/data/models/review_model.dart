DateTime _parseReviewCreatedAt(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  if (value is List && value.length >= 6) {
    final ns = value.length > 6 ? (value[6] as int) : 0;
    return DateTime(
      value[0] as int,
      value[1] as int,
      value[2] as int,
      value[3] as int,
      value[4] as int,
      value[5] as int,
      ns ~/ 1000000,
      (ns % 1000000) ~/ 1000,
    );
  }
  return DateTime.now();
}

class AdminReviewModel {
  final int id;
  final String userId;
  final String userFullName;
  final String orderId;
  final int? foodId;
  final String? foodName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const AdminReviewModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.orderId,
    this.foodId,
    this.foodName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory AdminReviewModel.fromJson(Map<String, dynamic> json) =>
      AdminReviewModel(
        id: (json['id'] as num).toInt(),
        userId: json['userId'] as String? ?? '',
        userFullName: json['userFullName'] as String? ?? '',
        orderId: json['orderId'] as String? ?? '',
        foodId: (json['foodId'] as num?)?.toInt(),
        foodName: json['foodName'] as String?,
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        comment: json['comment'] as String?,
        createdAt: _parseReviewCreatedAt(json['createdAt']),
      );
}
