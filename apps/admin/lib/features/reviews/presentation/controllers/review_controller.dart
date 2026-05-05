import 'dart:developer' as dev;

import 'package:get/get.dart';

import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';

class AdminReviewController extends GetxController {
  AdminReviewController(this._repository);

  final ReviewRepository _repository;

  final reviews = <AdminReviewModel>[].obs;
  final isLoading = false.obs;
  final isEmpty = true.obs; // Rule #2
  final error = Rxn<Object>();

  @override
  void onInit() {
    super.onInit();
    loadReviews();
  }

  Future<void> loadReviews() async {
    try {
      isLoading.value = true;
      error.value = null;
      final list = await _repository.fetchReviews();
      reviews.assignAll(list);
      isEmpty.value = list.isEmpty;
      dev.log('[REVIEW/VM] ✅ Loaded ${list.length} reviews');
    } catch (e) {
      dev.log('[REVIEW/VM] ❌ loadReviews error: $e');
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }
}
