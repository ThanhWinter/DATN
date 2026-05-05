import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../data/models/category_model.dart';
import '../controllers/menu_controller.dart';
import 'edit_category_sheet.dart';

/// Chip lọc danh mục + avatar (ảnh decode đủ DPR qua [AppNetworkImage]).
class MenuCategoryFilterBar extends GetView<MenuController> {
  const MenuCategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      color: AppColors.white,
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: controller.categories.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final cat = isAll ? null : controller.categories[index - 1];
              final isSelected = isAll
                  ? controller.selectedCategoryId.value == null
                  : controller.selectedCategoryId.value == cat?.id;

              Widget? avatar;
              if (!isAll) {
                final url = cat!.imageUrl;
                avatar = url != null
                    ? ClipOval(
                        child: AppNetworkImage(
                          url: url,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                        ),
                      )
                    : CircleAvatar(
                        radius: 12,
                        backgroundColor: isSelected
                            ? AppColors.white.withValues(alpha: 0.3)
                            : AppColors.grey300,
                        child: Icon(Icons.fastfood,
                            size: 13,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.grey600),
                      );
              }
              final chip = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InputChip(
                  avatar: avatar,
                  label: Text(isAll ? 'Tất cả' : cat!.name),
                  selected: isSelected,
                  onSelected: (_) =>
                      controller.selectCategory(isAll ? null : cat?.id),
                  onDeleted: !isAll
                      ? () => _confirmDelete(context, cat!.id, cat.name)
                      : null,
                  deleteIcon: Icon(Icons.cancel,
                      size: 16,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.grey400),
                  selectedColor: AppColors.primaryOrange,
                  checkmarkColor: AppColors.white,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textGrey,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: AppColors.grey100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryOrange
                          : Colors.transparent,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
              if (isAll) return chip;
              return GestureDetector(
                onLongPress: () => _openEditCategory(cat!),
                child: chip,
              );
            },
          )),
    );
  }

  void _openEditCategory(CategoryModel cat) {
    Get.bottomSheet(
      EditCategorySheet(category: cat),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xoá danh mục', style: AppTextStyles.h3),
        content: Text(
            'Bạn chắc chắn muốn xoá danh mục "$name"?\n(Lưu ý: Các món ăn trong danh mục này sẽ không bị xoá)'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Huỷ',
                style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteCategory(id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xoá ngay'),
          ),
        ],
      ),
    );
  }
}
