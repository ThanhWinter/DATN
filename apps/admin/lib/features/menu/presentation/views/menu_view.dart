import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';

import '../../data/models/food_model.dart';
import '../controllers/menu_controller.dart';
import '../widgets/add_category_sheet.dart';
import '../widgets/add_food_sheet.dart';
import '../widgets/edit_food_sheet.dart';
import '../widgets/food_card.dart';
import '../widgets/menu_category_filter_bar.dart';
import '../widgets/menu_search_bar.dart';
import '../widgets/option_group_sheet.dart';

class MenuView extends GetView<MenuController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient backdrop: xanh lá nhạt → trắng, chỉ phần trên cùng
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F5E9), // emerald 10% tint
                  Colors.white,
                  Colors.white,
                ],
                stops: [0.0, 0.28, 1.0],
              ),
            ),
          ),
          SnapHelperWidget(
            isLoading: controller.isLoading,
            error: controller.error,
            onRefresh: controller.loadData,
            onSuccess: () => RefreshIndicator(
              onRefresh: controller.loadData,
              color: AppColors.emerald,
              backgroundColor: AppColors.white,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification n) {
                  if (n.metrics.pixels >= n.metrics.maxScrollExtent - 360) {
                    controller.maybeLoadMoreVisibleFoods();
                  }
                  return false;
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragEnd: _handleHorizontalSwipe,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      SliverAppBar(
                        floating: false,
                        pinned: true,
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Manage',
                              style: AppTextStyles.h1.copyWith(
                                fontSize: 26,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (b) => const LinearGradient(
                                colors: [
                                  AppColors.emerald,
                                  AppColors.emeraldLight,
                                ],
                              ).createShader(b),
                              child: Text(
                                'Hit',
                                style: AppTextStyles.h1.copyWith(
                                  fontSize: 26,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: const [],
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(112),
                          child: DecoratedBox(
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const MenuSearchBar(),
                                  const SizedBox(height: 10),
                                  _MenuSegmentedTabs(controller: controller),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Obx(() {
                        if (controller.activeMenuTab.value == 0) {
                          return const SliverToBoxAdapter(
                            child: MenuCategoryFilterBar(),
                          );
                        }
                        return SliverToBoxAdapter(
                          child: _FoodManagementSection(
                            controller: controller,
                            onEdit: _showEditFood,
                            onDelete: (food) =>
                                _confirmDeleteFood(context, food),
                            onManageOptions: _showOptionGroups,
                            onView: (food) => _showFoodDetail(context, food),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildFab() {
    return SpeedDial(
      icon: Icons.add_rounded,
      activeIcon: Icons.close_rounded,
      backgroundColor: AppColors.emerald,
      foregroundColor: Colors.white,
      activeBackgroundColor: AppColors.errorRed,
      activeForegroundColor: Colors.white,
      spacing: 12,
      spaceBetweenChildren: 12,
      elevation: 8,
      animationCurve: Curves.elasticInOut,
      overlayColor: Colors.black,
      overlayOpacity: 0.15,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.category_rounded, color: AppColors.emerald),
          backgroundColor: Colors.white,
          label: 'Tạo danh mục',
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, color: AppColors.textDark),
          onTap: _showAddCategory,
        ),
        SpeedDialChild(
          child: const Icon(Icons.restaurant_menu_rounded,
              color: AppColors.emerald),
          backgroundColor: Colors.white,
          label: 'Tạo món mới',
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, color: AppColors.textDark),
          onTap: _showAddFood,
        ),
      ],
    );
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -320) {
      controller.showFoodsTab();
    } else if (velocity > 320) {
      controller.showCategoriesTab();
    }
  }

  void _showAddCategory() {
    Get.bottomSheet(
      const AddCategorySheet(),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
    );
  }

  void _showAddFood() {
    Get.bottomSheet(
      const AddFoodSheet(),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
    );
  }

  void _showOptionGroups(FoodModel food) {
    Get.bottomSheet(
      OptionGroupSheet(food: food),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
    );
  }

  void _showEditFood(FoodModel food) {
    Get.bottomSheet(
      EditFoodSheet(food: food),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
    );
  }

  void _showFoodDetail(BuildContext context, FoodModel food) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.58,
        minChildSize: 0.42,
        maxChildSize: 0.94,
        expand: false,
        builder: (context, scrollController) => _FoodDetailSheet(
          food: food,
          scrollController: scrollController,
          onManageOptions: () {
            Get.back();
            _showOptionGroups(food);
          },
          onEdit: () {
            Get.back();
            _showEditFood(food);
          },
          onDelete: () {
            Get.back();
            _confirmDeleteFood(context, food);
          },
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _confirmDeleteFood(BuildContext context, FoodModel food) {
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
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.errorRed, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Xoá món ăn',
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
              const TextSpan(text: 'Bạn chắc chắn muốn xoá '),
              TextSpan(
                text: '"${food.name}"',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: '?'),
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
                Get.back();
                Future.microtask(() => controller.deleteFood(food.id));
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

class _MenuSegmentedTabs extends StatelessWidget {
  const _MenuSegmentedTabs({required this.controller});

  final MenuController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.activeMenuTab.value;
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Expanded(
              child: _SegmentButton(
                label: 'Danh mục',
                icon: Icons.category_outlined,
                count: controller.categories.length,
                selected: active == 0,
                onTap: controller.showCategoriesTab,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _SegmentButton(
                label: 'Món ăn',
                icon: Icons.restaurant_menu_outlined,
                count: controller.visibleFoodsForList.length,
                selected: active == 1,
                onTap: controller.showFoodsTab,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.emeraldDark : AppColors.textGrey;
    return Material(
      color: selected ? AppColors.white : AppColors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? Border.all(color: AppColors.emerald.withValues(alpha: 0.18))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.emerald.withValues(alpha: 0.10)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color:
                        selected ? AppColors.emeraldDark : AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
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

class _FoodManagementSection extends StatelessWidget {
  const _FoodManagementSection({
    required this.controller,
    required this.onEdit,
    required this.onDelete,
    required this.onManageOptions,
    required this.onView,
  });

  final MenuController controller;
  final ValueChanged<FoodModel> onEdit;
  final ValueChanged<FoodModel> onDelete;
  final ValueChanged<FoodModel> onManageOptions;
  final ValueChanged<FoodModel> onView;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final foods = controller.visibleFoodsForList;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Món ăn',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                _SmallCountBadge(value: '${foods.length}'),
                const Spacer(),
                if (controller.isFiltered)
                  _SectionTextButton(
                    label: 'Bỏ lọc',
                    icon: Icons.filter_alt_off_outlined,
                    onTap: controller.clearFilters,
                  ),
              ],
            ),
            if (controller.selectedCategoryId.value != null) ...[
              const SizedBox(height: 6),
              Text(
                'Đang lọc theo danh mục đã chọn',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (foods.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 56),
                child: AppEmptyState(
                  icon: Icons.restaurant_menu_outlined,
                  message: 'Không tìm thấy món ăn nào',
                ),
              )
            else
              for (final food in foods) ...[
                FoodCard(
                  food: food,
                  onToggle: (_) => controller.toggleAvailability(food),
                  onEdit: () => onEdit(food),
                  onDelete: () => onDelete(food),
                  onManageOptions: () => onManageOptions(food),
                  onView: () => onView(food),
                ),
                if (food != foods.last) const SizedBox(height: 10),
              ],
          ],
        ),
      );
    });
  }
}

class _SmallCountBadge extends StatelessWidget {
  const _SmallCountBadge({required this.value});

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

class _SectionTextButton extends StatelessWidget {
  const _SectionTextButton({
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
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.emerald,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FoodDetailSheet extends StatelessWidget {
  const _FoodDetailSheet({
    required this.food,
    required this.scrollController,
    required this.onManageOptions,
    required this.onEdit,
    required this.onDelete,
  });

  final FoodModel food;
  final ScrollController scrollController;
  final VoidCallback onManageOptions;
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
              Row(
                children: [
                  const Expanded(
                    child: Text('Chi tiết món ăn', style: AppTextStyles.h3),
                  ),
                  _FoodStatusPill(isAvailable: food.isAvailable),
                ],
              ),
              const SizedBox(height: 14),
              _DetailImage(
                imageUrl: food.imageUrl,
                caption: food.name,
                fallbackIcon: Icons.restaurant_menu_rounded,
              ),
              const SizedBox(height: 16),
              Text(
                food.name,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                food.description?.trim().isNotEmpty == true
                    ? food.description!.trim()
                    : 'Không có mô tả',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textGrey,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FoodInfoPill(
                    icon: Icons.payments_outlined,
                    label: '${food.price.toInt().toVnd()}đ',
                  ),
                  _FoodInfoPill(
                    icon: Icons.category_outlined,
                    label: food.categoryName,
                  ),
                  _FoodInfoPill(
                      icon: Icons.tag_rounded, label: 'ID ${food.id}'),
                ],
              ),
              const SizedBox(height: 18),
              _DetailInfoBlock(
                title: 'Thông tin backend',
                rows: [
                  ('Mã món', '#${food.id}'),
                  ('Tên món', food.name),
                  ('Giá bán', '${food.price.toInt().toVnd()}đ'),
                  ('Mã danh mục', '#${food.categoryId}'),
                  ('Tên danh mục', food.categoryName),
                  ('Trạng thái', food.isAvailable ? 'Đang bán' : 'Tạm ẩn'),
                  (
                    'Ảnh',
                    food.imageUrl?.isNotEmpty == true
                        ? food.imageUrl!
                        : 'Chưa có ảnh'
                  ),
                  (
                    'Mô tả',
                    food.description?.trim().isNotEmpty == true
                        ? food.description!.trim()
                        : 'Không có mô tả'
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _GreenSquareButton(
                      label: 'Tuỳ chọn',
                      icon: Icons.tune_rounded,
                      onTap: onManageOptions,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GreenSquareButton(
                      label: 'Xoá',
                      icon: Icons.delete_outline_rounded,
                      onTap: onDelete,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: _GreenSquareButton(
                  label: 'Sửa món ăn',
                  icon: Icons.edit_outlined,
                  onTap: onEdit,
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
                color: AppColors.grey100,
                child: Icon(fallbackIcon, size: 46, color: AppColors.grey600),
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

class _FoodStatusPill extends StatelessWidget {
  const _FoodStatusPill({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? AppColors.emeraldDark : AppColors.grey600;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        isAvailable ? 'Đang bán' : 'Tạm ẩn',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FoodInfoPill extends StatelessWidget {
  const _FoodInfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textGrey),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
