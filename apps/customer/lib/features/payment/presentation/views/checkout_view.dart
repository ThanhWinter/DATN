import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core_ui/core_ui.dart';

import '../../../cart/data/models/cart_item_model.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: Text(
          'Xác nhận đơn hàng',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionCard(
                    title: 'Danh sách món',
                    child: Column(
                      children: controller.cartItems
                          .map((item) => _OrderItemRow(item: item))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Phương thức thanh toán',
                    child: Row(
                      children: [
                        Image.asset(
                          AppIcons.iconZalopay,
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        const Text('ZaloPay', style: AppTextStyles.bodyLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _BottomBar(controller: controller),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.h3.copyWith(color: AppColors.textDark)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${item.name} x${item.quantity}',
              style: AppTextStyles.bodyLarge,
            ),
          ),
          Text(
            '${(item.price * item.quantity).toVnd()} ₫',
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.primaryOrangeDark),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});

  final CheckoutController controller;

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
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              if (controller.errorMessage.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    controller.errorMessage.value,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.errorRed),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng:', style: AppTextStyles.h3),
                Text(
                  '${controller.totalPrice.toVnd()} ₫',
                  style: AppTextStyles.h2
                      .copyWith(color: AppColors.primaryOrangeDark),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Thanh toán qua ZaloPay',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.pay,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
