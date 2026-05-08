import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomeCategorySection extends GetView<HomeController> {
  const HomeCategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: "Danh mục" + "Xem tất cả" ────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 8, 10),
          child: Row(
            children: [
              const Text(
                'Danh mục',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.allCategories),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
        ),

        // ── Category list ────────────────────────────────────────────────
        SizedBox(
          height: 78,
          child: Obx(() {
            final cats = controller.categories;
            // Đọc selectedCategoryId.value tại đây để Obx theo dõi reactive dependency
            final selectedId = controller.selectedCategoryId.value;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: cats.length,
              itemBuilder: (context, index) {
                final cat = cats[index];
                return _CategoryChip(
                  name: cat.name,
                  imageUrl: cat.imageUrl,
                  isSelected: selectedId == cat.id,
                  onTap: () => controller.selectCategory(cat.id),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.name,
    required this.isSelected,
    required this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dùng Container (không AnimatedContainer) để viền hiện ngay lập tức
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primaryOrange.withValues(alpha: 0.12)
                    : const Color(0xFFF5F5F5),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryOrange
                      : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryOrange.withValues(alpha: 0.30),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: ClipOval(child: _buildIcon()),
            ),
            const SizedBox(height: 5),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryOrange
                    : AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (imageUrl != null) {
      return AppNetworkImage(
        url: imageUrl!,
        fit: BoxFit.cover,
        width: 50,
        height: 50,
        errorWidget: _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: isSelected
          ? AppColors.primaryOrange.withValues(alpha: 0.08)
          : const Color(0xFFF5F5F5),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color:
                isSelected ? AppColors.primaryOrange : AppColors.grey400,
          ),
        ),
      ),
    );
  }
}
