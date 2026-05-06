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
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: 120,
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Quản lý ',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: [
                            AppColors.emeraldDark,
                            AppColors.emeraldLight,
                          ],
                        ).createShader(b),
                        child: Text(
                          'Thực đơn',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.emerald.withValues(alpha: 0.3),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_rounded,
                            color: AppColors.emerald, size: 20),
                        onPressed: _showAddCategory,
                        tooltip: 'Thêm danh mục',
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.fromLTRB(16, 100, 16, 0),
                      child: const MenuSearchBar(),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: MenuCategoryFilterBar()),
                const SliverToBoxAdapter(child: MenuStatsRow()),
                Obx(() {
                  final foods = controller.visibleFoodsForList;
                  if (foods.isEmpty) {
                    return const SliverFillRemaining(
                      child: AppEmptyState(
                        icon: Icons.restaurant_menu_outlined,
                        message: 'Không tìm thấy món ăn nào',
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final food = foods[i];
                          return RepaintBoundary(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: FoodCard(
                                food: food,
                                onToggle: (_) =>
                                    controller.toggleAvailability(food),
                                onEdit: () => _showEditFood(food),
                                onDelete: () =>
                                    _confirmDeleteFood(context, food),
                                onManageOptions: () =>
                                    _showOptionGroups(food),
                              ),
                            ),
                          );
                        },
                        childCount: foods.length,
                      ),
                    ),
                  );
                }),
              ],
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
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.emeraldDark, AppColors.emerald, AppColors.emeraldLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddFood,
          borderRadius: BorderRadius.circular(28),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: AppColors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Thêm món mới',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                controller.deleteFood(food.id);
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
