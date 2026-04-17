import 'package:core_ui/core_ui.dart';
import 'package:core_utils/core_utils.dart';
import 'package:flutter/material.dart';

import '../../data/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onActionPressed;

  const OrderCard({
    super.key,
    required this.order,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
              ),
              _OrderStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(formatOrderDate(order.orderDate), style: AppTextStyles.bodySmall),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.grey300, height: 1),
          ),
          ...order.itemsSummary.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: AppColors.grey400),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: AppTextStyles.bodyMedium)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tổng cộng', style: AppTextStyles.bodySmall),
                  Text(
                    '${order.totalAmount.toVnd()} ₫',
                    style:
                        AppTextStyles.h3.copyWith(color: AppColors.primaryOrange),
                  ),
                ],
              ),
              _buildActionButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final isActive = order.status == 'active';
    return ElevatedButton(
      onPressed: onActionPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? AppColors.white : AppColors.primaryOrange,
        foregroundColor: isActive ? AppColors.primaryOrange : AppColors.white,
        elevation: 0,
        side: isActive
            ? const BorderSide(color: AppColors.primaryOrange)
            : BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        isActive ? 'Xem chi tiết' : 'Đặt lại',
        style: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w700,
          color: isActive ? AppColors.primaryOrange : AppColors.white,
        ),
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final String status;

  const _OrderStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: AppTextStyles.bodySmall.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String get _label {
    switch (status) {
      case 'active':
        return 'Đang giao';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color get _bgColor {
    switch (status) {
      case 'active':
        return AppColors.primaryOrange.withValues(alpha: 0.15);
      case 'completed':
        return Colors.green.withValues(alpha: 0.15);
      case 'cancelled':
        return AppColors.errorRed.withValues(alpha: 0.15);
      default:
        return AppColors.grey300;
    }
  }

  Color get _textColor {
    switch (status) {
      case 'active':
        return AppColors.primaryOrangeDark;
      case 'completed':
        return Colors.green[800]!;
      case 'cancelled':
        return AppColors.errorRed;
      default:
        return AppColors.grey600;
    }
  }
}
