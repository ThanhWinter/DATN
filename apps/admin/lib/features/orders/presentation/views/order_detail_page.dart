import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/order_model.dart';
import '../controllers/order_detail_controller.dart';
import '../widgets/order_status_badge.dart';

class OrderDetailPage extends GetView<OrderDetailController> {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onSuccess: () => Obx(() {
          final order = controller.order.value;
          if (order == null) return const SizedBox.shrink();
          return _OrderDetailBody(order: order, ctrl: controller);
        }),
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({required this.order, required this.ctrl});

  final OrderModel order;
  final OrderDetailController ctrl;

  String _fmt(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} '
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String? _nextStatus(String s) => switch (s) {
        OrderModel.statusPaid => OrderModel.statusPreparing,
        OrderModel.statusPreparing => OrderModel.statusDelivering,
        OrderModel.statusDelivering => OrderModel.statusCompleted,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(title: '', children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Đơn #${order.id.substring(0, 8).toUpperCase()}',
                    style: AppTextStyles.h3,
                  ),
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),
          ]),
          const SizedBox(height: 12),
          _Section(title: 'Khách hàng', children: [
            _InfoRow(
                icon: Icons.person_outline,
                text: order.customerName ?? 'Không rõ'),
            _InfoRow(
                icon: Icons.phone_outlined, text: order.customerPhone ?? ''),
            _InfoRow(
                icon: Icons.location_on_outlined, text: order.deliveryAddress),
            _InfoRow(icon: Icons.access_time, text: _fmt(order.orderDate)),
            if (order.note != null)
              _InfoRow(
                  icon: Icons.sticky_note_2_outlined, text: order.note!),
            if (order.couponCode != null)
              _InfoRow(
                icon: Icons.local_offer_outlined,
                text: 'Coupon: ${order.couponCode}',
                color: AppColors.successGreen,
              ),
            if (order.discountAmount > 0)
              _InfoRow(
                icon: Icons.discount_outlined,
                text: 'Giảm giá: -${order.discountAmount.toInt().toVnd()}đ',
                color: AppColors.successGreen,
              ),
          ]),
          const SizedBox(height: 12),
          _Section(title: 'Món đã đặt', children: [
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: AppTextStyles.bodyMedium),
                          if (item.options.isNotEmpty)
                            Text(item.optionsLabel,
                                style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      '${(item.unitPrice * item.quantity).toInt().toVnd()}đ',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            if (order.discountAmount > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tạm tính', style: AppTextStyles.bodyMedium),
                  Text(
                    '${(order.totalAmount + order.discountAmount).toInt().toVnd()}đ',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.couponCode != null ? 'Mã ${order.couponCode}' : 'Giảm giá',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.successGreen),
                  ),
                  Text(
                    '-${order.discountAmount.toInt().toVnd()}đ',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.successGreen),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng', style: AppTextStyles.labelLarge),
                Text(
                  '${order.totalAmount.toInt().toVnd()}đ',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primaryOrange,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 20),
          if (_nextStatus(order.status) != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () =>
                    ctrl.updateStatus(_nextStatus(order.status)!),
                child: Text(
                  'Chuyển sang: ${OrderModel.statusLabel(_nextStatus(order.status)!)}',
                  style: AppTextStyles.button,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (order.status == OrderModel.statusPending ||
              order.status == OrderModel.statusPaid)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.errorRed,
                  side: const BorderSide(color: AppColors.errorRed),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () =>
                    ctrl.updateStatus(OrderModel.statusCancelled),
                child: const Text('Huỷ đơn hàng'),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 10),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color ?? AppColors.grey600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodyMedium.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
