import 'package:core_ui/core_ui.dart';
import 'package:core_utils/core_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../data/models/order_item_model.dart';
import '../../data/models/order_model.dart';
import '../controllers/order_detail_controller.dart';

class OrderDetailView extends GetView<OrderDetailController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: Get.back,
        ),
        title: Text(
          'Chi tiết đơn hàng',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onSuccess: () => Obx(() {
          final order = controller.order.value;
          if (order == null) return const SizedBox.shrink();
          return _OrderDetailBody(order: order, controller: controller);
        }),
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({required this.order, required this.controller});

  final OrderModel order;
  final OrderDetailController controller;

  @override
  Widget build(BuildContext context) {
    final status = order.status.toUpperCase();
    final isCancelled = status == 'CANCELLED';
    final isPending = status == 'PENDING';
    final isCompleted = status == 'COMPLETED';
    final isCancellable = status == 'PENDING';
    final idShort = order.id.length >= 8
        ? '#${order.id.substring(0, 8).toUpperCase()}'
        : '#${order.id.toUpperCase()}';

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── 1. Status hero ─────────────────────────────────────────────────
          _StatusHero(order: order, idShort: idShort),

          // ── 2. Timeline (ẩn nếu đã hủy) ────────────────────────────────────
          if (!isCancelled) _OrderTimeline(status: status),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── 3. Delivery info ──────────────────────────────────────────
                _DeliveryInfoCard(order: order),
                const SizedBox(height: 12),

                // ── 4. Items ──────────────────────────────────────────────────
                _ItemsCard(order: order),
                const SizedBox(height: 12),

                // ── 5. Payment + price breakdown ──────────────────────────────
                _PaymentCard(order: order),
                const SizedBox(height: 16),

                // ── 6. Actions ────────────────────────────────────────────────
                Obx(() {
                  final isMutating = controller.isMutating.value;
                  return _ActionsSection(
                    controller: controller,
                    order: order,
                    isPending: isPending,
                    isCancellable: isCancellable,
                    isCompleted: isCompleted,
                    loading: isMutating,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 1. Status Hero ────────────────────────────────────────────────────────────

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.order, required this.idShort});

  final OrderModel order;
  final String idShort;

  @override
  Widget build(BuildContext context) {
    final cfg = _StatusConfig.of(order.status);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryOrange, cfg.heroColor],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(
        children: [
          // Icon circle
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(cfg.icon, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 14),

          // Status label
          Text(
            cfg.label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),

          // Order ID
          Text(
            idShort,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),

          // Date
          Text(
            formatOrderDate(order.orderDate),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Order Timeline ─────────────────────────────────────────────────────────

class _StepData {
  const _StepData({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.status});

  final String status;

  static const _steps = [
    _StepData(icon: Icons.receipt_long_rounded, label: 'Đặt hàng'),
    _StepData(icon: Icons.payment_rounded, label: 'Đã TT'),
    _StepData(icon: Icons.restaurant_rounded, label: 'Chuẩn bị'),
    _StepData(icon: Icons.delivery_dining_rounded, label: 'Đang giao'),
    _StepData(icon: Icons.check_circle_rounded, label: 'Xong'),
  ];

  static const _statusIndex = {
    'PENDING': 0,
    'PAID': 1,
    'PREPARING': 2,
    'DELIVERING': 3,
    'COMPLETED': 4,
  };

  @override
  Widget build(BuildContext context) {
    final current = _statusIndex[status] ?? 0;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIdx = i ~/ 2;
            final done = stepIdx < current;
            return Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: done
                      ? const LinearGradient(
                          colors: [
                            AppColors.primaryOrange,
                            AppColors.primaryOrange
                          ],
                        )
                      : null,
                  color: done ? null : AppColors.grey200,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final isDone = stepIdx < current;
          final isActive = stepIdx == current;
          final step = _steps[stepIdx];
          return _TimelineStep(
            icon: step.icon,
            label: step.label,
            isDone: isDone,
            isActive: isActive,
          );
        }),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.isDone,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color circleColor;
    final Color iconColor;
    if (isDone) {
      circleColor = AppColors.primaryOrange;
      iconColor = Colors.white;
    } else if (isActive) {
      circleColor = AppColors.primaryOrange.withValues(alpha: 0.15);
      iconColor = AppColors.primaryOrange;
    } else {
      circleColor = AppColors.grey100;
      iconColor = AppColors.grey400;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: AppColors.primaryOrange, width: 2)
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryOrange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primaryOrange : AppColors.textGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── 3. Delivery Info Card ─────────────────────────────────────────────────────

class _DeliveryInfoCard extends StatelessWidget {
  const _DeliveryInfoCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        children: [
          _IconInfoRow(
            iconData: Icons.access_time_rounded,
            iconColor: AppColors.primaryOrange,
            bgColor: AppColors.primaryOrange.withValues(alpha: 0.1),
            label: 'Thời gian đặt',
            value: formatOrderDate(order.orderDate),
          ),
          if (order.deliveryAddress.isNotEmpty) ...[
            const _RowDivider(),
            _IconInfoRow(
              iconData: Icons.location_on_rounded,
              iconColor: const Color(0xFF0EA5E9),
              bgColor: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
              label: 'Địa chỉ giao hàng',
              value: order.deliveryAddress,
            ),
          ],
          if (order.note != null && order.note!.isNotEmpty) ...[
            const _RowDivider(),
            _IconInfoRow(
              iconData: Icons.notes_rounded,
              iconColor: const Color(0xFF8B5CF6),
              bgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              label: 'Ghi chú',
              value: order.note!,
            ),
          ],
        ],
      ),
    );
  }
}

class _IconInfoRow extends StatelessWidget {
  const _IconInfoRow({
    required this.iconData,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.value,
  });

  final IconData iconData;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(iconData, size: 17, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 4. Items Card ─────────────────────────────────────────────────────────────

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fastfood_rounded,
                    size: 16, color: AppColors.primaryOrange),
              ),
              const SizedBox(width: 10),
              Text(
                'Đơn hàng  •  ${order.orderItems.length} món',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(order.orderItems.length, (i) {
            final item = order.orderItems[i];
            return Column(
              children: [
                _ItemRow(item: item),
                if (i < order.orderItems.length - 1)
                  const Divider(height: 16, color: Color(0xFFF0F0F0)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Quantity badge
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Name + options
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.foodName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              if (item.selectedOptions.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  item.selectedOptions.join(', '),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Price
        Text(
          '${item.totalPrice.toVnd()} ₫',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryOrange,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── 5. Payment + Price Breakdown Card ────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final isZaloPay =
        order.paymentMethod.toUpperCase() == OrderModel.methodZaloPay;
    final subtotal =
        order.totalAmount + order.discountAmount - order.shippingFee;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment method row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isZaloPay
                      ? const Color(0xFF0068FF).withValues(alpha: 0.1)
                      : AppColors.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isZaloPay
                      ? Icons.account_balance_wallet_rounded
                      : Icons.payments_rounded,
                  size: 18,
                  color: isZaloPay
                      ? const Color(0xFF0068FF)
                      : AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thanh toán qua',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textGrey),
                    ),
                    Text(
                      isZaloPay ? 'ZaloPay' : 'Tiền mặt',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),

          // Price breakdown
          if (order.discountAmount > 0 || order.shippingFee > 0) ...[
            _PriceRow(
              label: 'Tạm tính',
              value: '${subtotal.toVnd()} ₫',
            ),
            const SizedBox(height: 8),
          ],
          if (order.shippingFee > 0) ...[
            _PriceRow(
              label: 'Phí giao hàng',
              value: '+ ${order.shippingFee.toVnd()} ₫',
              icon: Icons.delivery_dining_rounded,
              iconColor: AppColors.primaryOrange,
            ),
            const SizedBox(height: 8),
          ],
          if (order.discountAmount > 0) ...[
            _PriceRow(
              label: order.couponCode != null
                  ? 'Mã ${order.couponCode}'
                  : 'Giảm giá',
              value: '- ${order.discountAmount.toVnd()} ₫',
              valueColor: AppColors.successGreen,
              icon: Icons.sell_rounded,
              iconColor: AppColors.successGreen,
            ),
            const SizedBox(height: 8),
          ],

          if (order.discountAmount > 0 || order.shippingFee > 0)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Divider(height: 1, color: Color(0xFFF0F0F0)),
            ),

          // Total
          Row(
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
                '${order.totalAmount.toVnd()} ₫',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: iconColor ?? AppColors.textGrey,
              ),
            ),
          ],
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

// ── 6. Actions ────────────────────────────────────────────────────────────────

class _ActionsSection extends StatelessWidget {
  const _ActionsSection({
    required this.controller,
    required this.order,
    required this.isPending,
    required this.isCancellable,
    required this.isCompleted,
    required this.loading,
  });

  final OrderDetailController controller;
  final OrderModel order;
  final bool isPending;
  final bool isCancellable;
  final bool isCompleted;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isPending) ...[
          _ActionButton(
            label: 'Thanh toán ngay',
            icon: Icons.payment_rounded,
            onPressed: loading ? null : controller.retryPayment,
            loading: loading,
            backgroundColor: AppColors.primaryOrange,
          ),
          const SizedBox(height: 10),
        ],
        if (isCancellable) ...[
          _ActionButton(
            label: 'Huỷ đơn hàng',
            icon: Icons.cancel_outlined,
            onPressed: loading ? null : () => _confirmCancel(context),
            isOutlined: true,
            outlineColor: AppColors.errorRed,
            labelColor: AppColors.errorRed,
          ),
          const SizedBox(height: 10),
        ],
        if (isCompleted)
          _ActionButton(
            label: 'Đánh giá đơn hàng',
            icon: Icons.star_rounded,
            onPressed: () => Get.toNamed(
              AppRoutes.reviewOrder,
              arguments: {'orderId': order.id, 'items': order.orderItems},
            ),
            backgroundColor: AppColors.primaryOrange,
          ),
      ],
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Huỷ đơn hàng?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Bạn có chắc muốn huỷ đơn này không?\nHành động này không thể hoàn tác.'),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: Get.back,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 42),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 42),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Huỷ đơn'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
    this.backgroundColor,
    this.isOutlined = false,
    this.outlineColor,
    this.labelColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? backgroundColor;
  final bool isOutlined;
  final Color? outlineColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final inner = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18, color: isOutlined ? outlineColor : Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isOutlined ? labelColor : Colors.white,
                ),
              ),
            ],
          );

    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: outlineColor ?? AppColors.primaryOrange),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: inner,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryOrange,
          disabledBackgroundColor: (backgroundColor ?? AppColors.primaryOrange)
              .withValues(alpha: 0.6),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: inner,
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Color(0xFFF0F0F0)),
    );
  }
}

