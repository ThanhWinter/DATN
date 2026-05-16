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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEBEBEB)),
            ),
            child: Row(
              children: [
                _StatCell(
                  label: 'Tổng',
                  value: '${controller.totalFoodCount.value}',
                  color: AppColors.emeraldDark,
                ),
                const _VerticalDivider(),
                _StatCell(
                  label: 'Đang bán',
                  value: '${controller.availableFoodCount.value}',
                  color: const Color(0xFF16A34A),
                ),
                const _VerticalDivider(),
                _StatCell(
                  label: 'Tạm ẩn',
                  value: '${controller.unavailableFoodCount.value}',
                  color: const Color(0xFFDC2626),
                ),
              ],
            ),
          ),
          if (isFiltered)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 6),
              child: GestureDetector(
                onTap: controller.clearFilters,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_alt_off_rounded, size: 13, color: AppColors.emerald),
                    const SizedBox(width: 4),
                    Text(
                      'Bỏ lọc danh mục',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: const Color(0xFFEBEBEB));
  }
}
