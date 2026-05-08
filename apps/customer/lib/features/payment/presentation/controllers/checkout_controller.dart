import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/services/zalopay_service.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../orders/data/models/coupon_model.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../orders/data/repositories/order_repository.dart';
import '../../data/repositories/coupon_repository.dart';
import '../../data/repositories/payment_repository.dart';

class CheckoutController extends GetxController {
  final OrderRepository _orderRepository;
  final CouponRepository _couponRepository;
  final PaymentRepository _paymentRepository;

  CheckoutController(
    this._orderRepository,
    this._couponRepository,
    this._paymentRepository,
  );

  // ── Form ─────────────────────────────────────────────────────────────────────
  final addressController = TextEditingController();
  final noteController = TextEditingController();
  final couponCodeController = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────────
  final isOrderLoading = false.obs;
  final isCouponLoading = false.obs;
  final coupon = Rxn<CouponModel>();
  final couponError = ''.obs;
  final discountAmount = 0.0.obs;
  final errorMessage = ''.obs;
  final deliveryAddress = ''.obs;

  // Explicit RxDouble — không dùng computed getter trong Obx (Rule #2)
  final subtotal = 0.0.obs;
  final finalTotal = 0.0.obs;

  Worker? _cartTotalWorker;

  List<CartItemModel> get cartItems => Get.find<CartController>().cartItems;

  @override
  void onInit() {
    super.onInit();
    final cart = Get.find<CartController>();
    subtotal.value = cart.totalPrice.value;
    _updateFinalTotal();
    _cartTotalWorker = ever(cart.totalPrice, (val) {
      subtotal.value = val;
      _updateFinalTotal();
    });
    final homeAddr = Get.find<HomeController>().locationName.value;
    if (homeAddr.isNotEmpty) {
      addressController.text = homeAddr;
      deliveryAddress.value = homeAddr;
    }
  }

  @override
  void onClose() {
    _cartTotalWorker?.dispose();
    addressController.dispose();
    noteController.dispose();
    couponCodeController.dispose();
    super.onClose();
  }

  // ── Coupon ───────────────────────────────────────────────────────────────────

  Future<void> applyCoupon() async {
    final code = couponCodeController.text.trim();
    if (code.isEmpty) return;

    try {
      isCouponLoading.value = true;
      couponError.value = '';
      coupon.value = null;
      discountAmount.value = 0;

      final result = await _couponRepository.getCoupon(code);
      dev.log('[CHECKOUT/COUPON] ✅ Fetched coupon: $code');

      if (!result.isActive) {
        couponError.value = 'Mã giảm giá đã hết hiệu lực.';
        return;
      }
      if (DateTime.now().toUtc().isAfter(result.expiresAt.toUtc())) {
        couponError.value = 'Mã giảm giá đã hết hạn.';
        return;
      }
      if (result.minOrderValue != null &&
          subtotal.value < result.minOrderValue!) {
        couponError.value =
            'Đơn tối thiểu ${result.minOrderValue!.toInt()}đ để dùng mã này.';
        return;
      }

      coupon.value = result;
      discountAmount.value = result.calculateDiscount(subtotal.value);
      _updateFinalTotal();
    } on ApiException catch (e) {
      dev.log('[CHECKOUT/COUPON] ❌ ApiException: ${e.statusCode} ${e.message}');
      couponError.value =
          e.statusCode == 404 ? 'Mã giảm giá không tồn tại.' : e.message;
    } catch (e) {
      dev.log('[CHECKOUT/COUPON] ❌ Unexpected error: $e');
      couponError.value = 'Không thể áp dụng mã. Vui lòng thử lại.';
    } finally {
      isCouponLoading.value = false;
    }
  }

  void removeCoupon() {
    coupon.value = null;
    couponError.value = '';
    discountAmount.value = 0;
    couponCodeController.clear();
    _updateFinalTotal();
  }

  // ── Place Order ──────────────────────────────────────────────────────────────

