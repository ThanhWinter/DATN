import 'dart:math' as math;

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../features/main/presentation/controllers/main_controller.dart';
import '../../../../features/orders/data/models/coupon_model.dart';
import '../controllers/coupon_list_controller.dart';

// ── Palette màu cho các card (cycling) ───────────────────────────────────────
const _kCardColors = [
  Color(0xFF3CB878), // xanh lá
  Color(0xFFFF9F1C), // cam
  Color(0xFFE8445A), // hồng đỏ
  Color(0xFF3A86FF), // xanh dương
  Color(0xFF8338EC), // tím
  Color(0xFF06D6A0), // xanh ngọc
];

// Icon food gợi ý — cycling khi không có ảnh thật
const _kFoodIcons = [
  Icons.lunch_dining_rounded,
  Icons.local_pizza_rounded,
  Icons.ramen_dining_rounded,
  Icons.rice_bowl_rounded,
  Icons.bakery_dining_rounded,
  Icons.fastfood_rounded,
];

int _couponListItemCount(int availableLen, int expiredLen) {
  var n = 0;
  if (availableLen > 0) n += 2 + availableLen;
  if (expiredLen > 0) n += 3 + expiredLen;
  return n;
}

Widget _buildCouponListItem(
  int index,
  List<CouponModel> available,
  List<CouponModel> expired,
  bool isTab,
) {
  var i = index;
  if (available.isNotEmpty) {
    if (i == 0) {
      return _SectionLabel(label: 'Ưu đãi đang hoạt động', count: available.length);
    }
    if (i == 1) return const SizedBox(height: 12);
    if (i < 2 + available.length) {
      final idx = i - 2;
      return _CouponCard(
        coupon: available[idx],
        isExpired: false,
        isTab: isTab,
        colorIndex: idx,
      );
    }
    i -= 2 + available.length;
  }
  if (expired.isNotEmpty) {
    if (i == 0) return const SizedBox(height: 24);
    if (i == 1) {
      return _SectionLabel(label: 'Đã hết hạn', count: expired.length);
    }
    if (i == 2) return const SizedBox(height: 12);
    if (i < 3 + expired.length) {
      return _CouponCard(
        coupon: expired[i - 3],
        isExpired: true,
        isTab: isTab,
        colorIndex: i - 3,
      );
    }
  }
  return const SizedBox.shrink();
}

// ── View ──────────────────────────────────────────────────────────────────────

class CouponListView extends StatefulWidget {
  const CouponListView({super.key, this.isTab = false});

  final bool isTab;

  @override
  State<CouponListView> createState() => _CouponListViewState();
}

class _CouponListViewState extends State<CouponListView> {
  CouponListController get controller => Get.find<CouponListController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.ensureFirstLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        title: const Text(
          'Ưu đãi đặc biệt',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: !widget.isTab,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onSuccess: () => Obx(() {
          final available = controller.availableCoupons.toList();
          final expired = controller.expiredCoupons.toList();

          if (available.isEmpty && expired.isEmpty) {
            return RefreshIndicator(
              onRefresh: controller.loadCoupons,
              color: AppColors.primaryOrange,
              child: const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: AppEmptyState(
                      icon: Icons.local_offer_outlined,
                      message: 'Chưa có ưu đãi nào',
                      subMessage:
                          'Cửa hàng chưa có mã khuyến mãi công khai. Bạn vẫn có thể nhập mã thủ công ở bước thanh toán.',
                    ),
                  ),
                ],
              ),
            );
          }

          final itemCount =
              _couponListItemCount(available.length, expired.length);

          return RefreshIndicator(
            onRefresh: controller.loadCoupons,
            color: AppColors.primaryOrange,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              itemCount: itemCount,
              itemBuilder: (context, index) => _buildCouponListItem(
                index,
                available,
                expired,
                widget.isTab,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryOrange,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Coupon Card ───────────────────────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.isExpired,
    required this.colorIndex,
    this.isTab = false,
  });

  final CouponModel coupon;
  final bool isExpired;
  final int colorIndex;
  final bool isTab;

  Color get _cardColor {
    if (isExpired) return const Color(0xFF9E9E9E);
    return _kCardColors[colorIndex % _kCardColors.length];
  }

  IconData get _foodIcon => _kFoodIcons[colorIndex % _kFoodIcons.length];

  String get _discountBig {
    if (coupon.discountType == CouponModel.typePercent) {
      return '${coupon.discountValue.toInt()}%';
    }
    return '${(coupon.discountValue / 1000).toStringAsFixed(0)}K';
  }

  String get _line1 {
    if (coupon.discountType == CouponModel.typePercent) {
      final cap = coupon.maxDiscount != null
          ? ' TỐI ĐA ${(coupon.maxDiscount! / 1000).toStringAsFixed(0)}K'
          : '';
      return 'GIẢM GIÁ$cap';
    }
    return 'GIẢM TIỀN MẶT';
  }