// ── Status Config ─────────────────────────────────────────────────────────────

class _StatusConfig {
  const _StatusConfig({
    required this.label,
    required this.icon,
    required this.heroColor,
  });

  final String label;
  final IconData icon;
  final Color heroColor;

  static _StatusConfig of(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const _StatusConfig(
          label: 'Chờ thanh toán',
          icon: Icons.access_time_rounded,
          heroColor: Color(0xFFEA580C),
        );
      case 'PAID':
        return const _StatusConfig(
          label: 'Đã thanh toán',
          icon: Icons.check_circle_rounded,
          heroColor: Color(0xFF1D4ED8),
        );
      case 'PREPARING':
        return const _StatusConfig(
          label: 'Đang chuẩn bị',
          icon: Icons.restaurant_rounded,
          heroColor: Color(0xFF7C3AED),
        );
      case 'DELIVERING':
        return const _StatusConfig(
          label: 'Đang giao hàng',
          icon: Icons.delivery_dining_rounded,
          heroColor: Color(0xFF0891B2),
        );
      case 'COMPLETED':
        return const _StatusConfig(
          label: 'Hoàn thành',
          icon: Icons.check_circle_rounded,
          heroColor: Color(0xFF15803D),
        );
      case 'CANCELLED':
        return const _StatusConfig(
          label: 'Đã hủy đơn',
          icon: Icons.cancel_rounded,
          heroColor: Color(0xFFB91C1C),
        );
      default:
        return const _StatusConfig(
          label: 'Đang xử lý',
          icon: Icons.hourglass_top_rounded,
          heroColor: Color(0xFFEA580C),
        );
    }
  }
}
