import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../data/models/order_model.dart';

// Status background colors
const _bgPending = Color(0xFFFFF3E0);
const _bgPaid = Color(0xFFE3F2FD);
const _bgPreparing = Color(0xFFF3E5F5);
const _bgDelivering = Color(0xFFE0F7FA);
const _bgCompleted = Color(0xFFE8F5E9);
const _bgCancelled = Color(0xFFFFEBEE);

// Status foreground colors
const _fgPending = Color(0xFFE65100);
const _fgPaid = Color(0xFF1565C0);
const _fgPreparing = Color(0xFF6A1B9A);
const _fgDelivering = Color(0xFF006064);
const _fgCompleted = Color(0xFF2E7D32);
const _fgCancelled = Color(0xFFC62828);

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({required this.status, super.key});

  final String status;

  Color get _bg => switch (status) {
        OrderModel.statusPending => _bgPending,
        OrderModel.statusPaid => _bgPaid,
        OrderModel.statusPreparing => _bgPreparing,
        OrderModel.statusDelivering => _bgDelivering,
        OrderModel.statusCompleted => _bgCompleted,
        OrderModel.statusCancelled => _bgCancelled,
        _ => AppColors.grey100,
      };

  Color get _fg => switch (status) {
        OrderModel.statusPending => _fgPending,
        OrderModel.statusPaid => _fgPaid,
        OrderModel.statusPreparing => _fgPreparing,
        OrderModel.statusDelivering => _fgDelivering,
        OrderModel.statusCompleted => _fgCompleted,
        OrderModel.statusCancelled => _fgCancelled,
        _ => AppColors.textGrey,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        OrderModel.statusLabel(status),
        style: AppTextStyles.bodySmall.copyWith(
          color: _fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
