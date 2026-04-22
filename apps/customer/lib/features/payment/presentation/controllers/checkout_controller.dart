import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../data/repositories/payment_repository.dart';
import '../../../../app/services/zalopay_service.dart';

class CheckoutController extends GetxController {
  final PaymentRepository _repository;

  CheckoutController(this._repository);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  List<CartItemModel> get cartItems => Get.find<CartController>().cartItems;
  double get totalPrice => Get.find<CartController>().totalPrice.value;

  Future<void> pay() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final items = cartItems.map((e) => e.toJson()).toList();
      final zpToken = await _repository.createZaloPayOrder(
        appUser: 'customer',
        amount: totalPrice.toInt(),
        items: items,
      );

      final result = await ZaloPayService.payOrder(zpToken);

      switch (result) {
        case 'SUCCESS':
          Get.find<CartController>().clearCart();
          Get.back();
          Get.snackbar(
            'Thành công',
            'Thanh toán thành công!',
            backgroundColor: AppColors.successGreen,
            colorText: AppColors.white,
            icon: const Icon(Icons.check_circle, color: AppColors.white),
          );
        case 'CANCELED':
          break;
        case 'ERROR':
          errorMessage.value = 'Thanh toán thất bại. Vui lòng thử lại.';
        default:
          errorMessage.value = 'Đã xảy ra lỗi không xác định.';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
