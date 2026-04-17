import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core_ui/core_ui.dart'; 
import '../controllers/order_controller.dart';
import '../../data/models/order_model.dart';
// Note: Assuming CurrencyFormatExt is available globally via core_ui
// If it requires explicit import depending on the structure, we can import core_ui.dart

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.grey100,
        appBar: AppBar(
          title: const Text('Đơn hàng của tôi', style: AppTextStyles.h2),
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppColors.primaryOrange,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.primaryOrange,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [
              Tab(text: 'Đang giao'),
              Tab(text: 'Lịch sử'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            );
          }
          
          return TabBarView(
            children: [
              _buildOrderList(controller.activeOrders, true),
              _buildOrderList(controller.historyOrders, false),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, bool isActive) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.motorcycle_outlined : Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'Không có đơn hàng nào đang giao' : 'Chưa có lịch sử đơn hàng',
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
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
              _buildStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(order.orderDate),
            style: AppTextStyles.bodySmall,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.grey300, height: 1),
          ),
          // Items
          ...order.itemsSummary.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppColors.grey400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item, style: AppTextStyles.bodyMedium),
                    ),
                  ],
                ),
              )),
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
                    style: AppTextStyles.h3.copyWith(color: AppColors.primaryOrange),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: order.status == 'active' ? AppColors.white : AppColors.primaryOrange,
                  foregroundColor: order.status == 'active' ? AppColors.primaryOrange : AppColors.white,
                  elevation: 0,
                  side: order.status == 'active' ? const BorderSide(color: AppColors.primaryOrange) : BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  order.status == 'active' ? 'Xem chi tiết' : 'Đặt lại',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: order.status == 'active' ? AppColors.primaryOrange : AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'active':
        bgColor = AppColors.primaryOrange.withValues(alpha: 0.15);
        textColor = AppColors.primaryOrangeDark;
        label = 'Đang giao';
        break;
      case 'completed':
        bgColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green[800]!;
        label = 'Hoàn thành';
        break;
      case 'cancelled':
        bgColor = AppColors.errorRed.withValues(alpha: 0.15);
        textColor = AppColors.errorRed;
        label = 'Đã hủy';
        break;
      default:
        bgColor = AppColors.grey300;
        textColor = AppColors.grey600;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute - $day/$month/$year';
  }
}
