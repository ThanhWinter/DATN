import "package:core_ui/core_ui.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

import "../controllers/home_controller.dart";
import "food_detail_sheet.dart";
import "food_item_card.dart";

class HomeMenuHeader extends GetView<HomeController> {
  const HomeMenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Obx(
        () => Row(
          children: [
            const Text("Thực đơn", style: AppTextStyles.h3),
            const SizedBox(width: 8),
            Text(
              "(${controller.filteredCount.value} món)",
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeMenuGrid extends GetView<HomeController> {
  const HomeMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isFilteredEmpty.value) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.no_food_outlined,
                      size: 48, color: AppColors.grey300),
                  SizedBox(height: 12),
                  Text(
                    "Không có món nào trong danh mục này",
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = controller.filteredFoodItems[index];
              return FoodItemCard(
                item: item,
                onAdd: item.isAvailable
                    ? () {
                        controller.addToCart(item);
                        Get.snackbar(
                          'Đã thêm vào giỏ',
                          item.name,
                          snackPosition: SnackPosition.TOP,
                          duration: const Duration(seconds: 1),
                        );
                      }
                    : null,
                onTap: () => FoodDetailSheet.show(item),
              );
            },
            childCount: controller.filteredCount.value,
          ),
        ),
      );
    });
  }
}
