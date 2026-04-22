import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../controllers/menu_controller.dart';
import '../widgets/add_category_sheet.dart';
import '../widgets/add_food_sheet.dart';
import '../widgets/food_card.dart';

class MenuView extends GetView<MenuController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Thực đơn', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Thêm danh mục',
            onPressed: () => Get.bottomSheet(
              const AddCategorySheet(),
              backgroundColor: AppColors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              isScrollControlled: true,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm món'),
        onPressed: () => Get.bottomSheet(
          const AddFoodSheet(),
          backgroundColor: AppColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          isScrollControlled: true,
        ),
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onSuccess: () => Obx(() => Column(
          children: [
            _CategoryFilter(),
            Expanded(
              child: controller.filteredFoods.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.restaurant_menu_outlined,
                      message: 'Không có món ăn nào',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: controller.filteredFoods.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final food = controller.filteredFoods[i];
                        return FoodCard(
                          food: food,
                          onToggle: (_) => controller.toggleAvailability(food),
                        );
                      },
                    ),
            ),
          ],
        )),
      ),
    );
  }
}

class _CategoryFilter extends GetView<MenuController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Obx(() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _Chip(
              label: 'Tất cả',
              selected: controller.selectedCategoryId.value == null,
              onTap: () => controller.selectCategory(null),
            ),
            ...controller.categories.map((cat) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _Chip(
                label: cat.name,
                selected: controller.selectedCategoryId.value == cat.id,
                onTap: () => controller.selectCategory(cat.id),
                onDelete: () => _confirmDelete(context, cat.id, cat.name),
              ),
            )),
          ],
        ),
      )),
    );
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá danh mục'),
        content: Text('Bạn muốn xoá danh mục "$name"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Huỷ')),
          TextButton(
            onPressed: () {
              controller.deleteCategory(id);
              Get.back();
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.onDelete,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryOrange : AppColors.grey100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? AppColors.white : AppColors.textGrey,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: selected ? AppColors.white : AppColors.grey600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
