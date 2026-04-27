import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/order_controller.dart';
import '../widgets/order_list_section.dart';

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
            unselectedLabelStyle:
                AppTextStyles.bodyMedium.copyWith(fontSize: 15),
            tabs: const [
              Tab(text: 'Đang giao'),
              Tab(text: 'Lịch sử'),
            ],
          ),
        ),
        body: SnapHelperWidget(
          isLoading: controller.isLoading,
          error: controller.error,
          onRetry: controller.loadOrders,
          onSuccess: () => TabBarView(
            children: [
              Obx(() => OrderListSection(
                    orders: controller.activeOrders.toList(),
                    emptyIcon: Icons.motorcycle_outlined,
                    emptyMessage: 'Không có đơn hàng đang giao',
                    onOrderTap: controller.navigateToDetail,
                  )),
              Obx(() => OrderListSection(
                    orders: controller.historyOrders.toList(),
                    emptyIcon: Icons.receipt_long_outlined,
                    emptyMessage: 'Chưa có đơn hàng nào',
                    onOrderTap: controller.navigateToDetail,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
