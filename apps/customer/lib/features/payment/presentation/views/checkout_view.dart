import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core_ui/core_ui.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../home/presentation/widgets/location_picker_sheet.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  static const double _shippingFee = 15000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          'Xác nhận đơn hàng',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DeliverToCard(controller: controller),
                  const SizedBox(height: 12),
                  _OrderSummaryCard(controller: controller),
                  const SizedBox(height: 12),
                  _NoteCard(controller: controller),
                  const SizedBox(height: 12),
                  _PaymentMethodCard(),
                  const SizedBox(height: 12),
                  _DiscountsCard(controller: controller),
                  const SizedBox(height: 12),
                  _PriceBreakdownCard(
                    controller: controller,
                    shippingFee: _shippingFee,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _PlaceOrderBar(controller: controller, shippingFee: _shippingFee),
        ],
      ),
    );
  }
}

// ── Deliver To ────────────────────────────────────────────────────────────────

class _DeliverToCard extends StatelessWidget {
  const _DeliverToCard({required this.controller});
  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: InkWell(
        onTap: () async {
          await showModalBottomSheet(
            context: Get.context!,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const LocationPickerSheet(),
          );
          final updated = Get.find<HomeController>().locationName.value;
          if (updated.isNotEmpty) {
            controller.applySelectedAddress(updated);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primaryOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Giao đến',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Mặc định',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryOrange,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Obx(() {
                      final addr = controller.deliveryAddress.value;
                      return Text(
                        addr.isEmpty ? 'Chọn địa chỉ giao hàng...' : addr,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: addr.isEmpty
                              ? AppColors.textLight
                              : AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textGrey,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Order Summary ─────────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.controller});
  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Đơn hàng',
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded,
                            size: 14, color: AppColors.primaryOrange),
                        const SizedBox(width: 4),
                        Text(
                          'Thêm món',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final items = Get.find<CartController>().cartItems;
              return Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    _CartItemTile(item: items[i]),
                    if (i < items.length - 1)
                      const Divider(height: 16, color: Color(0xFFEEEEEE)),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});
  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: item.imageUrl != null
              ? Image.network(
                  item.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  cacheWidth: 120,
                  cacheHeight: 120,
                  errorBuilder: (_, __, ___) => _PlaceholderBox(),
                )
              : _PlaceholderBox(),
        ),
        const SizedBox(width: 12),
        // Name + options
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.selectedOptions.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  item.optionsLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 4),
              Text(
                '${(item.price).toVnd()} ₫',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Quantity badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'x${item.quantity}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaceholderBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      color: AppColors.grey100,
      child: const Icon(Icons.fastfood_rounded,
          color: AppColors.grey300, size: 28),
    );
  }
}

// ── Note ──────────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.controller});
  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.notes_rounded,
                color: AppColors.primaryOrange, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.noteController,
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: 'Ghi chú cho đơn hàng...',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textLight),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Payment Method ────────────────────────────────────────────────────────────

class _PaymentMethodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF0068FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Color(0xFF0068FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phương thức thanh toán',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'ZaloPay',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textGrey, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Discounts ─────────────────────────────────────────────────────────────────

class _DiscountsCard extends StatelessWidget {
  const _DiscountsCard({required this.controller});
  final CheckoutController controller;

  Future<void> _openCoupons() async {
    final result = await Get.toNamed(
      AppRoutes.coupons,
      arguments: {'returnOnSelect': true},
    );
    if (result is String && result.isNotEmpty) {
      await controller.applyCouponByCode(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Obx(() {
        final applied = controller.coupon.value;
        if (applied != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.sell_rounded,
                    color: AppColors.successGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ưu đãi đã áp dụng',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AppColors.successGreen.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              applied.code,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Giảm ${controller.discountAmount.value.toVnd()} ₫',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: controller.removeCoupon,
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.textGrey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        }

        return InkWell(
          onTap: _openCoupons,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.sell_rounded,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nhận ưu đãi',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textGrey, size: 22),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Price Breakdown ───────────────────────────────────────────────────────────

class _PriceBreakdownCard extends StatelessWidget {
  const _PriceBreakdownCard({
    required this.controller,
    required this.shippingFee,
  });
  final CheckoutController controller;
  final double shippingFee;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(() => _PriceRow(
                  label: 'Tạm tính',
                  value: '${controller.subtotal.value.toVnd()} ₫',
                )),
            const SizedBox(height: 8),
            _PriceRow(
              label: 'Phí giao hàng',
              value: '+ ${shippingFee.toInt().toVnd()} ₫',
            ),
            Obx(() {
              if (controller.discountAmount.value <= 0) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  const SizedBox(height: 8),
                  _PriceRow(
                    label: 'Giảm giá',
                    value: '- ${controller.discountAmount.value.toVnd()} ₫',
                    valueColor: AppColors.successGreen,
                  ),
                ],
              );
            }),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng cộng',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${(controller.finalTotal.value + shippingFee).toInt().toVnd()} ₫',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

// ── Place Order Bar ───────────────────────────────────────────────────────────

class _PlaceOrderBar extends StatelessWidget {
  const _PlaceOrderBar({
    required this.controller,
    required this.shippingFee,
  });
  final CheckoutController controller;
  final double shippingFee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          final total =
              (controller.finalTotal.value + shippingFee).toInt().toVnd();
          final loading = controller.isOrderLoading.value;
          return SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: loading ? null : controller.placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                disabledBackgroundColor: AppColors.primaryOrange.withValues(alpha: 0.6),
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      'Đặt hàng  •  $total ₫',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}
