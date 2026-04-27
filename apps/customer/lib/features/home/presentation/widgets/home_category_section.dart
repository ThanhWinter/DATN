import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeCategorySection extends GetView<HomeController> {
  const HomeCategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Obx(() {
        final selectedId = controller.selectedCategoryId.value;
        return SizedBox(
          height: 96,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            // +1 cho chip "Tất cả"
            itemCount: controller.categories.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 4),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _CategoryTile(
                  name: 'Tất cả',
                  imageUrl: null,
                  isSelected: selectedId == null,
                  onTap: () => controller.selectCategory(null),
                );
              }
              final cat = controller.categories[index - 1];
              return _CategoryTile(
                name: cat.name,
                imageUrl: cat.imageUrl,
                isSelected: selectedId == cat.id,
                onTap: () => controller.selectCategory(cat.id),
              );
            },
          ),
        );
      }),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
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
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.primaryOrange, width: 2.5)
                    : null,
                color: AppColors.grey100,
              ),
              child: ClipOval(
                child: imageUrl != null
                    ? AppNetworkImage(
                        url: imageUrl!,
                        fit: BoxFit.cover,
                        memCacheWidth: 60,
                        memCacheHeight: 60,
                        errorWidget: const Icon(
                          Icons.fastfood_rounded,
                          color: AppColors.primaryOrange,
                          size: 28,
                        ),
                      )
                    : const Icon(
                        Icons.fastfood_rounded,
                        color: AppColors.primaryOrange,
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10,
                color:
                    isSelected ? AppColors.primaryOrange : AppColors.textDark,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
