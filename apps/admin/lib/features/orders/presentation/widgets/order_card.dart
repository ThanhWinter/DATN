import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/order_model.dart';
import '../controllers/order_controller.dart';
import 'order_detail_sheet.dart';
import 'order_status_badge.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({required this.order, super.key});

  final OrderModel order;

  String _fmt(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} '
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Get.bottomSheet(
          OrderDetailSheet(order: order),
          backgroundColor: AppColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          isScrollControlled: true,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#${order.id}',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const Spacer(),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    order.paymentMethod == OrderModel.methodZaloPay
                        ? Icons.account_balance_wallet_outlined
                        : Icons.payments_outlined,
                    size: 12,
                    color: order.paymentMethod == OrderModel.methodZaloPay
                        ? Colors.blue
                        : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.paymentMethod == OrderModel.methodZaloPay
                        ? 'Đã thanh toán (ZaloPay)'
                        : 'Thanh toán tiền mặt',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: order.paymentMethod == OrderModel.methodZaloPay
                          ? Colors.blue
                          : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: AppColors.grey600),
                  const SizedBox(width: 4),
                  Text(order.customerName ?? 'Không rõ', style: AppTextStyles.bodyMedium),
                  const SizedBox(width: 12),
                  const Icon(Icons.phone_outlined, size: 14, color: AppColors.grey600),
                  const SizedBox(width: 4),
                  Text(order.customerPhone ?? '', style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.grey600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.deliveryAddress,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.grey600),
                  const SizedBox(width: 4),
                  Text(_fmt(order.orderDate), style: AppTextStyles.bodySmall),
                  const Spacer(),
                  Text(
                    '${order.totalAmount.toInt().toVnd()}đ',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primaryOrange,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              if (_nextStatus(order.status) != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Get.find<OrderController>()
                        .updateStatus(order, _nextStatus(order.status)!),
                    child: Text(
                      '→ ${OrderModel.statusLabel(_nextStatus(order.status)!)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
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
