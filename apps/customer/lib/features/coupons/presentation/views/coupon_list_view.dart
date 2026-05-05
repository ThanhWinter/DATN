import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../features/main/presentation/controllers/main_controller.dart';
import '../../../../features/orders/data/models/coupon_model.dart';
import '../controllers/coupon_list_controller.dart';

int _couponListItemCount(int availableLen, int expiredLen) {
  var n = 0;
  if (availableLen > 0) {
    n += 2 + availableLen;
  }
  if (expiredLen > 0) {
    n += 3 + expiredLen;
  }
  return n;
}

/// Linear index → widget (lazy `ListView.builder`).
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
        label: 'Có thể sử dụng',
        count: available.length,
      );
    }
    if (i == 1) return const SizedBox(height: 10);
    if (i < 2 + available.length) {
      return _CouponCard(
        coupon: available[i - 2],
        isExpired: false,
        isTab: isTab,
      );
    }
    i -= 2 + available.length;
  }
  if (expired.isNotEmpty) {
    if (i == 0) return const SizedBox(height: 20);
    if (i == 1) {
      return _SectionLabel(
        label: 'Đã hết hạn',
        count: expired.length,
      );
    }
    if (i == 2) return const SizedBox(height: 10);
    if (i < 3 + expired.length) {
      return _CouponCard(
        coupon: expired[i - 3],
        isExpired: true,
        isTab: isTab,
      );
    }
  }
  return const SizedBox.shrink();
}

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
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: Text(
          'Ưu đãi của bạn',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.white,
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
                      message: 'Chưa có danh sách hiển thị',
                      subMessage:
                          'Chưa có mã khuyến mãi công khai từ cửa hàng, hoặc tải danh sách thất bại. Bạn vẫn có thể nhập mã thủ công ở bước thanh toán.',
                    ),
                  ),
                ],
              ),
            );
          }

          final itemCount = _couponListItemCount(available.length, expired.length);

          return RefreshIndicator(
            onRefresh: controller.loadCoupons,
            color: AppColors.primaryOrange,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon, required this.isExpired, this.isTab = false});

  final CouponModel coupon;
  final bool isExpired;
  final bool isTab;

  String get _discountLabel {
    if (coupon.discountType == 'PERCENTAGE') {
      return '${coupon.discountValue.toInt()}%';
    }
    return '${coupon.discountValue.toInt().toVnd()}đ';
  }

  String get _discountDesc {
    if (coupon.discountType == 'PERCENTAGE') {
      final cap = coupon.maxDiscount != null
          ? ' (tối đa ${coupon.maxDiscount!.toInt().toVnd()}đ)'
          : '';
      return 'Giảm ${coupon.discountValue.toInt()}%$cap';
    }
    return 'Giảm ${coupon.discountValue.toInt().toVnd()}đ';
  }

  @override
  Widget build(BuildContext context) {
    final color = isExpired ? AppColors.grey400 : AppColors.primaryOrange;
    final bgColor = isExpired ? AppColors.grey200 : AppColors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: isExpired ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isExpired
                ? null
                : [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left — discount value
                Container(
                  width: 90,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _discountLabel,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon.discountType == 'PERCENTAGE'
                            ? 'GIẢM GIÁ'
                            : 'TIỀN MẶT',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Dashed divider
                _DashedDivider(color: color),
                // Right — info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _discountDesc,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (coupon.minOrderValue != null)
                          Text(
                            'Đơn tối thiểu ${coupon.minOrderValue!.toInt().toVnd()}đ',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textGrey,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          'HSD: ${DateFormat('dd/MM/yyyy').format(coupon.expiresAt)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isExpired
                                ? AppColors.errorRed
                                : AppColors.textGrey,
                          ),
                        ),
                        if (coupon.usageLimit != null) ...[
                          const SizedBox(height: 6),
                          _RemainingBadge(
                            remaining: coupon.usageLimit! - coupon.usedCount,
                            total: coupon.usageLimit!,
                            isExpired: isExpired,
                          ),
                        ],
                        const SizedBox(height: 10),
                        // Code + buttons
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: color,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                coupon.code,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!isExpired) ...[
                              _IconBtn(
                                icon: Icons.copy_rounded,
                                color: color,
                                tooltip: 'Sao chép',
                                onTap: () => _copyCode(context),
                              ),
                              const SizedBox(width: 6),
                              _UseCouponBtn(
                                color: color,
                                onTap: () => _useCoupon(context),
                              ),
                            ],
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
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: coupon.code));
    Get.snackbar(
      'Đã sao chép',
      'Mã "${coupon.code}" đã được sao chép.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successGreen,
      colorText: AppColors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _useCoupon(BuildContext context) {
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
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _UseCouponBtn extends StatelessWidget {
  const _UseCouponBtn({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Dùng ngay',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      child: CustomPaint(
        painter: _DashedLinePainter(color: color),
      ),
    );
  }
}

class _RemainingBadge extends StatelessWidget {
  const _RemainingBadge({
    required this.remaining,
    required this.total,
    required this.isExpired,
  });

  final int remaining;
  final int total;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final isEmpty = remaining <= 0;
    final color = isExpired || isEmpty ? AppColors.grey400 : AppColors.primaryOrange;
    return Row(
      children: [
        Icon(Icons.confirmation_num_outlined, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          isEmpty
              ? 'Đã hết lượt sử dụng'
              : 'Còn lại $remaining/$total lượt',
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    const dashHeight = 5.0;
    const dashSpace = 4.0;
    double y = 0;
    final x = size.width / 2;

    while (y < size.height) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dashHeight), paint);
      y += dashHeight + dashSpace;
    }

    // Circular cutouts
    final cutPaint = Paint()..color = AppColors.grey100;
    canvas.drawCircle(Offset(x, 0), 10, cutPaint);
    canvas.drawCircle(Offset(x, size.height), 10, cutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
