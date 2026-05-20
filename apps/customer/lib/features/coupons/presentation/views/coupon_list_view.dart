import 'dart:math' as math;

import 'package:core_network/core_network.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../features/main/presentation/controllers/main_controller.dart';
import '../../../../features/orders/data/models/coupon_model.dart';
import '../../../../features/payment/data/repositories/coupon_repository.dart';
import '../controllers/optimized_coupon_list_controller.dart';

// ── Palette màu cho các card (cycling) ───────────────────────────────────────
const _kCardColors = [
  Color(0xFF3CB878), // xanh lá
  Color(0xFFFF9F1C), // cam
  Color(0xFFE8445A), // hồng đỏ
  Color(0xFF3A86FF), // xanh dương
  Color(0xFF8338EC), // tím
  Color(0xFF06D6A0), // xanh ngọc
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
      return _SectionLabel(
          label: 'Ưu đãi đang hoạt động', count: available.length);
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
  late final OptimizedCouponListController controller;

  @override
  void initState() {
    super.initState();
    controller = _resolveController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.ensureFirstLoad();
    });
  }

  OptimizedCouponListController _resolveController() {
    try {
      return Get.find<OptimizedCouponListController>();
    } catch (_) {
      final repository = _resolveRepository();
      return Get.put(OptimizedCouponListController(repository));
    }
  }

  CouponRepository _resolveRepository() {
    try {
      return Get.find<CouponRepository>();
    } catch (_) {
      return CouponRepository(Get.find<IApiClient>());
    }
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

  Color get _baseColor {
    if (isExpired) return const Color(0xFF9E9E9E);
    return _kCardColors[colorIndex % _kCardColors.length];
  }

  String get _discountBig {
    if (coupon.discountType == CouponModel.typePercent) {
      return '${coupon.discountValue.toInt()}%';
    }
    return '${(coupon.discountValue / 1000).toStringAsFixed(0)}K';
  }

  String get _title {
    if (coupon.discountType == CouponModel.typePercent) {
      final cap = coupon.maxDiscount != null
          ? ' - Tối đa ${(coupon.maxDiscount! / 1000).toStringAsFixed(0)}K'
          : '';
      return 'Giảm $_discountBig$cap';
    }
    return 'Giảm $_discountBig';
  }

  String get _timeText {
    final now = DateTime.now().toUtc();
    final exp = coupon.expiresAt.toUtc();
    final diff = exp.difference(now).inDays;
    if (isExpired) return 'Đã hết hạn';
    if (diff == 0) return 'Sắp hết hạn: Hôm nay';
    if (diff <= 3) return 'Sắp hết hạn: Còn $diff ngày';
    return 'HSD: ${DateFormat('dd/MM/yyyy').format(exp)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Opacity(
        opacity: isExpired ? 0.6 : 1.0,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isExpired
                ? null
                : [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // ── Left: Gradient Ticket Stub ──────────────────────────────
              Container(
                width: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _baseColor.withValues(alpha: 0.8),
                      _baseColor,
                    ],
                  ),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    // Watermark icon
                    const Positioned(
                      right: -15,
                      bottom: -15,
                      child: Icon(
                        Icons.local_offer_rounded,
                        size: 60,
                        color: Color(0x33FFFFFF), // Colors.white with 0.2 alpha
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _discountBig,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Giảm giá',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Divider: Dashed Line ──────────────────────────────────────
              SizedBox(
                width: 12,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final height = constraints.constrainHeight();
                    const dashHeight = 4.0;
                    const dashSpace = 3.0;
                    final dashCount =
                        (height / (dashHeight + dashSpace)).floor();
                    return Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(dashCount, (_) {
                        return const SizedBox(
                          width: 1,
                          height: dashHeight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: AppColors.grey300),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),

              // ── Right: Details ────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Min order
                      if (coupon.minOrderValue != null)
                        Text(
                          'Đơn tối thiểu ${coupon.minOrderValue!.toInt().toVnd()}đ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      const SizedBox(height: 6),
                      // Code pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          border: Border.all(color: AppColors.grey300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          coupon.code,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Progress bar / Used count
                      if (coupon.usageLimit != null) ...[
                        _RemainingBar(
                          remaining: coupon.usageLimit! - coupon.usedCount,
                          total: coupon.usageLimit!,
                          color: _baseColor,
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Bottom row: Time + Action
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              _timeText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isExpired
                                    ? AppColors.errorRed
                                    : AppColors.primaryOrange,
                              ),
                            ),
                          ),
                          if (!isExpired)
                            InkWell(
                              onTap: () => _useCoupon(context),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _baseColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'Dùng',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
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

  void _useCoupon(BuildContext context) {
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
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primaryOrange,
      colorText: AppColors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }
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
