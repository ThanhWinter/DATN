import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../coupons/presentation/views/coupon_view.dart';
import '../../../customers/presentation/views/customer_view.dart';
import '../../../menu/presentation/views/menu_view.dart';
import '../../../orders/presentation/views/order_view.dart';
import '../../../profile/presentation/views/profile_view.dart';
import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  Widget _buildPage(int index) => switch (index) {
        0 => const MenuView(),
        1 => const OrderView(),
        2 => const CouponView(),
        3 => const CustomerView(),
        _ => const ProfileView(),
      };

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: _buildPage(controller.currentIndex.value),
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: controller.changePage,
            backgroundColor: AppColors.white,
            indicatorColor: AppColors.primaryOrange.withValues(alpha: 0.12),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon:
                    Icon(Icons.restaurant_menu, color: AppColors.primaryOrange),
                label: 'Thực đơn',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon:
                    Icon(Icons.receipt_long, color: AppColors.primaryOrange),
                label: 'Đơn hàng',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_offer_outlined),
                selectedIcon:
                    Icon(Icons.local_offer, color: AppColors.primaryOrange),
                label: 'Khuyến mãi',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people, color: AppColors.primaryOrange),
                label: 'Khách hàng',
              ),
              NavigationDestination(
                icon: Icon(Icons.manage_accounts_outlined),
                selectedIcon: Icon(Icons.manage_accounts,
                    color: AppColors.primaryOrange),
                label: 'Hồ sơ',
              ),
            ],
          ),
        ));
  }
}
