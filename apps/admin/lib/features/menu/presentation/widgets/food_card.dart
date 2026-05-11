import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../data/models/food_model.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    required this.food,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onManageOptions,
    required this.onView,
    super.key,
  });

  final FoodModel food;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManageOptions;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final isAvailable = food.isAvailable;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isAvailable
                  ? AppColors.emerald.withValues(alpha: 0.22)
                  : AppColors.grey300,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FoodImage(food: food, isAvailable: isAvailable),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _FoodInfo(food: food)),
                          const SizedBox(width: 8),
                          _StatusButton(
                            isAvailable: isAvailable,
                            onChanged: () => onToggle(!isAvailable),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _ActionChipButton(
                            icon: Icons.tune_rounded,
                            label: 'Tuỳ chọn',
                            color: AppColors.emerald,
                            onTap: onManageOptions,
                          ),
                          const SizedBox(width: 6),
                          _ActionChipButton(
                            icon: Icons.edit_outlined,
                            label: 'Sửa',
                            color: AppColors.grey600,
                            onTap: onEdit,
                          ),
                          const SizedBox(width: 6),
                          _ActionChipButton(
                            icon: Icons.delete_outline_rounded,
                            label: 'Xoá',
                            color: AppColors.errorRed,
                            onTap: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodImage extends StatelessWidget {
  const _FoodImage({required this.food, required this.isAvailable});

  final FoodModel food;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: food.imageUrl != null
              ? AppNetworkImage(
                  url: food.imageUrl!,
                  width: 74,
                  height: 74,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 74,
                  height: 74,
                  color: AppColors.grey100,
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: AppColors.grey600,
                    size: 28,
                  ),
                ),
        ),
        if (!isAvailable)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.48),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'TẠM ẨN',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FoodInfo extends StatelessWidget {
  const _FoodInfo({required this.food});

  final FoodModel food;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          food.name,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          food.description?.trim().isNotEmpty == true
              ? food.description!.trim()
              : 'Không có mô tả',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textGrey,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 5,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${food.price.toInt().toVnd()}đ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.emeraldDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            _CategoryTag(label: food.categoryName),
          ],
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({required this.isAvailable, required this.onChanged});

  final bool isAvailable;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isAvailable ? 'Ngừng bán món này' : 'Mở bán món này',
      child: InkWell(
        onTap: onChanged,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: isAvailable
                ? AppColors.emerald.withValues(alpha: 0.10)
                : AppColors.grey100,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isAvailable
                  ? AppColors.emerald.withValues(alpha: 0.30)
                  : AppColors.grey300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAvailable
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
                size: 15,
                color: isAvailable ? AppColors.emeraldDark : AppColors.grey600,
              ),
              const SizedBox(width: 4),
              Text(
                isAvailable ? 'Ngừng bán' : 'Mở bán',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color:
                      isAvailable ? AppColors.emeraldDark : AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.075),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 10,
          color: AppColors.textGrey,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
