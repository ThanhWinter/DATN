import "package:core_ui/core_ui.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

import "../controllers/home_controller.dart";
import "category_filter_chip.dart";

class HomeCategorySection extends GetView<HomeController> {
  const HomeCategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grey100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Obx(() {
        // Đọc giá trị synchronously để GetX đăng ký callback
        final currentSlug = controller.selectedCategorySlug.value;
        return SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: controller.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = controller.categories[index];
              return CategoryFilterChip(
                item: cat,
                isSelected: currentSlug == cat.slug,
                onTap: () => controller.selectCategory(cat.slug),
              );
            },
          ),
        );
      }),
    );
  }
}

class CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const CategoryHeaderDelegate({required this.child});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      elevation: shrinkOffset > 0 ? 2 : 0,
      color: AppColors.grey100,
      child: child,
    );
  }

  @override
  bool shouldRebuild(CategoryHeaderDelegate oldDelegate) =>
      oldDelegate.child != child;
}
