import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core_ui/core_ui.dart';
import '../controllers/cart_controller.dart';

class CartCheckoutBar extends GetView<CartController> {
  const CartCheckoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grey300)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black54,
            blurRadius: 4,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng:', style: AppTextStyles.h3),
                Obx(() => Text(
                      '${controller.totalPrice.value.toVnd()} ₫',
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.primaryOrangeDark),
                    )),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle checkout action
                  Get.snackbar(
                    'Thông báo',
                    'Chức năng thanh toán đang được phát triển',
                    backgroundColor: AppColors.primaryOrange,
                    colorText: AppColors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Thanh toán', style: AppTextStyles.button),
              ),
            )
          ],
        ),
      ),
    );
  }
}
