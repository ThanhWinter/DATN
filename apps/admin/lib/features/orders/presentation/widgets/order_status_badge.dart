import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../data/models/order_model.dart';

// Status background colors
const _bgPending = Color(0xFFFFF3E0);
const _bgConfirmed = Color(0xFFE3F2FD);
const _bgPreparing = Color(0xFFF3E5F5);
const _bgReady = Color(0xFFE8F5E9);
const _bgDelivered = Color(0xFFE8F5E9);
const _bgCancelled = Color(0xFFFFEBEE);

// Status foreground colors
const _fgPending = Color(0xFFE65100);
const _fgConfirmed = Color(0xFF1565C0);
const _fgPreparing = Color(0xFF6A1B9A);
const _fgReady = Color(0xFF2E7D32);
const _fgDelivered = Color(0xFF2E7D32);
const _fgCancelled = Color(0xFFC62828);

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({required this.status, super.key});

  final String status;

  Color get _bg => switch (status) {
        OrderModel.statusPending => _bgPending,
        OrderModel.statusConfirmed => _bgConfirmed,
        OrderModel.statusPreparing => _bgPreparing,
        OrderModel.statusReady => _bgReady,
        OrderModel.statusDelivered => _bgDelivered,
        OrderModel.statusCancelled => _bgCancelled,
        _ => AppColors.grey100,
      };

  Color get _fg => switch (status) {
        OrderModel.statusPending => _fgPending,
        OrderModel.statusConfirmed => _fgConfirmed,
        OrderModel.statusPreparing => _fgPreparing,
        OrderModel.statusReady => _fgReady,
        OrderModel.statusDelivered => _fgDelivered,
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
