import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../data/models/food_model.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    required this.food,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final FoodModel food;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = food.isAvailable;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.6,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 1. Food Image with Status Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: food.imageUrl != null
                        ? AppNetworkImage(
                            url: food.imageUrl!,
                            width: 84,
                            height: 84,
                            fit: BoxFit.cover,
                            memCacheWidth: 84,
                            memCacheHeight: 84,
                          )
                        : Container(
                            width: 84,
                            height: 84,
                            color: AppColors.grey200,
                            child: const Icon(Icons.fastfood_outlined,
                                color: AppColors.grey400, size: 32),
                          ),
                  ),
                  if (!isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'HẾT HÀNG',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // 2. Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: AppTextStyles.labelLarge
                          .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      food.description ?? 'Không có mô tả',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${food.price.toInt().toVnd()}đ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            food.categoryName,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textGrey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Actions
              Column(
                children: [
                  Switch(
                    value: isAvailable,
                    onChanged: onToggle,
                    activeThumbColor: AppColors.primaryOrange,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              size: 18, color: AppColors.grey600),
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          tooltip: 'Chỉnh sửa',
                        ),
                      ),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: AppColors.errorRed),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          tooltip: 'Xoá món',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
