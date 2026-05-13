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
    final nextSt = _nextStatus(order.status);
    final canCancel = order.status == OrderModel.statusPending ||
        order.status == OrderModel.statusPaid;

    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Thanh màu trái thể hiện trạng thái ──
              Container(width: 4, color: _accentColor(order.status)),
              // ── Nội dung ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: mã đơn + badge
                      Row(
                        children: [
                          Text(
                            '#${order.id.substring(0, 8).toUpperCase()}',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primaryOrange,
                            ),
                          ),
                          const Spacer(),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Khách hàng + số điện thoại
                      Row(
                        children: [
                          const Icon(Icons.person_outline,
                              size: 14, color: AppColors.grey600),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              order.customerName ?? 'Không rõ',
                              style: AppTextStyles.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.phone_outlined,
                              size: 14, color: AppColors.grey600),
                          const SizedBox(width: 4),
                          Text(order.customerPhone ?? '',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Địa chỉ
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.grey600),
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
                      // Thời gian + tổng tiền
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 14, color: AppColors.grey600),
                          const SizedBox(width: 4),
                          Text(_fmt(order.orderDate),
                              style: AppTextStyles.bodySmall),
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
                      // Nút hành động
                      if (nextSt != null || canCancel) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (nextSt != null)
                              Expanded(
                                flex: canCancel ? 3 : 1,
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 15),
                                  label: Text(_actionLabel(nextSt)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _actionColor(nextSt),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 38),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    textStyle: AppTextStyles.bodySmall
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  onPressed: () => Get.find<OrderController>()
                                      .updateStatus(order, nextSt),
                                ),
                              ),
                            if (nextSt != null && canCancel)
                              const SizedBox(width: 8),
                            if (canCancel)
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.errorRed,
                                    side: BorderSide(
                                      color: AppColors.errorRed
                                          .withValues(alpha: 0.5),
                                    ),
                                    minimumSize: const Size(0, 38),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    textStyle: AppTextStyles.bodySmall
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  onPressed: _confirmCancel,
                                  child: const Text('Huỷ'),
                                ),
                              ),
                          ],
                        ),
                      ],
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

  void _confirmCancel() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Huỷ đơn hàng?'),
        content: Text(
          'Xác nhận huỷ đơn #${order.id.substring(0, 8).toUpperCase()}?',
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Không',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            onPressed: () {
              Get.back();
              Get.find<OrderController>()
                  .updateStatus(order, OrderModel.statusCancelled);
            },
            child: const Text(
              'Huỷ đơn',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  String? _nextStatus(String current) => switch (current) {
        OrderModel.statusPaid => OrderModel.statusPreparing,
        OrderModel.statusPreparing => OrderModel.statusDelivering,
        OrderModel.statusDelivering => OrderModel.statusCompleted,
        _ => null,
      };

  String _actionLabel(String nextStatus) => switch (nextStatus) {
        OrderModel.statusPreparing => 'Bắt đầu chuẩn bị',
        OrderModel.statusDelivering => 'Bắt đầu giao hàng',
        OrderModel.statusCompleted => 'Hoàn thành đơn',
        _ => OrderModel.statusLabel(nextStatus),
      };

  // Màu nút = màu của trạng thái đích để admin hiểu rõ sẽ chuyển đến đâu
  Color _actionColor(String nextStatus) => switch (nextStatus) {
        OrderModel.statusPreparing => const Color(0xFF6A1B9A),
        OrderModel.statusDelivering => const Color(0xFF006064),
        OrderModel.statusCompleted => const Color(0xFF2E7D32),
        _ => AppColors.primaryOrange,
      };

  // Thanh màu trái phản ánh trạng thái hiện tại
  Color _accentColor(String status) => switch (status) {
        OrderModel.statusPending => const Color(0xFFE65100),
        OrderModel.statusPaid => const Color(0xFF1565C0),
        OrderModel.statusPreparing => const Color(0xFF6A1B9A),
        OrderModel.statusDelivering => const Color(0xFF006064),
        OrderModel.statusCompleted => const Color(0xFF2E7D32),
        OrderModel.statusCancelled => const Color(0xFFC62828),
        _ => AppColors.grey300,
      };
}
