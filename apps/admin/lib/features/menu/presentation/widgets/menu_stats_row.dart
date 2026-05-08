import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../controllers/menu_controller.dart';

class MenuStatsRow extends GetView<MenuController> {
  const MenuStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFiltered = controller.isFiltered;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
        child: Row(
          children: [
            _Pill(
              icon: Icons.restaurant_menu_rounded,
              value: '${controller.totalFoodCount.value}',
              label: 'tổng',
              color: AppColors.emerald,
            ),
            const SizedBox(width: 8),
            _Pill(
              icon: Icons.check_circle_outline_rounded,
              value: '${controller.availableFoodCount.value}',
              label: 'bán',
              color: AppColors.emeraldDark,
            ),
            const SizedBox(width: 8),
            _Pill(
              icon: Icons.remove_circle_outline_rounded,
              value: '${controller.unavailableFoodCount.value}',
              label: 'hết',
              color: AppColors.errorRed,
            ),
            const Spacer(),
            if (isFiltered)
              TextButton.icon(
                onPressed: controller.clearFilters,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.emerald,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(Icons.filter_alt_off_rounded, size: 14),
                label: const Text('Xem tất cả'),
              ),
          ],
        ),
      );
    });
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.20), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
