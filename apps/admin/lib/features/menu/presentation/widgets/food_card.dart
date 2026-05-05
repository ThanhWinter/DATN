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
    super.key,
  });

  final FoodModel food;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManageOptions;

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = food.isAvailable;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvailable
              ? AppColors.emerald.withValues(alpha: 0.15)
              : AppColors.grey300.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isAvailable
                ? AppColors.emerald.withValues(alpha: 0.07)
                : AppColors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ── Food Image ──────────────────────────────────────────────────
            _buildImage(isAvailable),
            const SizedBox(width: 14),

            // ── Info ────────────────────────────────────────────────────────
            Expanded(child: _buildInfo()),

            // ── Actions ─────────────────────────────────────────────────────
            _buildActions(isAvailable),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(bool isAvailable) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: food.imageUrl != null
              ? AppNetworkImage(
                  url: food.imageUrl!,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.fastfood_outlined,
                      color: AppColors.emerald, size: 32),
                ),
        ),
        if (!isAvailable)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'HẾT HÀNG',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          food.name,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          food.description ?? 'Không có mô tả',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [AppColors.emeraldDark, AppColors.emeraldLight],
              ).createShader(b),
              child: Text(
                '${food.price.toInt().toVnd()}đ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.emerald.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                food.categoryName,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  color: AppColors.emeraldDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(bool isAvailable) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 0.85,
          child: Switch(
            value: isAvailable,
            onChanged: onToggle,
            activeThumbColor: AppColors.emerald,
            activeTrackColor: AppColors.emerald.withValues(alpha: 0.25),
            inactiveThumbColor: AppColors.grey400,
            inactiveTrackColor: AppColors.grey200,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionBtn(
              icon: Icons.tune_rounded,
              color: AppColors.emerald,
              tooltip: 'Tuỳ chọn',
              onTap: onManageOptions,
            ),
            _actionBtn(
              icon: Icons.edit_outlined,
              color: AppColors.grey600,
              tooltip: 'Chỉnh sửa',
              onTap: onEdit,
            ),
            _actionBtn(
              icon: Icons.delete_outline_rounded,
              color: AppColors.errorRed,
              tooltip: 'Xoá món',
              onTap: onDelete,
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        icon: Icon(icon, size: 17, color: color),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        tooltip: tooltip,
      ),
    );
  }
}
