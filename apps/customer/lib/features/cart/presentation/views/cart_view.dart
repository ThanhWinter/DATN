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
            child: SnapHelperWidget(
              isLoading: RxBool(false), // cart không có isLoading thực sự từ controller
              isEmpty: () => controller.cartItems.isEmpty,
              emptyMessage: 'Giỏ hàng của bạn đang trống',
              onSuccess: () => ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: controller.cartItems.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: AppColors.grey300),
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return CartItemCard(item: item);
                },
              ),
            ),
          ),
          const CartCheckoutBar(),
        ],
      ),
    );
  }
}
