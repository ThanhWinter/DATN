import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/review_controller.dart';

class ReviewView extends GetView<ReviewController> {
  const ReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Đánh giá đơn hàng', style: AppTextStyles.h2),
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            _FoodSelector(controller: controller),
            const SizedBox(height: 24),
            const Text('Bạn cảm thấy thế nào?', style: AppTextStyles.h3),
            const SizedBox(height: 24),
            _StarRating(controller: controller),
            const SizedBox(height: 32),
            _CommentField(controller: controller),
            const SizedBox(height: 32),
            _SubmitButton(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _FoodSelector extends StatelessWidget {
  const _FoodSelector({required this.controller});

  final ReviewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.items;
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chọn món cần đánh giá', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          ...items.map((item) {
            final isSelected = controller.selectedFoodId.value == item.foodId;
            return GestureDetector(
              onTap: () => controller.selectFood(item.foodId, item.foodName),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryOrange.withValues(alpha: 0.12)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryOrange : AppColors.grey300,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: isSelected
                          ? AppColors.primaryOrange
                          : AppColors.grey400,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.foodName}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected
                              ? AppColors.primaryOrange
                              : AppColors.textDark,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.controller});

  final ReviewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final star = i + 1;
            return GestureDetector(
              onTap: () => controller.setRating(star),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  star <= controller.rating.value
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 48,
                  color: star <= controller.rating.value
                      ? AppColors.primaryOrange
                      : AppColors.grey300,
                ),
              ),
            );
          }),
        ));
  }
}

class _CommentField extends StatelessWidget {
  const _CommentField({required this.controller});

  final ReviewController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controller.commentController,
        maxLines: 4,
        maxLength: 300,
        decoration: InputDecoration(
          hintText: 'Nhận xét của bạn (tùy chọn)...',
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.grey400),
          border: InputBorder.none,
          counterStyle:
              AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
        ),
        style: AppTextStyles.bodyMedium,
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.controller});

  final ReviewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.canSubmit.value && !controller.isLoading.value
                ? controller.submitReview
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              disabledBackgroundColor: AppColors.grey300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.white,
                    ),
                  )
                : const Text(
                    'Gửi đánh giá',
                    style: AppTextStyles.bodyLarge,
                  ),
          ),
        ));
  }
}