  Future<void> placeOrder() async {
    final address = addressController.text.trim();
    if (address.isEmpty) {
      Get.snackbar(
        'Thiếu địa chỉ',
        'Vui lòng nhập địa chỉ giao hàng.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (cartItems.isEmpty) return;

    try {
      isOrderLoading.value = true;
      errorMessage.value = '';

      final orderItems = cartItems
          .map(
            (e) => OrderItemRequest(
              foodId: e.foodId,
              quantity: e.quantity,
              selectedOptionIds: e.selectedOptions.map((o) => o.id).toList(),
            ),
          )
          .toList();

      final order = await _orderRepository.createOrder(
        OrderCreateRequest(
          deliveryAddress: address,
          note: noteController.text.trim(),
          couponCode: coupon.value?.code,
          items: orderItems,
        ),
      );
      dev.log('[CHECKOUT/ORDER] ✅ Order created: id=${order.id}, total=${order.totalAmount}');

      // Thử thanh toán ZaloPay sau khi tạo đơn thành công
      try {
        final payment = await _paymentRepository.createZaloPayOrder(orderId: order.id);
        final result = await ZaloPayService.payOrder(payment.zpTransToken);
        dev.log('[CHECKOUT/ZALOPAY] Result: $result');

        if (result == 'SUCCESS') {
          try {
            final confirmed = await _paymentRepository.queryPaymentStatus(payment.appTransId);
            dev.log('[CHECKOUT/ZALOPAY] Backend query confirmed: $confirmed');
          } catch (e) {
            dev.log('[CHECKOUT/ZALOPAY] ⚠️ queryPaymentStatus failed: $e');
          }
          await _onOrderSuccess(order.id);
          return;
        }

        // CANCELED hoặc ERROR — đơn đã tạo, để trạng thái PENDING để user retry
        final isCanceled = result == 'CANCELED';
        dev.log('[CHECKOUT/ZALOPAY] ${isCanceled ? "CANCELED" : "ERROR"} — order ${order.id} left PENDING');
        Get.find<CartController>().clearCart();
        Get.snackbar(
          isCanceled ? 'Đã huỷ thanh toán' : 'Thanh toán thất bại',
          'Đơn hàng đã được đặt. Vào chi tiết đơn để thanh toán lại.',
          backgroundColor: isCanceled ? null : AppColors.errorRed,
          colorText: isCanceled ? null : AppColors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(AppRoutes.main);
        Get.toNamed(AppRoutes.orderDetail, arguments: order.id);
        return;
      } catch (e) {
        dev.log('[CHECKOUT/ZALOPAY] ⚠️ ZaloPay exception (order created): $e');
        Get.find<CartController>().clearCart();
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(AppRoutes.main);
        Get.toNamed(AppRoutes.orderDetail, arguments: order.id);
        return;
      }
    } on ApiException catch (e) {
      dev.log('[CHECKOUT/ORDER] ❌ ApiException: ${e.statusCode} ${e.message}');
      errorMessage.value = e.message;
      Get.snackbar(
        'Đặt hàng thất bại',
        e.message,
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      dev.log('[CHECKOUT/ORDER] ❌ Unexpected error: $e');
      errorMessage.value = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      Get.snackbar(
        'Lỗi',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isOrderLoading.value = false;
    }
  }

  void applySelectedAddress(String address) {
    addressController.text = address;
    deliveryAddress.value = address;
  }

  Future<void> applyCouponByCode(String code) async {
    couponCodeController.text = code;
    await applyCoupon();
  }

  // ── Private ──────────────────────────────────────────────────────────────────

  void _updateFinalTotal() {
    finalTotal.value = subtotal.value - discountAmount.value;
  }

  Future<void> _onOrderSuccess(String orderId) async {
    Get.find<CartController>().clearCart();
    dev.log('[CHECKOUT/ORDER] ✅ Cart cleared, navigating to order detail: $orderId');
    Get.snackbar(
      'Đặt hàng thành công',
      'Đơn hàng của bạn đang được xử lý.',
      backgroundColor: AppColors.successGreen,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    await Future.delayed(const Duration(milliseconds: 500));
    Get.offAllNamed(AppRoutes.main);
    Get.toNamed(AppRoutes.orderDetail, arguments: orderId);
  }
}
