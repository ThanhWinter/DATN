import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/routes/app_routes.dart';
import '../../data/models/home_items.dart';
import '../../data/models/food_option_model.dart';
import '../controllers/food_detail_controller.dart';

class FoodDetailView extends GetView<FoodDetailController> {
  const FoodDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: Stack(
        children: [
          SnapHelperWidget(
            isLoading: controller.isLoading,
            error: controller.error,
            onSuccess: () => _FoodDetailContent(controller: controller),
          ),
          const FoodDetailBottomBar(),
        ],
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
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: Colors.black,
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
            IconButton(
              onPressed: () => _showShareSheet(context, controller),
              icon: const Icon(Icons.ios_share_rounded, color: AppColors.white),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                food.imageUrl != null
                    ? AppNetworkImage(
                        url: food.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: _placeholder(),
                      )
                    : _placeholder(),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x12000000),
                        Color(0x66000000),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(food.name, style: AppTextStyles.h2)),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.grey400,
                          size: 24,
                        ),
                      ],
                    ),
                    if (food.description != null) ...[
                      const SizedBox(height: 6),
                      Text(food.description!,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textGrey)),
                    ],
                    const SizedBox(height: 14),
                    _QuickInfoSection(controller: controller),
                    const SizedBox(height: 12),
                    Obx(() => Text(
                          'Từ ${controller.totalPrice.value.toVnd()}đ',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.primaryOrange,
                          ),
                        )),
                  ],
                ),
              ),
              if (food.hasOffer || !(food.offerText?.isEmpty ?? true))
                RepaintBoundary(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    color: AppColors.white,
                    child: ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.local_offer_outlined,
                        color: AppColors.successGreen,
                      ),
                      title: Text(
                        food.offerText ?? 'Offers are available',
                        style: AppTextStyles.bodyLarge,
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.grey400,
                      ),
                    ),
                  ),
                ),
              RepaintBoundary(child: _FoodMetaSection(food: food)),
              Obx(() {
                if (controller.relatedFoods.isEmpty) {
                  return const SizedBox.shrink();
                }
                return _ForYouSection(controller: controller);
              }),
              ...food.optionGroups.map(
                (group) => _OptionGroupSection(
                  group: group,
                  controller: controller,
                ),
              ),
              if (food.optionGroups.isEmpty)
                RepaintBoundary(child: _NoOptionSection(food: food)),
              const SizedBox(height: 130),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.grey200,
        child: const Center(
          child:
              Icon(Icons.fastfood_rounded, color: AppColors.grey400, size: 60),
        ),
      );
}

// ── Share Sheet ───────────────────────────────────────────────────────────────

void _showShareSheet(BuildContext context, FoodDetailController controller) {
  final food = controller.food.value;
  if (food == null) return;

  final shareText =
      '🍜 Mình đang thèm món "${food.name}" tại FoodHit!\n'
      '💰 Giá từ ${food.price.toInt().toVnd()}đ\n'
      '📲 Tải app FoodHit để đặt ngay nhé!';

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _ShareSheet(food: food, shareText: shareText),
  );
}

class _ShareSheet extends StatelessWidget {
  final FoodItemModel food;
  final String shareText;

