import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/home_items.dart';
import '../../data/models/food_option_model.dart';
import '../controllers/food_detail_controller.dart';
import '../../../interactions/data/models/interaction_models.dart';

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

// ── Main content ──────────────────────────────────────────────────────────────

class _FoodDetailContent extends StatelessWidget {
  const _FoodDetailContent({required this.controller});

  final FoodDetailController controller;

  @override
  Widget build(BuildContext context) {
    final food = controller.food.value!;

    return CustomScrollView(
      slivers: [
        _FoodSliverAppBar(food: food, controller: controller),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Card chính ────────────────────────────────────────────
              _MainInfoCard(food: food, controller: controller),

              // ── Tuỳ chọn ─────────────────────────────────────────────
              ...food.optionGroups.map(
                (group) => _OptionGroupSection(
                  group: group,
                  controller: controller,
                ),
              ),

              // ── Mô tả ─────────────────────────────────────────────────
              _FoodDescriptionSection(food: food),

              // ── Đánh giá ──────────────────────────────────────────────
              _ReviewsSection(controller: controller),

              const SizedBox(height: 130),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Sliver AppBar with tappable image ─────────────────────────────────────────

class _FoodSliverAppBar extends StatelessWidget {
  const _FoodSliverAppBar({required this.food, required this.controller});

  final FoodItemModel food;
  final FoodDetailController controller;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.black,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: AppColors.white),
      actions: [
        Obx(() => IconButton(
              onPressed: controller.toggleFavorite,
              icon: Icon(
                controller.isFavorite.value
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: controller.isFavorite.value
                    ? Colors.redAccent
                    : AppColors.white,
              ),
            )),
        IconButton(
          onPressed: () => _showShareSheet(context, controller),
          icon: const Icon(Icons.ios_share_rounded, color: AppColors.white),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onTap: food.imageUrl != null
              ? () => _openFullscreenImage(context, food.imageUrl!)
              : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              food.imageUrl != null
                  ? AppNetworkImage(
                      url: food.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: _FoodPlaceholder(),
                    )
                  : _FoodPlaceholder(),
              // Gradient overlay
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x22000000), Color(0x88000000)],
                  ),
                ),
              ),
              // Tap hint
              if (food.imageUrl != null)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_out_map_rounded,
                            color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Phóng to',
                            style: TextStyle(color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFullscreenImage(BuildContext context, String url) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => _FullscreenImagePage(url: url),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }
}

class _FoodPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grey200,
      child: const Center(
        child: Icon(Icons.fastfood_rounded, color: AppColors.grey400, size: 64),
      ),
    );
  }
}

// ── Fullscreen image viewer ────────────────────────────────────────────────────

class _FullscreenImagePage extends StatelessWidget {
  const _FullscreenImagePage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black87,
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: AppNetworkImage(
                      url: url,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 22),
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

// ── Main info card ────────────────────────────────────────────────────────────

class _MainInfoCard extends StatelessWidget {
  const _MainInfoCard({required this.food, required this.controller});

  final FoodItemModel food;
  final FoodDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên món
          Text(
            food.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),

          // Giá
          Obx(() => Text(
                'Từ ${controller.totalPrice.value.toVnd()}đ',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryOrange,
                  height: 1.2,
                ),
              )),
          const SizedBox(height: 12),

