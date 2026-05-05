import 'package:core_utils/core_utils.dart';

class FoodRatingModel {
  final double avgRating;
  final int totalReviews;

  const FoodRatingModel({required this.avgRating, required this.totalReviews});

  factory FoodRatingModel.fromJson(Map<String, dynamic> json) => FoodRatingModel(
        avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      );

  static const empty = FoodRatingModel(avgRating: 0.0, totalReviews: 0);
}

class FavoriteItemModel {
  final int id;
  final int foodId;
  final String foodName;
  final double price;
  final String? imageUrl;
  final DateTime createdAt;

  const FavoriteItemModel({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.price,
    this.imageUrl,
    required this.createdAt,
  });

  factory FavoriteItemModel.fromJson(Map<String, dynamic> json) {
    return FavoriteItemModel(
      id: (json['id'] as num).toInt(),
      foodId: (json['foodId'] as num).toInt(),
      foodName: json['foodName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      createdAt: parseApiDateTime(json['createdAt']),
    );
  }
}

class ReviewModel {
  final int id;
  final String userId;
  final String userFullName;
  final String orderId;
  final int foodId;
  final String foodName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.orderId,
    required this.foodId,
    required this.foodName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: (json['id'] as num).toInt(),
      userId: json['userId'] as String? ?? '',
      userFullName: json['userFullName'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      foodId: (json['foodId'] as num?)?.toInt() ?? 0,
      foodName: json['foodName'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString(),
      createdAt: parseApiDateTime(json['createdAt']),
    );
  }
}
