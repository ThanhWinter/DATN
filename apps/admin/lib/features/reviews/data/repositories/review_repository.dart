import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/review_model.dart';

class ReviewRepository {
  ReviewRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<List<AdminReviewModel>> fetchReviews({int page = 0}) async {
    final res = await _apiClient.get(
      '/interactions/reviews',
      query: {'page': page.toString(), 'size': '20'},
    );
    final pageData = res['result'] as Map<String, dynamic>;
    final list = pageData['content'] as List<dynamic>? ?? [];
    dev.log('[REVIEW/REPO] ✅ Loaded ${list.length} reviews');
    return list
        .map((e) => AdminReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteReview(int id) async {
    dev.log('[REVIEW/REPO] Deleting review: $id');
    await _apiClient.delete('/interactions/reviews/$id');
    dev.log('[REVIEW/REPO] ✅ Review $id deleted');
  }
}
