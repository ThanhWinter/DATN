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

  Future<void> deleteReview(int id) async {
    try {
      await _repository.deleteReview(id);
      reviews.removeWhere((r) => r.id == id);
      isEmpty.value = reviews.isEmpty;
      dev.log('[REVIEW/VM] ✅ Review $id deleted');
      Get.snackbar('Đã xoá', 'Đánh giá đã được xoá.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      dev.log('[REVIEW/VM] ❌ deleteReview error: $e');
      Get.snackbar('Lỗi', 'Không thể xoá đánh giá.', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
