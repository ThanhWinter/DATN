import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/order_model.dart';
import '../controllers/order_controller.dart';
import 'order_status_badge.dart';

class OrderDetailSheet extends StatelessWidget {
  const OrderDetailSheet({required this.order, super.key});

  final OrderModel order;

  String _fmt(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} '
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('Đơn #${order.id}', style: AppTextStyles.h3),
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                children: [
                  _Section(title: 'Khách hàng', children: [
                    _Row(icon: Icons.person_outline, text: order.customerName ?? 'Không rõ'),
                    _Row(icon: Icons.phone_outlined, text: order.customerPhone ?? ''),
                    _Row(icon: Icons.location_on_outlined, text: order.deliveryAddress),
                    _Row(icon: Icons.access_time, text: _fmt(order.orderDate)),
                    _Row(
                      icon: order.paymentMethod == OrderModel.methodZaloPay
                          ? Icons.account_balance_wallet_outlined
                          : Icons.payments_outlined,
                      text: order.paymentMethod == OrderModel.methodZaloPay
                          ? 'Thanh toán: ZaloPay (Đã nhận tiền)'
                          : 'Thanh toán: Tiền mặt (Thu khi giao)',
                      color: order.paymentMethod == OrderModel.methodZaloPay
                          ? Colors.blue
                          : Colors.green,
                    ),
                    if (order.note != null)
                      _Row(icon: Icons.sticky_note_2_outlined, text: order.note!),
                    if (order.couponCode != null)
                      _Row(icon: Icons.local_offer_outlined,
                          text: 'Coupon: ${order.couponCode}',
                          color: AppColors.successGreen),
                  ]),
                  const SizedBox(height: 12),
                  _Section(title: 'Món đã đặt', children: [
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 28, height: 28,
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
                                if (item.options != null)
                                  Text(item.options!,
                                      style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                          Text(
                            '${(item.unitPrice * item.quantity).toInt().toVnd()}đ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )),
                    const Divider(),
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
                  const SizedBox(height: 16),
                  if (_nextStatus(order.status) != null)
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
                        onPressed: () {
                          Get.find<OrderController>()
                              .updateStatus(order, _nextStatus(order.status)!);
                          Get.back();
                        },
                        child: Text(
                          'Chuyển sang: ${OrderModel.statusLabel(_nextStatus(order.status)!)}',
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),
                  if (order.status == OrderModel.statusPending ||
                      order.status == OrderModel.statusPaid) ...[
                    const SizedBox(height: 8),
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
                        onPressed: () {
                          Get.find<OrderController>()
                              .updateStatus(order, OrderModel.statusCancelled);
                          Get.back();
                        },
                        child: const Text('Huỷ đơn hàng'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _nextStatus(String current) => switch (current) {
        OrderModel.statusPending => OrderModel.statusPreparing,
        OrderModel.statusPaid => OrderModel.statusPreparing,
        OrderModel.statusPreparing => OrderModel.statusDelivering,
        OrderModel.statusDelivering => OrderModel.statusCompleted,
        _ => null,
      };
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
          Text(title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textGrey,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.text, this.color});

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
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
