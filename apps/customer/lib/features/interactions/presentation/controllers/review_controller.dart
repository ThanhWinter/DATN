import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../orders/data/models/order_item_model.dart';
import '../../data/repositories/interaction_repository.dart';

class ReviewController extends GetxController {
  final InteractionRepository _repository;

  ReviewController(this._repository);

  final rating = 0.obs;
  final canSubmit = false.obs; // Rule #2 — explicit RxBool
  final isLoading = false.obs;
  final commentController = TextEditingController();
  final items = <OrderItemModel>[].obs;
  final selectedFoodId = Rxn<int>();
  final selectedFoodName = ''.obs;

  late final String _orderId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _orderId = args?['orderId'] as String? ?? '';
    items.value = (args?['items'] as List<OrderItemModel>?) ?? [];
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  void selectFood(int foodId, String foodName) {
    selectedFoodId.value = foodId;
    selectedFoodName.value = foodName;
    _updateCanSubmit();
  }

  void setRating(int r) {
    rating.value = r;
    _updateCanSubmit();
  }

  void _updateCanSubmit() {
    canSubmit.value = rating.value > 0 && selectedFoodId.value != null;
  }

  Future<void> submitReview() async {
    final foodId = selectedFoodId.value;
    if (!canSubmit.value || foodId == null) return;

    try {
      isLoading.value = true;
      await _repository.createReview(
        orderId: _orderId,
        foodId: foodId,
        rating: rating.value,
        comment: commentController.text.trim().isNotEmpty
            ? commentController.text.trim()
            : null,
      );
      dev.log('[REVIEW] ✅ Review submitted for order: $_orderId food: $foodId');
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
