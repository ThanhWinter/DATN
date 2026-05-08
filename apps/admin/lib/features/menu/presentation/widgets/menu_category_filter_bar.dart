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
    return Obx(() {
      final cats = controller.categories;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header: "Danh mục" + count badge + "Xem tất cả" ──────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
            child: Row(
              children: [
                const Text(
                  'Danh mục',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${cats.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.emerald,
                    ),
                  ),
                ),
                const Spacer(),
                // Hiển thị theo quyền backend cho nhân viên
                TextButton(
                  onPressed: () => controller.selectCategory(null),
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
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
          ),

          // ── Category chips ──────────────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: cats.length,
              itemBuilder: (context, index) {
                final cat = cats[index];
                final isSelected =
                    controller.selectedCategoryId.value == cat.id;

                final url = cat.imageUrl;
                final avatar = url != null
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

                final chip = Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InputChip(
                    avatar: avatar,
                    label: Text(cat.name),
                    selected: isSelected,
                    onSelected: (_) => controller.selectCategory(cat.id),
                    onDeleted: () =>
                        _confirmDelete(context, cat.id, cat.name),
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
                      color:
                          isSelected ? AppColors.white : AppColors.textGrey,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.emerald
                            : AppColors.emerald.withValues(alpha: 0.18),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    showCheckmark: false,
                    elevation: 0,
                    pressElevation: 0,
                  ),
                );

                return GestureDetector(
                  onLongPress: () => _openEditCategory(cat),
                  child: chip,
                );
              },
            ),
          ),
        ],
      );
    });
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
