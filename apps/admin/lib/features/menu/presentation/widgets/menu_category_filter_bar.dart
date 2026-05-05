import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../data/models/category_model.dart';
import '../controllers/menu_controller.dart';
import 'edit_category_sheet.dart';

class MenuCategoryFilterBar extends GetView<MenuController> {
  const MenuCategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: AppColors.mintBg,
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          width: 22,
                          height: 22,
                          fit: BoxFit.cover,
                        ),
                      )
                    : CircleAvatar(
                        radius: 11,
                        backgroundColor: isSelected
                            ? AppColors.white.withValues(alpha: 0.35)
                            : AppColors.emerald.withValues(alpha: 0.12),
                        child: Icon(
                          Icons.fastfood_rounded,
                          size: 12,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.emerald,
                        ),
                      );
              }

              final chip = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InputChip(
                  avatar: avatar,
                  label: Text(isAll ? 'Tất cả' : cat!.name),
                  selected: isSelected,
                  onSelected: (_) =>
                      controller.selectCategory(isAll ? null : cat?.id),
                  onDeleted: !isAll
                      ? () => _confirmDelete(context, cat!.id, cat.name)
                      : null,
                  deleteIcon: Icon(
                    Icons.cancel_rounded,
                    size: 15,
                    color: isSelected
                        ? AppColors.white.withValues(alpha: 0.8)
                        : AppColors.grey400,
                  ),
                  selectedColor: AppColors.emerald,
                  checkmarkColor: AppColors.white,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textGrey,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.normal,
                  ),
                  backgroundColor: AppColors.white.withValues(alpha: 0.75),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.emerald
                          : AppColors.emerald.withValues(alpha: 0.15),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  showCheckmark: false,
                  elevation: 0,
                  pressElevation: 0,
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
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.category_outlined,
                  color: AppColors.errorRed, size: 18),
            ),
            const SizedBox(width: 12),
            Text('Xoá danh mục',
                style: AppTextStyles.h3.copyWith(color: AppColors.textDark)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textGrey,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Xoá danh mục '),
              TextSpan(
                text: '"$name"',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(
                  text: '?\n\nCác món ăn trong danh mục này sẽ không bị xoá.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Huỷ',
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textGrey, fontWeight: FontWeight.w600)),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.errorRed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () {
                controller.deleteCategory(id);
                Get.back();
              },
              child: Text('Xoá ngay',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
