import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core_ui/core_ui.dart';
import '../controllers/cart_controller.dart';

class CartCheckoutBar extends GetView<CartController> {
  const CartCheckoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grey200)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng',
                  style: AppTextStyles.bodyMedium,
                ),
                Obx(() => Text(
                      '${controller.totalPrice.value.toVnd()} ₫',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primaryOrangeDark,
                        fontWeight: FontWeight.w700,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Đặt hàng', style: AppTextStyles.button),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
