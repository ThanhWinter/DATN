import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../interactions/data/models/interaction_models.dart';
import '../../../interactions/data/repositories/interaction_repository.dart';

class AllReviewsSheet extends StatefulWidget {
  final int foodId;
  final String foodName;

  const AllReviewsSheet({
    super.key,
    required this.foodId,
    required this.foodName,
  });

  @override
  State<AllReviewsSheet> createState() => _AllReviewsSheetState();
}

class _AllReviewsSheetState extends State<AllReviewsSheet> {
  List<ReviewModel>? _reviews;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final repo = Get.find<InteractionRepository>();
    final list = await repo.getFoodReviews(widget.foodId, size: 50);
    if (mounted) {
      setState(() {
        _reviews = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.grey200)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 40), // spacer for symmetry
                Expanded(
                  child: Text(
                    'Đánh giá ${widget.foodName}',
                    style: AppTextStyles.h3,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryOrange),
                  )
                : (_reviews == null || _reviews!.isEmpty)
                    ? Center(
                        child: Text(
                          'Chưa có đánh giá nào cho món này.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reviews!.length,
                        separatorBuilder: (_, __) => const Divider(height: 24, color: AppColors.grey200),
                        itemBuilder: (context, index) {
                          final review = _reviews![index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      review.userFullName.isNotEmpty
                                          ? review.userFullName[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: AppColors.primaryOrange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.userFullName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        Row(
                                          children: List.generate(5, (i) {
                                            return Icon(
                                              Icons.star_rounded,
                                              size: 14,
                                              color: i < review.rating
                                                  ? AppColors.accentGold
                                                  : AppColors.grey300,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                              if (review.comment != null && review.comment!.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  review.comment!,
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
