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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isFiltered)
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 4),
              child: TextButton.icon(
                onPressed: controller.clearFilters,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.emerald,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, isFiltered ? 0 : 10, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: _Pill(
                    icon: Icons.restaurant_menu_rounded,
                    value: '${controller.totalFoodCount.value}',
                    label: 'tổng',
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Pill(
                    icon: Icons.check_circle_outline_rounded,
                    value: '${controller.availableFoodCount.value}',
                    label: 'bán',
                    color: AppColors.emeraldDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Pill(
                    icon: Icons.remove_circle_outline_rounded,
                    value: '${controller.unavailableFoodCount.value}',
                    label: 'hết',
                    color: AppColors.errorRed,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  height: 1.1,
                ),
              ),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
