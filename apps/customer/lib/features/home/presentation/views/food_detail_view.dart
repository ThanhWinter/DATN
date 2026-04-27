import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/food_option_model.dart';
import '../controllers/food_detail_controller.dart';

class FoodDetailView extends GetView<FoodDetailController> {
  const FoodDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onSuccess: () => _FoodDetailContent(controller: controller),
      ),
    );
  }
}

class _FoodDetailContent extends StatelessWidget {
  const _FoodDetailContent({required this.controller});

  final FoodDetailController controller;

  @override
  Widget build(BuildContext context) {
    final food = controller.food.value!;

    return CustomScrollView(
      slivers: [
        // ── Hero image + AppBar ───────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: AppColors.primaryOrange,
          iconTheme: const IconThemeData(color: AppColors.white),
          actions: [
            Obx(() => IconButton(
                  onPressed: controller.toggleFavorite,
                  icon: Icon(
                    controller.isFavorite.value
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: AppColors.white,
                  ),
                )),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: food.imageUrl != null
                ? AppNetworkImage(
                    url: food.imageUrl!,
                    fit: BoxFit.cover,
                    memCacheWidth: 400,
                    errorWidget: _placeholder(),
                  )
                : _placeholder(),
          ),
        ),

        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Tên + giá + mô tả ──────────────────────────────────────
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(food.name, style: AppTextStyles.h2),
                    if (food.description != null) ...[
                      const SizedBox(height: 6),
                      Text(food.description!,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textGrey)),
                    ],
                    const SizedBox(height: 12),
                    Obx(() => Text(
                          '${controller.totalPrice.value.toVnd()} ₫',
                          style: AppTextStyles.h2
                              .copyWith(color: AppColors.primaryOrange),
                        )),
                  ],
                ),
              ),

              // ── Option groups ───────────────────────────────────────────
              ...food.optionGroups.map(
                (group) => _OptionGroupSection(
                  group: group,
                  controller: controller,
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.grey200,
        child: const Center(
          child: Icon(Icons.fastfood_rounded,
              color: AppColors.grey400, size: 60),
        ),
      );
}

// ── Option group section ──────────────────────────────────────────────────────

class _OptionGroupSection extends StatelessWidget {
  const _OptionGroupSection({
    required this.group,
    required this.controller,
  });

  final OptionGroupModel group;
  final FoodDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header nhóm
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(group.name, style: AppTextStyles.h3),
                ),
                if (group.isRequired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Bắt buộc',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.errorRed),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(
              group.isMultiSelect
                  ? 'Chọn tối đa ${group.maxSelect}'
                  : 'Chọn 1',
              style: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(height: 8),

          // Danh sách options
          ...group.items.map(
            (item) => Obx(() {
              final selected =
                  controller.isOptionSelected(group.id, item.id);
              return _OptionTile(
                item: item,
                selected: selected,
                isMulti: group.isMultiSelect,
                onTap: () => controller.toggleOption(
                  group.id,
                  item.id,
                  group.maxSelect,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.item,
    required this.selected,
    required this.isMulti,
    required this.onTap,
  });

  final OptionItemModel item;
  final bool selected;
  final bool isMulti;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            isMulti
                ? Checkbox(
                    value: selected,
                    onChanged: (_) => onTap(),
                    activeColor: AppColors.primaryOrange,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )
                : _RadioDot(selected: selected),
            const SizedBox(width: 8),
            Expanded(
              child: Text(item.name, style: AppTextStyles.bodyLarge),
            ),
            if (item.priceAdjustment > 0)
              Text(
                '+ ${item.priceAdjustment.toVnd()}đ',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.primaryOrange),
              ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primaryOrange : AppColors.grey400,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryOrange,
                ),
              ),
            )
          : null,
    );
  }
}

// ── Bottom bar (sticky) ───────────────────────────────────────────────────────

class FoodDetailBottomBar extends GetView<FoodDetailController> {
  const FoodDetailBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: const BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black54,
              blurRadius: 6,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Obx(() => QuantitySelector(
                    value: controller.quantity.value,
                    onIncrease: controller.increaseQty,
                    onDecrease: controller.decreaseQty,
                  )),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => PrimaryButton(
                      label: 'Thêm vào giỏ  •  ${controller.totalPrice.value.toVnd()}đ',
                      onPressed: controller.canAddToCart.value
                          ? controller.addToCart
                          : null,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
