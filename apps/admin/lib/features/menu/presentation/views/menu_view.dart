import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../data/models/food_model.dart';
import '../controllers/menu_controller.dart';
import '../widgets/add_category_sheet.dart';
import '../widgets/add_food_sheet.dart';
import '../widgets/edit_food_sheet.dart';
import '../widgets/food_card.dart';
import '../widgets/menu_category_filter_bar.dart';
import '../widgets/menu_search_bar.dart';
import '../widgets/menu_stats_row.dart';
import '../widgets/option_group_sheet.dart';

class MenuView extends GetView<MenuController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onRefresh: controller.loadData,
        onSuccess: () => RefreshIndicator(
          onRefresh: controller.loadData,
          color: AppColors.emerald,
          backgroundColor: Colors.white,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
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
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverAppBar(
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    forceElevated: true,
                    shadowColor: Colors.black12,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Manage',
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 22,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [AppColors.emerald, AppColors.emeraldLight],
                          ).createShader(b),
                          child: Text(
                            'Hit',
                            style: AppTextStyles.h1.copyWith(
                              fontSize: 22,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(44),
                      child: _MenuTabBar(controller: controller),
                    ),
                  ),
                  // Search bar dính — chỉ hiện ở tab Món ăn
                  Obx(() => controller.activeMenuTab.value == 1
                      ? const SliverPersistentHeader(
                          pinned: true,
                          delegate: _SearchBarDelegate(),
                        )
                      : const SliverToBoxAdapter(child: SizedBox.shrink())),
                  Obx(() {
                    if (controller.activeMenuTab.value == 0) {
                      return const SliverToBoxAdapter(
                        child: MenuCategoryFilterBar(),
                      );
                    }
                    return SliverToBoxAdapter(
                      child: _FoodsTabHeader(controller: controller),
                    );
                  }),
                  // Food cards — lazy SliverList (foods tab only)
                  Obx(() {
                    if (controller.activeMenuTab.value != 1) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    final foods = controller.visibleFoodsForList;
                    if (foods.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList.separated(
                        itemCount: foods.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final food = foods[i];
                          return FoodCard(
                            key: ValueKey(food.id),
                            food: food,
                            onToggle: (_) => controller.toggleAvailability(food),
                            onEdit: () => _showEditFood(food),
                            onDelete: () => _confirmDeleteFood(context, food),
                            onManageOptions: () => _showOptionGroups(food),
                            onView: () => _showFoodDetail(context, food),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  void _handleHorizontalSwipe(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (v < -320) {
      controller.showFoodsTab();
    } else if (v > 320) {
      controller.updateSearch(''); // xoá search khi vuốt về Danh mục
      controller.showCategoriesTab();
    }
  }

  void _showAddMenu(BuildContext context) {
    Get.bottomSheet(
      _AddMenuSheet(
        onAddCategory: () { Get.back(); _showAddCategory(); },
        onAddFood: () { Get.back(); _showAddFood(); },
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
    );
  }

  void _showAddCategory() {
    Get.bottomSheet(
      const AddCategorySheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
    );
  }

  void _showAddFood() {
    Get.bottomSheet(
      const AddFoodSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
    );
  }

  void _showOptionGroups(FoodModel food) {
    Get.bottomSheet(
      OptionGroupSheet(food: food),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
    );
  }

  void _showEditFood(FoodModel food) {
    Get.bottomSheet(
      EditFoodSheet(food: food),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
        builder: (_, scrollController) => _FoodDetailSheet(
          food: food,
          scrollController: scrollController,
          onManageOptions: () { Get.back(); _showOptionGroups(food); },
          onEdit: () { Get.back(); _showEditFood(food); },
          onDelete: () { Get.back(); _confirmDeleteFood(context, food); },
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _confirmDeleteFood(BuildContext context, FoodModel food) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xoá món ăn',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
            children: [
              const TextSpan(text: 'Bạn chắc chắn muốn xoá '),
              TextSpan(
                text: '"${food.name}"',
                style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Huỷ', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          FilledButton(
            onPressed: () { Get.back(); Future.microtask(() => controller.deleteFood(food.id)); },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}

// ─── Tab bar ─────────────────────────────────────────────────────────────────

class _MenuTabBar extends StatelessWidget {
  const _MenuTabBar({required this.controller});

  final MenuController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.activeMenuTab.value;
      return Row(
        children: [
          _TabItem(
            label: 'Danh mục',
            count: controller.categories.length,
            isActive: active == 0,
            onTap: () {
              controller.updateSearch('');
              controller.showCategoriesTab();
            },
          ),
          _TabItem(
            label: 'Món ăn',
            count: controller.visibleFoodsForList.length,
            isActive: active == 1,
            onTap: controller.showFoodsTab,
          ),
        ],
      );
    });
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.emeraldDark : const Color(0xFF9CA3AF);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.emerald : const Color(0xFFEBEBEB),
                width: isActive ? 2 : 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.emerald.withValues(alpha: 0.12)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
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

// ─── Add menu action sheet ────────────────────────────────────────────────────

class _AddMenuSheet extends StatelessWidget {
  const _AddMenuSheet({
    required this.onAddCategory,
    required this.onAddFood,
  });

  final VoidCallback onAddCategory;
  final VoidCallback onAddFood;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
              'Thêm mới',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.category_outlined,
              title: 'Tạo danh mục',
              subtitle: 'Thêm nhóm món ăn mới',
              onTap: onAddCategory,
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.restaurant_menu_outlined,
              title: 'Tạo món ăn',
              subtitle: 'Thêm món mới vào thực đơn',
              onTap: onAddFood,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.emerald, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Foods tab header (stats + title row + empty state) ──────────────────────

class _FoodsTabHeader extends StatelessWidget {
  const _FoodsTabHeader({required this.controller});

  final MenuController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final foods = controller.visibleFoodsForList;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MenuStatsRow(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Món ăn',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${foods.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emeraldDark,
                    ),
                  ),
                ),
                const Spacer(),
                if (controller.isFiltered)
                  GestureDetector(
                    onTap: controller.clearFilters,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_alt_off_outlined, size: 14, color: AppColors.emerald),
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
              ],
            ),
            const SizedBox(height: 10),
            if (foods.isEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 100),
                padding: const EdgeInsets.symmetric(vertical: 48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEBEBEB)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.restaurant_menu_outlined, size: 36, color: Color(0xFFD1D5DB)),
                    SizedBox(height: 8),
                    Text(
                      'Không tìm thấy món ăn nào',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

// ─── Food detail sheet ────────────────────────────────────────────────────────

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
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Material(
        color: Colors.white,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            20, 8, 20, 24 + MediaQuery.viewInsetsOf(context).bottom,
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
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Chi tiết món ăn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  _StatusBadge(isAvailable: food.isAvailable),
                ],
              ),
              const SizedBox(height: 14),
              _DetailImage(imageUrl: food.imageUrl, fallbackIcon: Icons.restaurant_menu_rounded),
              const SizedBox(height: 14),
              Text(
                food.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                food.description?.trim().isNotEmpty == true
                    ? food.description!.trim()
                    : 'Không có mô tả',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(label: '${food.price.toInt().toVnd()}đ', isPrice: true),
                  _InfoChip(label: food.categoryName),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Sửa món ăn'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onManageOptions,
                      icon: const Icon(Icons.tune_rounded, size: 16),
                      label: const Text('Tuỳ chọn'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.emerald,
                        side: BorderSide(color: AppColors.emerald.withValues(alpha: 0.4)),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                      label: const Text('Xoá'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFFF0FDF4) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvailable ? const Color(0xFFBBF7D0) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        isAvailable ? 'Đang bán' : 'Tạm ẩn',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isAvailable ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _DetailImage extends StatelessWidget {
  const _DetailImage({required this.imageUrl, required this.fallbackIcon});

  final String? imageUrl;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: imageUrl != null
          ? AppNetworkImage(url: imageUrl!, height: 160, width: double.infinity, fit: BoxFit.cover)
          : Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFFF3F4F6),
              child: Icon(fallbackIcon, size: 40, color: const Color(0xFFD1D5DB)),
            ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, this.isPrice = false});

  final String label;
  final bool isPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPrice
            ? AppColors.emerald.withValues(alpha: 0.08)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isPrice ? AppColors.emeraldDark : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

// ─── Search bar delegate (pinned sliver, foods tab only) ──────────────────────

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  const _SearchBarDelegate();

  static const double _h = 57.0;

  @override
  double get minExtent => _h;

  @override
  double get maxExtent => _h;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const ColoredBox(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 7, 16, 7),
            child: MenuSearchBar(),
          ),
          Divider(height: 1, thickness: 1, color: Color(0xFFEBEBEB)),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SearchBarDelegate old) => false;
}
