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
      backgroundColor: AppColors.grey100,
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onSuccess: () => RefreshIndicator(
          onRefresh: controller.loadData,
          color: AppColors.primaryOrange,
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
                  backgroundColor: AppColors.white,
                  elevation: 0,
                  expandedHeight: 120,
                  title:
                      const Text('Quản lý Thực đơn', style: AppTextStyles.h3),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: AppColors.primaryOrange),
                      onPressed: _showAddCategory,
                      tooltip: 'Thêm danh mục',
                    ),
                    const SizedBox(width: 8),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFood,
        backgroundColor: AppColors.primaryOrange,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('Thêm món mới',
            style: TextStyle(
                color: AppColors.white, fontWeight: FontWeight.bold)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xoá món ăn', style: AppTextStyles.h3),
        content: Text('Bạn chắc chắn muốn xoá "${food.name}"?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Huỷ',
                style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteFood(food.id);
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
