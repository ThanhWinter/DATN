import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../coupons/presentation/views/coupon_list_view.dart';
import '../../../home/presentation/views/home_view.dart';
import '../../../orders/presentation/views/order_view.dart';
import '../../../profile/presentation/views/profile_view.dart';
import '../controllers/main_controller.dart';

// Chỉ build tab khi user lần đầu chạm vào, giữ state sau đó.
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

// ── MainView ──────────────────────────────────────────────────────────────────

class MainView extends GetView<MainController> {
  const MainView({super.key});

  // Tab layout: Thực đơn | Ưu đãi | Đơn hàng | Tài khoản
  static const _tabs = [
    HomeView(),
    CouponListView(isTab: true),
    OrderView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Obx(
        () => _LazyIndexedStack(
          index: controller.selectedIndex.value,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: _BottomBar(controller: controller),
    );
  }
}

// ── Bottom Bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final MainController controller;
  const _BottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedIndex.value;
      final orderCount = controller.activeOrderBadgeCount.value;
      final couponCount = controller.availableCouponCount.value;

      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                // ── Thực đơn ────────────────────────────────────────────
                _NavItem(
                  svgAsset: AppIcons.homeSvg,
                  label: 'Trang chủ',
                  isSelected: selected == 0,
                  onTap: () => controller.onTabChanged(0),
                ),

                // ── Ưu đãi ──────────────────────────────────────────────
                _NavItem(
                  svgAsset: AppIcons.sellSvg,
                  label: 'Ưu đãi',
                  isSelected: selected == 1,
                  badge: couponCount,
                  onTap: () => controller.onTabChanged(1),
                ),

                // ── Đơn hàng ────────────────────────────────────────────
                _NavItem(
                  svgAsset: AppIcons.orderSvg,
                  label: 'Đơn hàng',
                  isSelected: selected == 2,
                  badge: orderCount,
                  onTap: () => controller.onTabChanged(2),
                ),

                // ── Tài khoản ────────────────────────────────────────────
                _NavItem(
                  svgAsset: AppIcons.accountSvg,
                  label: 'Tài khoản',
                  isSelected: selected == 3,
                  onTap: () => controller.onTabChanged(3),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final String svgAsset;
  final String label;
  final bool isSelected;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.svgAsset,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primaryOrange : AppColors.textGrey;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  svgAsset,
                  width: 22,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
                if (badge > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 15, minHeight: 15),
                      alignment: Alignment.center,
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
