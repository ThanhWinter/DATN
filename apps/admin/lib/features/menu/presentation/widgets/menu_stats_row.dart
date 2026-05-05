import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../controllers/menu_controller.dart';

/// Thống kê tính trên cache client ([MenuController] master list).
class MenuStatsRow extends GetView<MenuController> {
  const MenuStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _StatItem(
                label: 'Tổng số món',
                value: '${controller.totalFoodCount.value}',
                color: AppColors.primaryOrange,
              ),
              const SizedBox(width: 12),
              _StatItem(
                label: 'Đang bán',
                value: '${controller.availableFoodCount.value}',
                color: AppColors.successGreen,
              ),
              const SizedBox(width: 12),
              _StatItem(
                label: 'Hết hàng',
                value: '${controller.unavailableFoodCount.value}',
                color: AppColors.errorRed,
              ),
            ],
          ),
        ));
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.h3.copyWith(color: color, fontSize: 18)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }
}
