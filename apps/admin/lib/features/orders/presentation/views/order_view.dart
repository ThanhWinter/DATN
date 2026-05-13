import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/order_model.dart';
import '../controllers/order_controller.dart';
import '../widgets/order_card.dart';

class OrderView extends StatelessWidget {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OrderController>();
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Đơn hàng', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Obx(() => _FilterBar(
                selected: c.selectedFilter.value,
                allCount: c.pendingOrders.length + c.activeOrders.length,
                pendingCount: c.pendingOrders.length,
                activeCount: c.activeOrders.length,
                onSelect: (f) => _onFilterSelect(c, f),
              )),
        ),
      ),
      body: SnapHelperWidget(
        isLoading: c.isLoading,
        error: c.error,
        onRefresh: c.loadOrders,
        onSuccess: () => Obx(() {
          final filter = c.selectedFilter.value;

          // On-demand loading indicator cho completed / cancelled
          if (c.loadingTabIndex.value != null &&
              (filter == 'completed' || filter == 'cancelled')) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            );
          }

          final orders = _ordersForFilter(c, filter);
          return RefreshIndicator(
            onRefresh: c.loadOrders,
            color: AppColors.primaryOrange,
            child: orders.isEmpty
                ? CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        child: AppEmptyState(
                          icon: Icons.receipt_long_outlined,
                          message: _emptyMsg(filter),
                        ),
                      ),
                    ],
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n.metrics.pixels >=
                          n.metrics.maxScrollExtent - 140) {
                        c.loadMoreForFilter(filter);
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
        }),
      ),
    );
  }

  void _onFilterSelect(OrderController c, String filter) {
    c.selectedFilter.value = filter;
    if (filter == 'completed' && !c.isTabLoaded(2)) {
      c.loadTabOnDemand(2);
    } else if (filter == 'cancelled' && !c.isTabLoaded(3)) {
      c.loadTabOnDemand(3);
    }
  }

  List<OrderModel> _ordersForFilter(OrderController c, String filter) {
    switch (filter) {
      case 'pending':
        return c.pendingOrders.toList();
      case 'active':
        return c.activeOrders.toList();
      case 'completed':
        return c.completedOrders.toList();
      case 'cancelled':
        return c.cancelledOrders.toList();
      default: // 'all'
        final merged = [...c.pendingOrders, ...c.activeOrders];
        merged.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        return merged;
    }
  }

  String _emptyMsg(String filter) => switch (filter) {
        'pending' => 'Không có đơn chờ xác nhận',
        'active' => 'Không có đơn đang xử lý',
        'completed' => 'Chưa có đơn hoàn thành',
        'cancelled' => 'Không có đơn bị huỷ',
        _ => 'Không có đơn hàng đang hoạt động',
      };
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selected,
    required this.allCount,
    required this.pendingCount,
    required this.activeCount,
    required this.onSelect,
  });

  final String selected;
  final int allCount;
  final int pendingCount;
  final int activeCount;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        children: [
          _Chip(
            label: 'Đang chạy',
            count: allCount,
            value: 'all',
            selected: selected,
            onTap: onSelect,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Chờ xác nhận',
            count: pendingCount,
            value: 'pending',
            selected: selected,
            onTap: onSelect,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Đang xử lý',
            count: activeCount,
            value: 'active',
            selected: selected,
            onTap: onSelect,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Hoàn thành',
            count: 0,
            value: 'completed',
            selected: selected,
            onTap: onSelect,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Đã huỷ',
            count: 0,
            value: 'cancelled',
            selected: selected,
            onTap: onSelect,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.count,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : AppColors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : AppColors.grey300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.white : AppColors.textGrey,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.28)
                      : AppColors.primaryOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.primaryOrange,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
