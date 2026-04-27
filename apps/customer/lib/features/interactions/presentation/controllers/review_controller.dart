import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositories/interaction_repository.dart';

class ReviewController extends GetxController {
  final InteractionRepository _repository;

  ReviewController(this._repository);

  final rating = 0.obs;
  final canSubmit = false.obs; // Rule #2 — explicit RxBool
  final isLoading = false.obs;
  final commentController = TextEditingController();

  late final String _orderId;

  @override
  void onInit() {
    super.onInit();
    _orderId = Get.arguments as String? ?? '';
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  void setRating(int r) {
    rating.value = r;
    canSubmit.value = r > 0;
  }

  Future<void> submitReview() async {
    if (!canSubmit.value) return;

    try {
      isLoading.value = true;
      await _repository.createReview(
        orderId: _orderId,
        rating: rating.value,
        comment: commentController.text.trim().isNotEmpty
            ? commentController.text.trim()
            : null,
      );
      dev.log('[REVIEW] ✅ Review submitted for order: $_orderId');
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back();
      Get.snackbar(
        'Cảm ơn bạn!',
        'Đánh giá của bạn đã được ghi nhận.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
    } on ApiException catch (e) {
      dev.log('[REVIEW] ❌ ApiException: ${e.statusCode} ${e.message}');
      Get.snackbar(
        'Lỗi',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      dev.log('[REVIEW] ❌ Unexpected error: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể gửi đánh giá. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
