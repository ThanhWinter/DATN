import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../coupons/presentation/views/coupon_view.dart';
import '../../../customers/presentation/views/customer_view.dart';
import '../../../menu/presentation/views/menu_view.dart';
import '../../../orders/presentation/views/order_view.dart';
import '../../../profile/presentation/views/profile_view.dart';
import '../controllers/main_controller.dart';

// Chỉ build tab khi user lần đầu chạm vào, giữ state sau đó —
// tránh unmount+remount toàn bộ widget tree mỗi lần đổi tab.
class _LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const _LazyIndexedStack({required this.index, required this.children});

  @override
  State<_LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<_LazyIndexedStack> {
  late List<bool> _activated;

  @override
  void initState() {
    super.initState();
    _activated = List.filled(widget.children.length, false);
  }

  @override
  Widget build(BuildContext context) {
    _activated[widget.index] = true;
    return IndexedStack(
      index: widget.index,
      children: List.generate(widget.children.length, (i) {
        return _activated[i] ? widget.children[i] : const SizedBox.shrink();
      }),
    );
  }
}

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => _LazyIndexedStack(
          index: controller.currentIndex.value,
          children: const [
            MenuView(),
            OrderView(),
            CouponView(),
            CustomerView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () {
          final pendingCount = controller.pendingOrderBadgeCount.value;
          return NavigationBar(
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: controller.changePage,
            backgroundColor: AppColors.white,
            indicatorColor: AppColors.primaryOrange.withValues(alpha: 0.12),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon:
                    Icon(Icons.restaurant_menu, color: AppColors.primaryOrange),
                label: 'Thực đơn',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text('$pendingCount'),
                  child: const Icon(Icons.receipt_long_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text('$pendingCount'),
                  child: const Icon(Icons.receipt_long,
                      color: AppColors.primaryOrange),
                ),
                label: 'Đơn hàng',
              ),
              const NavigationDestination(
                icon: Icon(Icons.local_offer_outlined),
                selectedIcon:
                    Icon(Icons.local_offer, color: AppColors.primaryOrange),
                label: 'Khuyến mãi',
              ),
              const NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon:
                    Icon(Icons.people, color: AppColors.primaryOrange),
                label: 'Người dùng',
              ),
              const NavigationDestination(
                icon: Icon(Icons.manage_accounts_outlined),
                selectedIcon:
                    Icon(Icons.manage_accounts, color: AppColors.primaryOrange),
                label: 'Hồ sơ',
              ),
            ],
          );
        },
      ),
    );
  }
}
