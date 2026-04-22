import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/order_controller.dart';
import '../widgets/order_card.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.grey100,
        appBar: AppBar(
          title: const Text('Đơn hàng', style: AppTextStyles.h3),
          backgroundColor: AppColors.white,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primaryOrange,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.primaryOrange,
            labelStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đang xử lý'),
              Tab(text: 'Hoàn thành'),
              Tab(text: 'Đã huỷ'),
            ],
          ),
        ),
        body: SnapHelperWidget(
          isLoading: controller.isLoading,
          error: controller.error,
          onSuccess: () => Obx(() => TabBarView(
            children: [
              _OrderList(orders: controller.pendingOrders.toList(), emptyMsg: 'Không có đơn chờ xác nhận'),
              _OrderList(orders: controller.activeOrders.toList(), emptyMsg: 'Không có đơn đang xử lý'),
              _OrderList(orders: controller.completedOrders.toList(), emptyMsg: 'Chưa có đơn hoàn thành'),
              _OrderList(orders: controller.cancelledOrders.toList(), emptyMsg: 'Không có đơn bị huỷ'),
            ],
          )),
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders, required this.emptyMsg});

  final List orders;
  final String emptyMsg;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return AppEmptyState(
        icon: Icons.receipt_long_outlined,
        message: emptyMsg,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => OrderCard(order: orders[i]),
    );
  }
}
