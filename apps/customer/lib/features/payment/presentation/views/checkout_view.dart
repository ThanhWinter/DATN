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
                  // ── Danh sách món ──────────────────────────────────────────
                  _SectionCard(
                    title: 'Danh sách món',
                    child: Column(
                      children: controller.cartItems
                          .map((item) => _OrderItemRow(item: item))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Địa chỉ giao hàng ──────────────────────────────────────
                  _SectionCard(
                    title: 'Địa chỉ giao hàng',
                    child: _FormField(
                      controller: controller.addressController,
                      hintText: 'Nhập địa chỉ nhận hàng...',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Ghi chú ────────────────────────────────────────────────
                  _SectionCard(
                    title: 'Ghi chú (tuỳ chọn)',
                    child: _FormField(
                      controller: controller.noteController,
                      hintText: 'VD: Gọi trước khi giao...',
                      icon: Icons.notes_outlined,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Mã giảm giá ────────────────────────────────────────────
                  _SectionCard(
                    title: 'Mã giảm giá',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _FormField(
                                controller: controller.couponCodeController,
                                hintText: 'Nhập mã giảm giá...',
                                icon: Icons.sell_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Obx(() => SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: controller.isCouponLoading.value
                                        ? null
                                        : controller.coupon.value != null
                                            ? controller.removeCoupon
                                            : controller.applyCoupon,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          controller.coupon.value != null
                                              ? AppColors.errorRed
                                              : AppColors.primaryOrange,
                                      foregroundColor: AppColors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: controller.isCouponLoading.value
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.white,
                                            ),
                                          )
                                        : Obx(() => Text(
                                              controller.coupon.value != null
                                                  ? 'Xoá'
                                                  : 'Áp dụng',
                                              style: AppTextStyles.labelLarge
                                                  .copyWith(
                                                      color: AppColors.white),
                                            )),
                                  ),
                                )),
                          ],
                        ),
                        Obx(() {
                          if (controller.couponError.value.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                controller.couponError.value,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.errorRed),
                              ),
                            );
                          }
                          if (controller.coupon.value != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Obx(() => Text(
                                    'Giảm ${controller.discountAmount.value.toVnd()}đ',
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.successGreen),
                                  )),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Phương thức thanh toán ──────────────────────────────────
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

// ── Shared internal widgets ───────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            AppTextStyles.bodyLarge.copyWith(color: AppColors.textLight),
        prefixIcon: Icon(icon, color: AppColors.primaryOrange, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.primaryOrange, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          if (item.selectedOptions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                item.optionsLabel,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.primaryOrange),
              ),
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
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tạm tính:', style: AppTextStyles.bodyMedium),
                    Text('${controller.subtotal.value.toVnd()} ₫',
                        style: AppTextStyles.bodyMedium),
                  ],
                )),
            Obx(() {
              if (controller.discountAmount.value <= 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Giảm giá:', style: AppTextStyles.bodyMedium),
                    Text(
                      '- ${controller.discountAmount.value.toVnd()} ₫',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.successGreen),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 6),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng cộng:', style: AppTextStyles.h3),
                    Text(
                      '${controller.finalTotal.value.toVnd()} ₫',
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.primaryOrangeDark),
                    ),
                  ],
                )),
            const SizedBox(height: 12),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Đặt hàng',
                    isLoading: controller.isOrderLoading.value,
                    onPressed: controller.isOrderLoading.value
                        ? null
                        : controller.placeOrder,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
