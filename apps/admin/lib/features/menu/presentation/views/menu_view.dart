import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../data/models/food_model.dart';
import '../controllers/menu_controller.dart';
import '../widgets/add_category_sheet.dart';
import '../widgets/add_food_sheet.dart';
import '../widgets/edit_food_sheet.dart';
import '../widgets/food_card.dart';

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
          child: CustomScrollView(
            // AlwaysScrollableScrollPhysics ensures pull-to-refresh works
            // even when list content doesn't fill the screen
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // 1. Custom AppBar
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: AppColors.white,
                elevation: 0,
                expandedHeight: 120,
                title: const Text('Quản lý Thực đơn', style: AppTextStyles.h3),
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
                    child: const _SearchBar(),
                  ),
                ),
              ),

              // 2. Category Filter (Sticky)
              SliverToBoxAdapter(child: _CategoryFilter()),

              // 3. Stats Row
              SliverToBoxAdapter(child: _MenuStats()),

              // 4. Food List
              Obx(() {
                final foods = controller.filteredFoods;
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
                      (context, i) => RepaintBoundary(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FoodCard(
                            food: foods[i],
                            onToggle: (_) =>
                                controller.toggleAvailability(foods[i]),
                            onEdit: () => _showEditFood(foods[i]),
                            onDelete: () =>
                                _confirmDeleteFood(context, foods[i]),
                          ),
                        ),
                      ),
                      childCount: foods.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFood,
        backgroundColor: AppColors.primaryOrange,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('Thêm món mới',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
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

// Functional search bar — TextField wired to MenuController.updateSearch
class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _ctrl = TextEditingController();
  late final MenuController _menuController;

  @override
  void initState() {
    super.initState();
    _menuController = Get.find<MenuController>();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.grey600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: _menuController.updateSearch,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm món ăn...',
                hintStyle: AppTextStyles.bodySmall,
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Obx(() => _menuController.searchQuery.value.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _ctrl.clear();
                    _menuController.updateSearch('');
                  },
                  child: const Icon(Icons.close,
                      color: AppColors.grey400, size: 18),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _CategoryFilter extends GetView<MenuController> {
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
                          memCacheWidth: 24,
                          memCacheHeight: 24,
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
              return Padding(
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
            },
          )),
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

// Wrapped in Obx so counts update immediately when availability is toggled
class _MenuStats extends GetView<MenuController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _StatItem(
                label: 'Tổng số món',
                value: '${controller.foods.length}',
                color: AppColors.primaryOrange,
              ),
              const SizedBox(width: 12),
              _StatItem(
                label: 'Đang bán',
                value:
                    '${controller.foods.where((f) => f.isAvailable).length}',
                color: AppColors.successGreen,
              ),
              const SizedBox(width: 12),
              _StatItem(
                label: 'Hết hàng',
                value:
                    '${controller.foods.where((f) => !f.isAvailable).length}',
                color: AppColors.errorRed,
              ),
            ],
          ),
        ));
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.h3.copyWith(color: color, fontSize: 18)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }
}