          // Badges: dùng Wrap để tránh overflow
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                icon: Icons.fastfood_rounded,
                label: food.categoryName ?? 'Đang cập nhật',
                bgColor: const Color(0xFFF3EEFF),
                textColor: const Color(0xFF7C3AED),
                iconColor: const Color(0xFF7C3AED),
              ),
              _Badge(
                icon: food.isAvailable
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                label: food.isAvailable ? 'Đặt ngay' : 'Tạm hết',
                bgColor: food.isAvailable
                    ? AppColors.successGreen.withValues(alpha: 0.1)
                    : AppColors.errorRed.withValues(alpha: 0.1),
                textColor:
                    food.isAvailable ? AppColors.successGreen : AppColors.errorRed,
                iconColor:
                    food.isAvailable ? AppColors.successGreen : AppColors.errorRed,
              ),
            ],
          ),

          // Mô tả đầy đủ
          if (food.description != null &&
              food.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.grey200),
            const SizedBox(height: 12),
            Text(
              food.description!.trim(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGrey,
                height: 1.55,
              ),
            ),
          ],

          // Delivery info
          if (food.distanceKm != null ||
              food.deliveryEta != null ||
              food.deliveryFee != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.grey200),
            const SizedBox(height: 12),
            _DeliveryRow(food: food),
          ],

          // Offer banner
          if (food.hasOffer || !(food.offerText?.isEmpty ?? true)) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.grey200),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_offer_rounded,
                      color: AppColors.successGreen, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    food.offerText ?? 'Ưu đãi đang áp dụng',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryRow extends StatelessWidget {
  const _DeliveryRow({required this.food});

  final FoodItemModel food;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (food.distanceKm != null) {
      parts.add('${food.distanceKm!.toStringAsFixed(1)} km');
    }
    if (food.deliveryEta != null) parts.add(food.deliveryEta!);
    if (food.deliveryFee != null) parts.add('${food.deliveryFee!.toVnd()}đ');

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delivery_dining_rounded,
              color: AppColors.successGreen, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            parts.join('  •  '),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Option group ──────────────────────────────────────────────────────────────

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
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 4),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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
            const SizedBox(width: 10),
            Expanded(
              child: Text(item.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                  )),
            ),
            if (item.priceAdjustment > 0)
              Text(
                '+ ${item.priceAdjustment.toVnd()}đ',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryOrange,
                ),
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

// ── Description section ────────────────────────────────────────────────────────

class _FoodDescriptionSection extends StatelessWidget {
  const _FoodDescriptionSection({required this.food});

  final FoodItemModel food;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chi tiết món ăn', style: AppTextStyles.h3),
            const SizedBox(height: 10),
            Text(
              food.description?.trim().isNotEmpty == true
                  ? food.description!.trim()
                  : 'Món này hiện chưa có mô tả chi tiết. Bạn có thể đặt ngay với mức giá tốt từ cửa hàng.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGrey,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reviews section ────────────────────────────────────────────────────────────

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.controller});

  final FoodDetailController controller;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Đánh giá', style: AppTextStyles.h3),
                const Spacer(),
                Obx(() {
                  final rating = controller.rating.value;
                  if (rating.totalReviews == 0) return const SizedBox.shrink();
                  return Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.accentGold, size: 18),
                      const SizedBox(width: 3),
                      Text(
                        rating.avgRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${rating.totalReviews})',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textGrey),
                      ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final reviews = controller.reviews;
              if (reviews.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Chưa có đánh giá nào.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textGrey),
                  ),
                );
              }
              return Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 20, color: AppColors.grey200),
                    itemBuilder: (_, index) =>
                        _ReviewTile(review: reviews[index]),
                  ),
                  Obx(() {
                    final rating = controller.rating.value;
                    if (rating.totalReviews > reviews.length) {
                      return Column(
                        children: [
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: controller.viewAllReviews,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryOrange,
                                side: const BorderSide(
                                    color: AppColors.primaryOrange),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Xem tất cả',
                                  style: AppTextStyles.bodyLarge),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                review.userFullName.isNotEmpty
                    ? review.userFullName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userFullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: i < review.rating
                            ? AppColors.accentGold
                            : AppColors.grey300,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (review.comment != null && review.comment!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            review.comment!,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textDark, height: 1.5),
          ),
        ],
      ],
    );
  }
}

// ── Share sheet ────────────────────────────────────────────────────────────────

void _showShareSheet(BuildContext context, FoodDetailController controller) {
  final food = controller.food.value;
  if (food == null) return;

  final shareText = '🍜 Mình đang thèm món "${food.name}" tại FoodHit!\n'
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 8),
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
                  snackPosition: SnackPosition.TOP,
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

// ── Bottom bar ────────────────────────────────────────────────────────────────

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
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
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
                    height: 48,
                    child: ElevatedButton(
                      onPressed: controller.canAddToCart.value
                          ? controller.addToCart
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.grey300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        controller.canAddToCart.value
                            ? 'Thêm vào giỏ  •  ${controller.totalPrice.value.toVnd()}đ'
                            : 'Chọn tuỳ chọn bắt buộc',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
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
