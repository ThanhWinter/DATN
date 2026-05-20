import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core_ui/core_ui.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_checkout_bar.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Giỏ hàng của bạn',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.cartItems.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 56, color: AppColors.grey300),
                      SizedBox(height: 12),
                      Text('Giỏ hàng trống', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: controller.cartItems.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: AppColors.grey200, height: 1),
                itemBuilder: (_, index) => RepaintBoundary(
                    child: CartItemCard(item: controller.cartItems[index])),
              );
            }),
          ),
          const CartCheckoutBar(),
        ],
      ),
    );
  }
}
