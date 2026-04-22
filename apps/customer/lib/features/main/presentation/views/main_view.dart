import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../cart/presentation/views/cart_view.dart';
import '../../../home/presentation/views/home_view.dart';
import '../../../orders/presentation/views/order_view.dart';
import '../../../profile/presentation/views/profile_view.dart';
import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: const [
            HomeView(),
            CartView(),
            OrderView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Obx(() {
      final cartController = Get.find<CartController>();
      final cartCount =
          cartController.cartItems.fold(0, (sum, item) => sum + item.quantity);

      return BottomNavigationBar(
        currentIndex: controller.selectedIndex.value,
        onTap: controller.onTabChanged,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textGrey,
        selectedLabelStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: AppTextStyles.bodySmall.copyWith(fontSize: 11),
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppIcons.homeSvg, width: 22, colorFilter: ColorFilter.mode(AppColors.textGrey, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset(AppIcons.homeSvg, width: 22, colorFilter: ColorFilter.mode(AppColors.primaryOrange, BlendMode.srcIn)),
            label: 'Thực đơn',
          ),
          BottomNavigationBarItem(
            icon: _buildCartIcon(cartCount, isSelected: false),
            activeIcon: _buildCartIcon(cartCount, isSelected: true),
            label: 'Giỏ hàng',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppIcons.orderSvg, width: 22, colorFilter: ColorFilter.mode(AppColors.textGrey, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset(AppIcons.orderSvg, width: 22, colorFilter: ColorFilter.mode(AppColors.primaryOrange, BlendMode.srcIn)),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppIcons.accountSvg, width: 22, colorFilter: ColorFilter.mode(AppColors.textGrey, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset(AppIcons.accountSvg, width: 22, colorFilter: ColorFilter.mode(AppColors.primaryOrange, BlendMode.srcIn)),
            label: 'Tài khoản',
          ),
        ],
      );
    });
  }

  Widget _buildCartIcon(int cartCount, {required bool isSelected}) {
    final color = isSelected ? AppColors.primaryOrange : AppColors.textGrey;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SvgPicture.asset(
          AppIcons.cartSvg,
          width: 22,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        if (cartCount > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.errorRed,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              alignment: Alignment.center,
              child: Text(
                cartCount > 99 ? '99+' : '$cartCount',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