  const _ShareSheet({required this.food, required this.shareText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Food preview
            Row(
              children: [
                if (food.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AppNetworkImage(
                      url: food.imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorWidget: const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Từ ${food.price.toInt().toVnd()}đ',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Share options
            _ShareOption(
              icon: Icons.share_rounded,
              iconColor: AppColors.primaryOrange,
              label: 'Chia sẻ qua ứng dụng khác',
              onTap: () {
                Get.back();
                Share.share(shareText, subject: food.name);
              },
            ),
            _ShareOption(
              icon: Icons.copy_rounded,
              iconColor: AppColors.textGrey,
              label: 'Sao chép nội dung',
              onTap: () {
                Clipboard.setData(ClipboardData(text: shareText));
                Get.back();
                Get.snackbar(
                  'Đã sao chép',
                  'Nội dung đã được sao chép vào clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.textDark,
                  colorText: AppColors.white,
                  margin: const EdgeInsets.all(12),
                  borderRadius: 10,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickInfoSection extends StatelessWidget {
  const _QuickInfoSection({required this.controller});

  final FoodDetailController controller;

  @override
  Widget build(BuildContext context) {
    final food = controller.food.value!;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Obx(() {
            final rating = controller.rating.value;
            return _InfoRow(
              icon: Icons.star_rounded,
              iconColor: AppColors.accentGold,
              title: rating.avgRating > 0
                  ? rating.avgRating.toStringAsFixed(1)
                  : 'Chưa có',
              subtitle: '${rating.totalReviews} reviews',
            );
          }),
          _InfoRow(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.successGreen,
            title: food.distanceKm != null
                ? '${food.distanceKm!.toStringAsFixed(1)} km'
                : 'Khoảng cách cập nhật sau',
          ),
          _InfoRow(
            icon: Icons.delivery_dining_rounded,
            iconColor: AppColors.successGreen,
            title: food.deliveryEta ?? 'Delivery Now',
            subtitle: food.deliveryFee != null
                ? '${food.deliveryFee!.toVnd()}đ'
                : null,
            hasBottomDivider: false,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.hasBottomDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool hasBottomDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: hasBottomDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.grey200),
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Text(title, style: AppTextStyles.bodyLarge),
          if (subtitle != null) ...[
            const SizedBox(width: 8),
            Text(
              subtitle!,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
            ),
          ],
          const Spacer(),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.grey400,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _ForYouSection extends StatelessWidget {
  const _ForYouSection({required this.controller});

  final FoodDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('For You', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final item = controller.relatedFoods[index];
                return _ForYouCard(item: item, isBestSeller: index == 0);
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: controller.relatedFoods.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _ForYouCard extends StatelessWidget {
  const _ForYouCard({
    required this.item,
    required this.isBestSeller,
  });

  final FoodItemModel item;
  final bool isBestSeller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.foodDetail, arguments: item.id),
      child: Container(
        width: 138,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey200),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  SizedBox(
                    width: 122,
                    height: 116,
                    child: item.imageUrl != null
                        ? AppNetworkImage(
                            url: item.imageUrl!, fit: BoxFit.cover)
                        : _fallback(),
                  ),
                  if (isBestSeller)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Best Seller',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              '${item.price.toVnd()}đ',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.primaryOrange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        color: AppColors.grey200,
        child: const Center(
          child: Icon(Icons.fastfood_rounded, color: AppColors.grey400),
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
    return GetBuilder<FoodDetailController>(
      id: 'group_${group.id}',
      builder: (c) => RepaintBoundary(
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          color: AppColors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              ...group.items.map(
                (item) => _OptionTile(
                  item: item,
                  selected: c.isOptionSelected(group.id, item.id),
                  isMulti: group.isMultiSelect,
                  onTap: () => c.toggleOption(
                    group.id,
                    item.id,
                    group.maxSelect,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodMetaSection extends StatelessWidget {
  const _FoodMetaSection({required this.food});

  final FoodItemModel food;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thông tin món ăn', style: AppTextStyles.h3),
          const SizedBox(height: 10),
          _MetaRow(
            label: 'Danh mục',
            value: food.categoryName?.isNotEmpty == true
                ? food.categoryName!
                : 'Đang cập nhật',
          ),
          _MetaRow(
            label: 'Tình trạng',
            value: food.isAvailable ? 'Có thể đặt ngay' : 'Tạm hết',
          ),
          _MetaRow(
            label: 'Tuỳ chọn thêm',
            value: '${food.optionGroups.length} nhóm lựa chọn',
            hideDivider: true,
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    this.hideDivider = false,
  });

  final String label;
  final String value;
  final bool hideDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: hideDivider
            ? null
            : const Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
            ),
          ),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _NoOptionSection extends StatelessWidget {
  const _NoOptionSection({required this.food});

  final FoodItemModel food;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gợi ý dùng món', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            food.description?.trim().isNotEmpty == true
                ? food.description!
                : 'Món này hiện chưa có mô tả chi tiết. Bạn có thể đặt ngay với mức giá tốt từ cửa hàng.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 10),
          const _HintLine(text: 'Phù hợp cho bữa trưa hoặc bữa tối nhẹ.'),
          const _HintLine(
              text: 'Nên dùng ngay khi nhận để giữ hương vị tốt nhất.'),
          const _HintLine(text: 'Có thể thêm combo đồ uống tại giỏ hàng.'),
        ],
      ),
    );
  }
}

class _HintLine extends StatelessWidget {
  const _HintLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 6, color: AppColors.primaryOrange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
            ),
          ),
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
          minimum: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Obx(() => QuantitySelector(
                    value: controller.quantity.value,
                    onIncrease: controller.increaseQty,
                    onDecrease: controller.decreaseQty,
                  )),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(
                  () => SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: controller.canAddToCart.value
                          ? controller.addToCart
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.grey300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Thêm vào giỏ  •  ${controller.totalPrice.value.toVnd()}đ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
