import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/order_model.dart';
import '../controllers/order_controller.dart';
import '../widgets/order_card.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.grey100,
        appBar: AppBar(
          title: Text(
            'Đơn hàng của bạn',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          backgroundColor: AppColors.primaryOrange,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.white),
          bottom: TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white,
            indicatorColor: AppColors.white,
            indicatorWeight: 3,
            labelStyle: AppTextStyles.bodyMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
              fontSize: 15,
            ),
            tabs: const [
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
              _OrderList(
                orders: controller.activeOrders,
                emptyIcon: Icons.motorcycle_outlined,
                emptyMessage: 'Không có đơn hàng đang giao',
              ),
              _OrderList(
                orders: controller.historyOrders,
                emptyIcon: Icons.receipt_long_outlined,
                emptyMessage: 'Chưa có đơn hàng nào',
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  final IconData emptyIcon;
  final String emptyMessage;

  const _OrderList({
    required this.orders,
    required this.emptyIcon,
    required this.emptyMessage,
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
        onActionPressed: () {},
      ),
    );
  }
}
