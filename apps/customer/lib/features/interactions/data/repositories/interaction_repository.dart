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

  // ── Reviews ────────────────────────────────────────────────────────────────

  Future<ReviewModel> createReview({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    final body = <String, dynamic>{
      'orderId': orderId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
    final response = await _apiClient.post('/interactions/reviews', body: body);
    dev.log('[INTERACTION] ✅ Review created for order $orderId');
    return ReviewModel.fromJson(response['result'] as Map<String, dynamic>);
  }
}
