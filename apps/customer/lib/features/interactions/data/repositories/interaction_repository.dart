import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/interaction_models.dart';

class InteractionRepository {
  InteractionRepository(this._apiClient);

  final IApiClient _apiClient;

  // ── Favorites ──────────────────────────────────────────────────────────────

  Future<List<FavoriteItemModel>> getMyFavorites() async {
    final response = await _apiClient.get(
      '/interactions/favorites/my',
      query: {'page': '0', 'size': '50'},
    );
    final page = response['result'] as Map<String, dynamic>;
    final list = page['content'] as List<dynamic>? ?? [];
    dev.log('[INTERACTION] ✅ Loaded ${list.length} favorites');
    return list
        .map((e) => FavoriteItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> checkFavorite(int foodId) async {
    final response =
        await _apiClient.get('/interactions/favorites/$foodId/check');
    return response['result'] as bool? ?? false;
  }

  Future<void> toggleFavorite(int foodId) async {
    await _apiClient.post('/interactions/favorites/$foodId/toggle');
    dev.log('[INTERACTION] ✅ Toggled favorite for food $foodId');
  }

  // ── Ratings ───────────────────────────────────────────────────────────────

  Future<FoodRatingModel> getFoodRating(int foodId) async {
    final response = await _apiClient.get('/interactions/foods/$foodId/rating');
    dev.log('[INTERACTION] ✅ Rating loaded for food $foodId');
    return FoodRatingModel.fromJson(response['result'] as Map<String, dynamic>);
  }

  Future<List<ReviewModel>> getFoodReviews(int foodId, {int page = 0, int size = 20}) async {
    try {
      final response = await _apiClient.get(
        '/interactions/foods/$foodId/reviews',
        query: {'page': '$page', 'size': '$size'},
      );
      final result = response['result'];
      List<dynamic> list = [];
      
      if (result is Map<String, dynamic> && result.containsKey('content')) {
        list = result['content'] as List<dynamic>? ?? [];
      } else if (result is List) {
        list = result;
      }
      
      final foodReviews = list.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
      
      dev.log('[INTERACTION] ✅ Loaded ${foodReviews.length} reviews for food $foodId');
      return foodReviews;
    } catch (e) {
      dev.log('[INTERACTION] ⚠️ getFoodReviews error: $e');
      return [];
    }
  }

  // ── Reviews ────────────────────────────────────────────────────────────────

  Future<ReviewModel> createReview({
    required String orderId,
    required int foodId,
    required int rating,
    String? comment,
  }) async {
    final body = <String, dynamic>{
      'orderId': orderId,
      'foodId': foodId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
    final response = await _apiClient.post('/interactions/reviews', body: body);
    dev.log('[INTERACTION] ✅ Review created for order $orderId food $foodId');
    return ReviewModel.fromJson(response['result'] as Map<String, dynamic>);
  }
}
