import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/review_model.dart';
import '../controllers/review_controller.dart';

class AdminReviewView extends GetView<AdminReviewController> {
  const AdminReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Quản lý đánh giá', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.loadReviews,
            icon: const Icon(Icons.refresh, color: AppColors.primaryOrange),
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        isEmpty: () => controller.isEmpty.value,
        emptyWidget: const AppEmptyState(
          icon: Icons.star_border_rounded,
          message: 'Chưa có đánh giá nào từ khách hàng',
        ),
        onSuccess: () => Obx(
          () => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ReviewCard(
              review: controller.reviews[i],
              onDelete: () =>
                  _confirmDelete(context, controller.reviews[i]),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminReviewModel review) {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Xoá đánh giá', style: AppTextStyles.h3),
      content: Text(
          'Xoá đánh giá của "${review.userFullName}"?\nHành động này không thể hoàn tác.'),
      actions: [
        TextButton(
          onPressed: Get.back,
          child:
              const Text('Huỷ', style: TextStyle(color: AppColors.textGrey)),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            controller.deleteReview(review.id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.errorRed,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Xoá ngay'),
        ),
      ],
    ));
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.onDelete});

  final AdminReviewModel review;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: user + stars + delete ─────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.15),
                child: Text(
                  review.userFullName.isNotEmpty
                      ? review.userFullName[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userFullName,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text('Đơn: ${review.orderId}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textGrey)),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.errorRed, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Stars ─────────────────────────────────────────────────────
          Row(
            children: List.generate(5, (i) {
              final filled = i < review.rating;
              return Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 20,
                color: filled ? AppColors.accentGold : AppColors.grey300,
              );
            }),
          ),

          // ── Comment ───────────────────────────────────────────────────
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
            ),
          ],

          // ── Date ──────────────────────────────────────────────────────
          const SizedBox(height: 8),
          Text(
            _formatDate(review.createdAt),
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
