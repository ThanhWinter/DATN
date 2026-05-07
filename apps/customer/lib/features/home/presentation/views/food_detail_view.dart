import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

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
              // ── Card chính: tên + info rows ─────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên món + giá
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            food.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.grey400,
                          size: 22,
                        ),
                      ],
                    ),
                    if (food.description != null &&
                        food.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        food.description!,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textGrey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Giá nổi bật
                    Obx(() => Text(
                          'Từ ${controller.totalPrice.value.toVnd()}đ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryOrange,
                          ),
                        )),
                    const SizedBox(height: 16),

                    // Info rows (không có khung xám)
                    _QuickInfoSection(controller: controller),
                  ],
                ),
              ),

              // ── Offers row ──────────────────────────────────────────────
              if (food.hasOffer || !(food.offerText?.isEmpty ?? true))
                RepaintBoundary(
                  child: Container(
                    color: AppColors.white,
                    child: _InfoDividerRow(
                      icon: Icons.local_offer_rounded,
                      iconColor: AppColors.successGreen,
                      iconBgColor:
                          AppColors.successGreen.withValues(alpha: 0.1),
                      title: food.offerText ?? 'Offers are available',
                      titleColor: AppColors.successGreen,
                    ),
                  ),
                ),

              // Đường kẻ phân cách bottom của card trắng
              Container(height: 1, color: AppColors.grey200),

              // ── Thông tin món ───────────────────────────────────────────
              RepaintBoundary(child: _FoodMetaSection(food: food)),

              // ── Tuỳ chọn ────────────────────────────────────────────────
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
    return Column(
      children: [
        // Rating
        Obx(() {
          final rating = controller.rating.value;
          return _InfoDividerRow(
            icon: Icons.star_rounded,
            iconColor: AppColors.accentGold,
            iconBgColor: const Color(0xFFFFF8E1),
            title: rating.avgRating > 0
                ? rating.avgRating.toStringAsFixed(1)
                : 'Chưa có đánh giá',
            subtitle: rating.totalReviews > 0
                ? '(${rating.totalReviews} reviews)'
                : null,
          );
        }),
        // Khoảng cách + giao hàng — chỉ hiện nếu có dữ liệu
        if (food.distanceKm != null ||
            food.deliveryEta != null ||
            food.deliveryFee != null)
          _InfoDividerRow(
            icon: Icons.delivery_dining_rounded,
            iconColor: AppColors.successGreen,
            iconBgColor: AppColors.successGreen.withValues(alpha: 0.1),
            title: food.distanceKm != null
                ? '${food.distanceKm!.toStringAsFixed(1)} km'
                : food.deliveryEta ?? 'Giao hàng',
            subtitle: () {
              final parts = [
                if (food.distanceKm != null && food.deliveryEta != null)
                  food.deliveryEta!,
                if (food.deliveryFee != null) '${food.deliveryFee!.toVnd()}đ',
              ];
              return parts.isEmpty ? null : parts.join('  •  ');
            }(),
          ),
      ],
    );
  }
}

// Row thông tin dạng: [icon tròn] [title] [subtitle?] [chevron]
class _InfoDividerRow extends StatelessWidget {
  const _InfoDividerRow({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    this.titleColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, color: AppColors.grey200),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? AppColors.textDark,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(width: 6),
                      const Text(
                        '|',
                        style: TextStyle(
                          color: AppColors.grey300,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          subtitle!,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textGrey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey400,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
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
    final isAvailable = food.isAvailable;
    final category = food.categoryName?.isNotEmpty == true
        ? food.categoryName!
        : 'Đang cập nhật';
    final optionCount = food.optionGroups.length;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thông tin món ăn', style: AppTextStyles.h3),
          const SizedBox(height: 14),

          // ── 3 thẻ thông tin ───────────────────────────────────────────
          Row(
            children: [
              // Danh mục
              Expanded(
                child: _MetaChip(
                  icon: Icons.category_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  bgColor: const Color(0xFFF3EEFF),
                  label: 'Danh mục',
                  value: category,
                ),
              ),
              const SizedBox(width: 10),
              // Tình trạng
              Expanded(
                child: _MetaChip(
                  icon: isAvailable
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  iconColor: isAvailable
                      ? AppColors.successGreen
                      : AppColors.errorRed,
                  bgColor: isAvailable
                      ? AppColors.successGreen.withValues(alpha: 0.08)
                      : AppColors.errorRed.withValues(alpha: 0.08),
                  label: 'Tình trạng',
                  value: isAvailable ? 'Đặt ngay' : 'Tạm hết',
                  valueColor: isAvailable
                      ? AppColors.successGreen
                      : AppColors.errorRed,
                ),
              ),
            ],
          ),
          if (optionCount > 0) ...[
            const SizedBox(height: 10),
            // Tuỳ chọn — full width nếu có
            _MetaChip(
              icon: Icons.tune_rounded,
              iconColor: AppColors.primaryOrange,
              bgColor: AppColors.primaryOrange.withValues(alpha: 0.08),
              label: 'Tuỳ chọn',
              value: '$optionCount nhóm — chọn thêm để tùy biến món',
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppColors.textDark,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
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
