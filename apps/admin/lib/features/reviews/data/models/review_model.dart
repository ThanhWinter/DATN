class AdminReviewModel {
  final int id;
  final String userId;
  final String userFullName;
  final String orderId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const AdminReviewModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.orderId,
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
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        comment: json['comment'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
