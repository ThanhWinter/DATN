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
