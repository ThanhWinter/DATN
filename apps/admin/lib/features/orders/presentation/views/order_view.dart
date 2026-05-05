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
            labelStyle:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
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
                  _OrderList(
                    orders: controller.pendingOrders.toList(),
                    emptyMsg: 'Không có đơn chờ xác nhận',
                    onRefresh: controller.loadOrders,
                    onNearEnd: () => controller.loadMoreForTab(0),
                  ),
                  _OrderList(
                    orders: controller.activeOrders.toList(),
                    emptyMsg: 'Không có đơn đang xử lý',
                    onRefresh: controller.loadOrders,
                    onNearEnd: () => controller.loadMoreForTab(1),
                  ),
                  _OrderList(
                    orders: controller.completedOrders.toList(),
                    emptyMsg: 'Chưa có đơn hoàn thành',
                    onRefresh: controller.loadOrders,
                    onNearEnd: () => controller.loadMoreForTab(2),
                  ),
                  _OrderList(
                    orders: controller.cancelledOrders.toList(),
                    emptyMsg: 'Không có đơn bị huỷ',
                    onRefresh: controller.loadOrders,
                    onNearEnd: () => controller.loadMoreForTab(3),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.orders,
    required this.emptyMsg,
    required this.onRefresh,
    required this.onNearEnd,
  });

  final List orders;
  final String emptyMsg;
  final Future<void> Function() onRefresh;
  final VoidCallback onNearEnd;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primaryOrange,
      child: orders.isEmpty
          ? CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: emptyMsg,
                  ),
                ),
              ],
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification n) {
                if (n.metrics.pixels >= n.metrics.maxScrollExtent - 140) {
                  onNearEnd();
                }
                return false;
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => OrderCard(order: orders[i]),
              ),
            ),
    );
  }
}
