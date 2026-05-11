import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/coupon_model.dart';
import '../controllers/coupon_controller.dart';
import '../widgets/add_coupon_sheet.dart';
import '../widgets/edit_coupon_sheet.dart';

class CouponView extends GetView<CouponController> {
  const CouponView({super.key});

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Khuyến mãi', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tạo mã'),
        onPressed: () => Get.bottomSheet(
          const AddCouponSheet(),
          backgroundColor: AppColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          isScrollControlled: true,
        ),
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onRefresh: controller.loadCoupons,
        onSuccess: () => RefreshIndicator(
          onRefresh: controller.loadCoupons,
          color: AppColors.primaryOrange,
          child: Obx(() => controller.coupons.isEmpty
              ? const CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      child: AppEmptyState(
                        icon: Icons.local_offer_outlined,
                        message: 'Chưa có mã khuyến mãi',
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: controller.coupons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _CouponCard(
                      coupon: controller.coupons[i], fmtDate: _fmtDate),
                )),
        ),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon, required this.fmtDate});

  final CouponModel coupon;
  final String Function(DateTime) fmtDate;

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xoá mã khuyến mãi', style: AppTextStyles.h3),
        content: Text(
          'Xoá mã "${coupon.code}"? Hành động này không thể hoàn tác.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Huỷ',
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.find<CouponController>().deleteCoupon(coupon.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }

  void _openEdit() {
    Get.bottomSheet(
      EditCouponSheet(coupon: coupon),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final expired = coupon.isExpired;
    final exhausted =
        coupon.usageLimit != null && coupon.usedCount >= coupon.usageLimit!;
    final active = !expired && !exhausted;

    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primaryOrange.withValues(alpha: 0.1)
                        : AppColors.grey200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          active ? AppColors.primaryOrange : AppColors.grey300,
                    ),
                  ),
                  child: Text(
                    coupon.code,
                    style: AppTextStyles.labelLarge.copyWith(
                      color:
                          active ? AppColors.primaryOrange : AppColors.grey600,
                      fontFamily: 'monospace',
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const Spacer(),
                _StatusBadge(
                  label: expired
                      ? 'Hết hạn'
                      : exhausted
                          ? 'Hết lượt'
                          : 'Đang dùng',
                  color: active ? AppColors.successGreen : AppColors.errorRed,
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton.outlined(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    color: AppColors.primaryOrange,
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryOrange),
                    ),
                    onPressed: _openEdit,
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton.outlined(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    color: AppColors.errorRed,
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: AppColors.errorRed),
                    ),
                    onPressed: _confirmDelete,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.discount_outlined,
                  label: 'Giảm ${coupon.displayValue}',
                  color: AppColors.primaryOrange,
                ),
                if (coupon.minOrderValue != null) ...[
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Từ ${coupon.minOrderValue!.toInt().toVnd()}đ',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.grey600),
                const SizedBox(width: 4),
                Text('HSD: ${fmtDate(coupon.expiresAt)}',
                    style: AppTextStyles.bodySmall),
                const Spacer(),
                if (coupon.usageLimit != null) ...[
                  const Icon(Icons.people_outline,
                      size: 14, color: AppColors.grey600),
                  const SizedBox(width: 4),
                  Text(
                    '${coupon.usedCount}/${coupon.usageLimit} lượt',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ],
            ),
            if (coupon.usageLimit != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: coupon.usedCount / coupon.usageLimit!,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation(
                    active ? AppColors.primaryOrange : AppColors.grey400,
                  ),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          )),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? AppColors.textGrey).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? AppColors.grey600),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color ?? AppColors.textGrey,
              )),
        ],
      ),
    );
  }
}
