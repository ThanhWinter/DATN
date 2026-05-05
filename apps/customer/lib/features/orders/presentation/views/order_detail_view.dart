import 'package:core_ui/core_ui.dart';
import 'package:core_utils/core_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../data/models/order_item_model.dart';
import '../../data/models/order_model.dart';
import '../controllers/order_detail_controller.dart';

class OrderDetailView extends GetView<OrderDetailController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: Text(
          'Chi tiết đơn hàng',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Get.back,
        ),
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onSuccess: () => Obx(() {
          final order = controller.order.value;
          if (order == null) return const SizedBox.shrink();
          return _OrderDetailContent(order: order, controller: controller);
        }),
      ),
    );
  }
}

class _OrderDetailContent extends StatelessWidget {
  const _OrderDetailContent({required this.order, required this.controller});

  final OrderModel order;
  final OrderDetailController controller;

  static const _cancellableStatuses = {'PENDING'};

  @override
  Widget build(BuildContext context) {
    final isPending = order.status.toUpperCase() == 'PENDING';
    final isCancellable = _cancellableStatuses.contains(order.status.toUpperCase());
    final idShort = order.id.length >= 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id.toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Mã đơn + trạng thái ──────────────────────────────────────────
          _Card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mã đơn hàng', style: AppTextStyles.bodySmall),
                      const SizedBox(height: 2),
                      Text(
                        '#$idShort',
                        style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.id,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusBadge(status: order.status),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Thời gian + địa chỉ ──────────────────────────────────────────
          _Card(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.access_time_outlined,
                  label: 'Thời gian đặt',
                  value: formatOrderDate(order.orderDate),
                ),
                if (order.deliveryAddress.isNotEmpty) ...[
                  const Divider(color: AppColors.grey200, height: 20),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Địa chỉ giao hàng',
                    value: order.deliveryAddress,
                  ),
                ],
                if (order.note != null && order.note!.isNotEmpty) ...[
                  const Divider(color: AppColors.grey200, height: 20),
                  _InfoRow(
                    icon: Icons.notes_outlined,
                    label: 'Ghi chú',
                    value: order.note!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Danh sách món ────────────────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Danh sách món', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                ...order.orderItems.map((item) => _OrderItemRow(item: item)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Tổng tiền ────────────────────────────────────────────────────
          _Card(
            child: Column(
              children: [
                if (order.discountAmount > 0 || order.shippingFee > 0) ...[
                  if (order.discountAmount > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tạm tính', style: AppTextStyles.bodyMedium),
                        Text(
                          '${(order.totalAmount + order.discountAmount - order.shippingFee).toVnd()} ₫',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_offer_outlined,
                                size: 14, color: AppColors.successGreen),
                            const SizedBox(width: 4),
                            Text(
                              order.couponCode != null
                                  ? 'Mã ${order.couponCode}'
                                  : 'Giảm giá',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.successGreen),
                            ),
                          ],
                        ),
                        Text(
                          '-${order.discountAmount.toVnd()} ₫',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.successGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (order.shippingFee > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.delivery_dining_outlined,
                                size: 14, color: AppColors.primaryOrange),
                            SizedBox(width: 4),
                            Text('Phí giao hàng',
                                style: AppTextStyles.bodyMedium),
                          ],
                        ),
                        Text(
                          '+${order.shippingFee.toVnd()} ₫',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  const Divider(height: 16, color: AppColors.grey200),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng cộng', style: AppTextStyles.h3),
                    Text(
                      '${order.totalAmount.toVnd()} ₫',
                      style: AppTextStyles.h2.copyWith(color: AppColors.primaryOrange),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Nút hành động ────────────────────────────────────────────────
          Obx(() {
            final loading = controller.isMutating.value;
            return Column(
              children: [
                if (isPending) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: loading ? null : controller.retryPayment,
                      icon: loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Icon(Icons.payment_outlined,
                              color: AppColors.white),
                      label: const Text('Thanh toán ngay',
                          style: AppTextStyles.bodyLarge),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                if (isCancellable) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: loading
                          ? null
                          : () => _confirmCancel(context),
                      icon: const Icon(Icons.cancel_outlined,
                          color: AppColors.errorRed),
                      label: const Text('Huỷ đơn hàng'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(color: AppColors.errorRed),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                if (order.status.toUpperCase() == 'COMPLETED') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed(
                        AppRoutes.reviewOrder,
                        arguments: {
                          'orderId': order.id,
                          'items': order.orderItems,
                        },
                      ),
                      icon: const Icon(Icons.star_rounded, color: AppColors.white),
                      label: const Text('Đánh giá đơn hàng',
                          style: AppTextStyles.bodyLarge),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Huỷ đơn hàng?'),
        content: const Text('Bạn có chắc muốn huỷ đơn này không?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.cancelOrder();
            },
            child: const Text(
              'Huỷ đơn',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.quantity}x',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.foodName, style: AppTextStyles.bodyLarge),
                if (item.selectedOptions.isNotEmpty)
                  Text(
                    item.selectedOptions.join(', '),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primaryOrange),
                  ),
              ],
            ),
          ),
          Text(
            '${item.totalPrice.toVnd()} ₫',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.primaryOrangeDark),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryOrange),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: AppTextStyles.bodySmall.copyWith(
          color: _fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String get _label {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Chờ thanh toán';
      case 'PAID':
        return 'Đã thanh toán';
      case 'PREPARING':
        return 'Đang chuẩn bị';
      case 'DELIVERING':
        return 'Đang giao';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color get _bg {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.primaryOrange.withValues(alpha: 0.15);
      case 'PAID':
        return Colors.blue.withValues(alpha: 0.12);
      case 'PREPARING':
      case 'DELIVERING':
        return AppColors.primaryOrange.withValues(alpha: 0.15);
      case 'COMPLETED':
        return Colors.green.withValues(alpha: 0.15);
      case 'CANCELLED':
        return AppColors.errorRed.withValues(alpha: 0.15);
      default:
        return AppColors.grey300;
    }
  }

  Color get _fg {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'PREPARING':
      case 'DELIVERING':
        return AppColors.primaryOrangeDark;
      case 'PAID':
        return Colors.blue[700]!;
      case 'COMPLETED':
        return Colors.green[800]!;
      case 'CANCELLED':
        return AppColors.errorRed;
      default:
        return AppColors.grey600;
    }
  }
}
