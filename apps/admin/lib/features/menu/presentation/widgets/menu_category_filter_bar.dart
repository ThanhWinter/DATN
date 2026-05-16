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
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                const Text(
                  'Danh mục',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${cats.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emeraldDark,
                    ),
                  ),
                ),
                const Spacer(),
                if (controller.selectedCategoryId.value != null)
                  GestureDetector(
                    onTap: controller.clearFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.emerald.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.filter_alt_off_rounded,
                              size: 13, color: AppColors.emerald),
                          SizedBox(width: 4),
                          Text(
                            'Bỏ lọc',
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
            ),
            const SizedBox(height: 14),
            // ── Grid ────────────────────────────────────────────────────────
            if (cats.isEmpty)
              _EmptyState()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: cats.length,
                itemBuilder: (_, i) {
                  final cat = cats[i];
                  final isSelected =
                      controller.selectedCategoryId.value == cat.id;
                  return _CategoryCard(
                    category: cat,
                    isSelected: isSelected,
                    foodCount: controller.categoryFoodCount(cat.id),
                    availableCount:
                        controller.categoryAvailableFoodCount(cat.id),
                    onTap: () => _openDetail(context, cat),
                    onFilter: () => controller.openFoodsForCategory(cat.id),
                    onEdit: () => _openEdit(cat),
                    onDelete: () =>
                        _confirmDelete(context, cat.id, cat.name),
                  );
                },
              ),
          ],
        ),
      );
    });
  }

  Future<void> _openDetail(BuildContext context, CategoryModel cat) async {
    CategoryModel detail;
    try {
      detail = await controller.getCategoryDetail(cat.id);
    } catch (_) {
      detail = cat;
    }
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.56,
        minChildSize: 0.42,
        maxChildSize: 0.94,
        expand: false,
        builder: (_, scrollController) => _CategoryDetailSheet(
          category: detail,
          scrollController: scrollController,
          foodCount: controller.categoryFoodCount(detail.id),
          availableCount: controller.categoryAvailableFoodCount(detail.id),
          onEdit: () {
            Get.back();
            _openEdit(detail);
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

  void _openEdit(CategoryModel cat) {
    Get.bottomSheet(
      EditCategorySheet(category: cat),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xoá danh mục',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827)),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
                fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
            children: [
              const TextSpan(text: 'Xoá danh mục '),
              TextSpan(
                text: '"$name"',
                style: const TextStyle(
                    color: Color(0xFF111827), fontWeight: FontWeight.w600),
              ),
              const TextSpan(
                  text: '? Backend sẽ từ chối nếu danh mục còn món ăn.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Huỷ',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              Future.microtask(
                  () => Get.find<MenuController>().deleteCategory(id));
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}

// ─── Category Grid Card ───────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.foodCount,
    required this.availableCount,
    required this.onTap,
    required this.onFilter,
    required this.onEdit,
    required this.onDelete,
  });

  final CategoryModel category;
  final bool isSelected;
  final int foodCount;
  final int availableCount;
  final VoidCallback onTap;
  final VoidCallback onFilter;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected ? AppColors.emerald : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.emerald.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ───────────────────────────────────────────────
            Expanded(
              flex: 54,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(13)),
                    child: category.imageUrl != null
                        ? AppNetworkImage(
                            url: category.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: isSelected
                                ? AppColors.emerald.withValues(alpha: 0.08)
                                : const Color(0xFFF3F4F6),
                            child: Icon(
                              Icons.category_rounded,
                              size: 38,
                              color: isSelected
                                  ? AppColors.emerald
                                  : const Color(0xFFD1D5DB),
                            ),
                          ),
                  ),
                  // Food count badge — top left
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.50),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$foodCount món',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Selected checkmark — top right
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.emerald,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emerald.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            // ── Content area ─────────────────────────────────────────────
            Expanded(
              flex: 46,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$availableCount đang bán',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        // Filter pill button
                        GestureDetector(
                          onTap: onFilter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.emerald
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isSelected ? 'Đang lọc' : 'Lọc món',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // More menu
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.more_horiz_rounded,
                                size: 18, color: Color(0xFF9CA3AF)),
                            onSelected: (v) {
                              if (v == 'edit') onEdit();
                              if (v == 'delete') onDelete();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                height: 40,
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined,
                                        size: 15,
                                        color: Color(0xFF374151)),
                                    SizedBox(width: 10),
                                    Text('Sửa',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF374151))),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                height: 40,
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded,
                                        size: 15,
                                        color: Color(0xFFDC2626)),
                                    SizedBox(width: 10),
                                    Text('Xoá',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFDC2626))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.category_outlined,
                size: 28, color: Color(0xFFD1D5DB)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Chưa có danh mục nào',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nhấn + để tạo danh mục đầu tiên',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

// ─── Category detail sheet ────────────────────────────────────────────────────

class _CategoryDetailSheet extends StatelessWidget {
  const _CategoryDetailSheet({
    required this.category,
    required this.scrollController,
    required this.foodCount,
    required this.availableCount,
    required this.onEdit,
    required this.onDelete,
  });

  final CategoryModel category;
  final ScrollController scrollController;
  final int foodCount;
  final int availableCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Material(
        color: Colors.white,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chi tiết danh mục',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827)),
              ),
              const SizedBox(height: 14),
              _DetailImage(
                  imageUrl: category.imageUrl,
                  fallbackIcon: Icons.category_rounded),
              const SizedBox(height: 14),
              Text(
                category.name,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827)),
              ),
              const SizedBox(height: 6),
              Text(
                category.description?.trim().isNotEmpty == true
                    ? category.description!.trim()
                    : 'Chưa có mô tả',
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(label: '$foodCount món'),
                  const SizedBox(width: 8),
                  _InfoChip(label: '$availableCount đang bán'),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Sửa danh mục'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Xoá danh mục'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailImage extends StatelessWidget {
  const _DetailImage(
      {required this.imageUrl, required this.fallbackIcon});

  final String? imageUrl;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: imageUrl != null
          ? AppNetworkImage(
              url: imageUrl!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover)
          : Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFFF3F4F6),
              child: Icon(fallbackIcon,
                  size: 40, color: const Color(0xFFD1D5DB)),
            ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.emeraldDark),
      ),
    );
  }
}
