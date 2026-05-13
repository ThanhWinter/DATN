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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
            child: Row(
              children: [
                Text(
                  'Danh mục',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 6),
                _CountBadge(value: cats.length.toString()),
              ],
            ),
          ),
          if (cats.isEmpty)
            const _EmptyCategoryCard()
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final cat in cats) ...[
                    _CategoryAdminCard(
                      category: cat,
                      isSelected: controller.selectedCategoryId.value == cat.id,
                      foodCount: controller.categoryFoodCount(cat.id),
                      availableFoodCount:
                          controller.categoryAvailableFoodCount(cat.id),
                      onTap: () => _openCategoryDetail(context, cat),
                      onSelect: () => controller.openFoodsForCategory(cat.id),
                      onEdit: () => _openEditCategory(cat),
                      onDelete: () => _confirmDelete(context, cat.id, cat.name),
                    ),
                    if (cat != cats.last) const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
        ],
      );
    });
  }

  Future<void> _openCategoryDetail(
      BuildContext context, CategoryModel cat) async {
    final detail = await _loadLatestCategory(cat);
    if (detail == null) return;
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.56,
        minChildSize: 0.42,
        maxChildSize: 0.94,
        expand: false,
        builder: (context, scrollController) => _CategoryDetailSheet(
          category: detail,
          scrollController: scrollController,
          foodCount: controller.categoryFoodCount(detail.id),
          availableFoodCount: controller.categoryAvailableFoodCount(detail.id),
          onEdit: () {
            Get.back();
            _openEditCategory(detail);
          },
          onDelete: () {
            Get.back();
            _confirmDelete(context, detail.id, detail.name);
          },
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Future<CategoryModel?> _loadLatestCategory(CategoryModel fallback) async {
    try {
      return await controller.getCategoryDetail(fallback.id);
    } catch (_) {
      Get.snackbar(
        'Không tải được chi tiết mới nhất',
        'Đang hiển thị dữ liệu danh sách hiện có.',
        backgroundColor: AppColors.warningYellow,
        colorText: AppColors.white,
      );
      return fallback;
    }
  }

  void _openEditCategory(CategoryModel cat) {
    Get.bottomSheet(
      EditCategorySheet(category: cat),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.errorRed,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Xoá danh mục',
              style: AppTextStyles.h3.copyWith(color: AppColors.textDark),
            ),
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
                text:
                    '?\n\nBackend sẽ từ chối nếu danh mục vẫn còn món ăn liên kết.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Huỷ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.errorRed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () {
                Get.back();
                Future.microtask(() => controller.deleteCategory(id));
              },
              child: Text(
                'Xoá ngay',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryAdminCard extends StatelessWidget {
  const _CategoryAdminCard({
    required this.category,
    required this.isSelected,
    required this.foodCount,
    required this.availableFoodCount,
    required this.onTap,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final CategoryModel category;
  final bool isSelected;
  final int foodCount;
  final int availableFoodCount;
  final VoidCallback onTap;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.imageUrl;
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.emerald
                  : AppColors.grey300.withValues(alpha: 0.75),
              width: isSelected ? 1.6 : 1,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CategoryThumb(imageUrl: imageUrl, isSelected: isSelected),
                  const SizedBox(width: 10),
                  Expanded(child: _CategorySummary(category: category)),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 17,
                      color: AppColors.emerald,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _MetricPill(
                    icon: Icons.restaurant_menu_rounded,
                    label: '$foodCount món',
                  ),
                  const SizedBox(width: 6),
                  _MetricPill(
                    icon: Icons.check_circle_outline_rounded,
                    label: '$availableFoodCount bán',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _CategoryActionButton(
                      icon: isSelected
                          ? Icons.check_circle_outline_rounded
                          : Icons.filter_alt_outlined,
                      label: isSelected ? 'Đang lọc' : 'Lọc món',
                      color: isSelected
                          ? AppColors.emeraldDark
                          : AppColors.grey600,
                      onTap: onSelect,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CategoryActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Sửa',
                      color: AppColors.grey600,
                      onTap: onEdit,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CategoryActionButton(
                      icon: Icons.delete_outline_rounded,
                      label: 'Xoá',
                      color: AppColors.errorRed,
                      onTap: onDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryThumb extends StatelessWidget {
  const _CategoryThumb({required this.imageUrl, required this.isSelected});

  final String? imageUrl;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl != null
          ? AppNetworkImage(
              url: imageUrl!,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
            )
          : Container(
              width: 46,
              height: 46,
              color: isSelected
                  ? AppColors.emerald.withValues(alpha: 0.12)
                  : AppColors.grey100,
              child: Icon(
                Icons.category_rounded,
                size: 22,
                color: isSelected ? AppColors.emerald : AppColors.grey600,
              ),
            ),
    );
  }
}

class _CategorySummary extends StatelessWidget {
  const _CategorySummary({required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          category.description?.trim().isNotEmpty == true
              ? category.description!.trim()
              : 'Chưa có mô tả',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textGrey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _CategoryDetailSheet extends StatelessWidget {
  const _CategoryDetailSheet({
    required this.category,
    required this.scrollController,
    required this.foodCount,
    required this.availableFoodCount,
    required this.onEdit,
    required this.onDelete,
  });

  final CategoryModel category;
  final ScrollController scrollController;
  final int foodCount;
  final int availableFoodCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Material(
        color: AppColors.white,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + keyboardHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Chi tiết danh mục', style: AppTextStyles.h3),
              const SizedBox(height: 14),
              _DetailImage(
                imageUrl: category.imageUrl,
                caption: category.name,
                fallbackIcon: Icons.category_rounded,
              ),
              const SizedBox(height: 16),
              Text(
                category.name,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.description?.trim().isNotEmpty == true
                    ? category.description!.trim()
                    : 'Chưa có mô tả',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textGrey,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricPill(
                    icon: Icons.restaurant_menu_rounded,
                    label: '$foodCount món',
                  ),
                  _MetricPill(
                    icon: Icons.check_circle_outline_rounded,
                    label: '$availableFoodCount đang bán',
                  ),
                  _MetricPill(
                      icon: Icons.tag_rounded, label: 'ID ${category.id}'),
                ],
              ),
              const SizedBox(height: 18),
              _DetailInfoBlock(
                title: 'Mô tả',
                rows: [
                  ('Mã danh mục', '#${category.id}'),
                  ('Tên danh mục', category.name),
                  ('Số món', '$foodCount món'),
                  ('Đang bán', '$availableFoodCount món'),
                  (
                    'Mô tả',
                    category.description?.trim().isNotEmpty == true
                        ? category.description!.trim()
                        : 'Chưa có mô tả'
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _GreenSquareButton(
                      label: 'Xoá',
                      icon: Icons.delete_outline_rounded,
                      onTap: onDelete,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GreenSquareButton(
                      label: 'Sửa danh mục',
                      icon: Icons.edit_outlined,
                      onTap: onEdit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailImage extends StatelessWidget {
  const _DetailImage({
    required this.imageUrl,
    required this.caption,
    required this.fallbackIcon,
  });

  final String? imageUrl;
  final String caption;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          imageUrl == null ? null : () => _showImagePreview(imageUrl!, caption),
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: imageUrl != null
            ? AppNetworkImage(
                url: imageUrl!,
                height: 176,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            : Container(
                height: 176,
                width: double.infinity,
                color: AppColors.emerald.withValues(alpha: 0.08),
                child: Icon(fallbackIcon, size: 46, color: AppColors.emerald),
              ),
      ),
    );
  }

  void _showImagePreview(String url, String caption) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: AppColors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: AppNetworkImage(url: url, fit: BoxFit.contain),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  color: AppColors.black,
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GreenSquareButton extends StatelessWidget {
  const _GreenSquareButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        backgroundColor: AppColors.emerald,
        foregroundColor: AppColors.white,
        minimumSize: const Size.fromHeight(44),
        shape: const RoundedRectangleBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _DetailInfoBlock extends StatelessWidget {
  const _DetailInfoBlock({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mintBg,
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.emeraldDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (final row in rows) ...[
            _DetailInfoRow(label: row.$1, value: row.$2),
            if (row != rows.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textGrey,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryActionButton extends StatelessWidget {
  const _CategoryActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.emeraldDark),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.emeraldDark,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.emerald,
        ),
      ),
    );
  }
}

class _EmptyCategoryCard extends StatelessWidget {
  const _EmptyCategoryCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey200),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, color: AppColors.grey400, size: 18),
            SizedBox(width: 8),
            Text(
              'Hiện chưa có danh mục nào',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
