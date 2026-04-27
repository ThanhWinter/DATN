import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../widgets/order_card.dart';

class OrderListSection extends StatelessWidget {
  final List<OrderModel> orders;
  final IconData emptyIcon;
  final String emptyMessage;
  final void Function(String orderId) onOrderTap;

  const OrderListSection({
    super.key,
    required this.orders,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text(emptyMessage, style: AppTextStyles.bodyLarge),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, index) => OrderCard(
        order: orders[index],
        onActionPressed: () => onOrderTap(orders[index].id),
      ),
    );
  }
}
