import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/order_controller.dart';
import '../widgets/order_card.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final OrderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OrderController>();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    // addListener fires on animation frames too; chỉ xử lý khi settle xong.
    if (_tabController.indexIsChanging) return;
    _controller.loadTabOnDemand(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Đơn hàng', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(() => TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primaryOrange,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.primaryOrange,
            labelStyle:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
            tabs: [
              Tab(
                text: _controller.pendingCount > 0
                    ? 'Chờ xác nhận (${_controller.pendingCount})'
                    : 'Chờ xác nhận',
              ),
              Tab(
                text: _controller.activeCount > 0
                    ? 'Đang xử lý (${_controller.activeCount})'
                    : 'Đang xử lý',
              ),
              const Tab(text: 'Hoàn thành'),
              const Tab(text: 'Đã huỷ'),
            ],
          )),
        ),
      ),
      body: SnapHelperWidget(
        isLoading: _controller.isLoading,
        error: _controller.error,
        onSuccess: () => TabBarView(
          controller: _tabController,
          children: [
            Obx(() => _OrderList(
                  orders: _controller.pendingOrders.toList(),
                  emptyMsg: 'Không có đơn chờ xác nhận',
                  onRefresh: _controller.loadOrders,
                  onNearEnd: () => _controller.loadMoreForTab(0),
                )),
            Obx(() {
              if (_controller.loadingTabIndex.value == 1) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryOrange,
                  ),
                );
              }
              return _OrderList(
                orders: _controller.activeOrders.toList(),
                emptyMsg: 'Không có đơn đang xử lý',
                onRefresh: _controller.loadOrders,
                onNearEnd: () => _controller.loadMoreForTab(1),
              );
            }),
            Obx(() {
              if (_controller.loadingTabIndex.value == 2) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryOrange,
                  ),
                );
              }
              return _OrderList(
                orders: _controller.completedOrders.toList(),
                emptyMsg: 'Chưa có đơn hoàn thành',
                onRefresh: _controller.loadOrders,
                onNearEnd: () => _controller.loadMoreForTab(2),
              );
            }),
            Obx(() {
              if (_controller.loadingTabIndex.value == 3) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryOrange,
                  ),
                );
              }
              return _OrderList(
                orders: _controller.cancelledOrders.toList(),
                emptyMsg: 'Không có đơn bị huỷ',
                onRefresh: _controller.loadOrders,
                onNearEnd: () => _controller.loadMoreForTab(3),
              );
            }),
          ],
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