  String get _line2 {
    final now = DateTime.now().toUtc();
    final exp = coupon.expiresAt.toUtc();
    final diff = exp.difference(now).inDays;
    if (isExpired) return 'ĐÃ HẾT HẠN';
    if (diff == 0) return 'CHỈ TRONG HÔM NAY!';
    if (diff <= 3) return 'HẾT HẠN TRONG $diff NGÀY!';
    return 'ÁP DỤNG NGAY!';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Opacity(
        opacity: isExpired ? 0.55 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: isExpired
                ? null
                : [
                    BoxShadow(
                      color: _cardColor.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                // ── Phần trên: màu + thông tin ưu đãi ──────────────────
                _CardTop(
                  cardColor: _cardColor,
                  discountBig: _discountBig,
                  line1: _line1,
                  line2: _line2,
                  foodIcon: _foodIcon,
                ),
                // ── Phần dưới: mã code + nút bấm ───────────────────────
                _CardBottom(
                  coupon: coupon,
                  cardColor: _cardColor,
                  isExpired: isExpired,
                  isTab: isTab,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Card top (colored hero area) ──────────────────────────────────────────────

class _CardTop extends StatelessWidget {
  const _CardTop({
    required this.cardColor,
    required this.discountBig,
    required this.line1,
    required this.line2,
    required this.foodIcon,
  });

  final Color cardColor;
  final String discountBig;
  final String line1;
  final String line2;
  final IconData foodIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background
          Positioned.fill(child: ColoredBox(color: cardColor)),

          // Decorative circles — rear
          Positioned(
            right: -32,
            top: -32,
            child: _Circle(
              size: 160,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -28,
            child: _Circle(
              size: 90,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),

          // Food icon circle — front right
          Positioned(
            right: -14,
            top: 10,
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 2,
                ),
              ),
              child: Icon(
                foodIcon,
                size: 52,
                color: Colors.white.withValues(alpha: 0.90),
              ),
            ),
          ),

          // Left text content
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            right: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Big discount number
                Text(
                  discountBig,
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                // Line 1
                Text(
                  line1,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.8,
                    height: 1.3,
                  ),
                ),
                // Line 2
                Text(
                  line2,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.6,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card bottom (white info + actions) ───────────────────────────────────────

class _CardBottom extends StatelessWidget {
  const _CardBottom({
    required this.coupon,
    required this.cardColor,
    required this.isExpired,
    required this.isTab,
  });

  final CouponModel coupon;
  final Color cardColor;
  final bool isExpired;
  final bool isTab;

  @override
  Widget build(BuildContext context) {
    final expiryText =
        'HSD: ${DateFormat('dd/MM/yyyy').format(coupon.expiresAt)}';
    final minText = coupon.minOrderValue != null
        ? 'Đơn tối thiểu ${coupon.minOrderValue!.toInt().toVnd()}đ'
        : null;

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          // Info + code
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Code pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: cardColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    coupon.code,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: cardColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Expiry + min order
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 11,
                      color: isExpired
                          ? AppColors.errorRed
                          : AppColors.textGrey,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      expiryText,
                      style: TextStyle(
                        fontSize: 11,
                        color: isExpired
                            ? AppColors.errorRed
                            : AppColors.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (minText != null) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '·',
                        style: TextStyle(
                          color: AppColors.grey400,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          minText,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (coupon.usageLimit != null) ...[
                  const SizedBox(height: 3),
                  _RemainingBar(
                    remaining: coupon.usageLimit! - coupon.usedCount,
                    total: coupon.usageLimit!,
                    color: cardColor,
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          if (!isExpired) ...[
            const SizedBox(width: 8),
            _ActionBtn(
              label: 'Dùng ngay',
              icon: Icons.arrow_forward_rounded,
              color: cardColor,
              outlined: false,
              onTap: () => _useCoupon(),
            ),
          ],
        ],
      ),
    );
  }

  void _useCoupon() {
    // Nếu mở từ checkout (returnOnSelect = true) → trả mã về, không navigate tab
    final args = Get.arguments;
    final returnOnSelect =
        args is Map && (args['returnOnSelect'] as bool? ?? false);
    if (returnOnSelect) {
      Get.back(result: coupon.code);
      return;
    }
    Clipboard.setData(ClipboardData(text: coupon.code));
    if (!isTab) Get.back();
    Get.find<MainController>().onTabChanged(1);
    Get.snackbar(
      'Mã "${coupon.code}" đã sao chép',
      'Vào thanh toán để dán mã và áp dụng.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryOrange,
      colorText: AppColors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      );
}

class _RemainingBar extends StatelessWidget {
  const _RemainingBar({
    required this.remaining,
    required this.total,
    required this.color,
  });

  final int remaining;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isEmpty = remaining <= 0;
    final ratio = isEmpty ? 0.0 : math.min(remaining / total, 1.0);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: AppColors.grey200,
              valueColor: AlwaysStoppedAnimation(
                isEmpty ? AppColors.grey400 : color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isEmpty ? 'Hết lượt' : 'Còn $remaining',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isEmpty ? AppColors.grey400 : color,
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.outlined,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color,
            width: outlined ? 1.5 : 0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: outlined ? color : AppColors.white,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              icon,
              size: 13,
              color: outlined ? color : AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}
