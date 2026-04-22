import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../data/models/food_model.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    required this.food,
    required this.onToggle,
    super.key,
  });

  final FoodModel food;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: food.imageUrl != null
                  ? AppNetworkImage(
                      url: food.imageUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 72,
                      height: 72,
                      color: AppColors.grey200,
                      child: const Icon(Icons.fastfood_outlined, color: AppColors.grey400, size: 32),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 2),
                  Text(
                    food.description ?? '',
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${food.price.toInt().toVnd()}đ',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          food.categoryName,
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: food.isAvailable,
              onChanged: onToggle,
              activeThumbColor: AppColors.primaryOrange,
            ),
          ],
        ),
      ),
    );
  }
}
