import 'dart:developer' as dev;

import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../../../../app/services/zalopay_service.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../../payment/data/repositories/payment_repository.dart';

class OrderDetailController extends GetxController {
  final OrderRepository _repository;
  final PaymentRepository _paymentRepository;

  OrderDetailController(this._repository, this._paymentRepository);

  final isLoading = false.obs;
  final isMutating = false.obs;
  final error = Rxn<Object>();
  final order = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    final orderId = Get.arguments as String?;
    if (orderId != null) loadOrder(orderId);
  }

  Future<void> loadOrder(String id) async {
    try {
      isLoading.value = true;
      error.value = null;
      order.value = await _repository.getOrderById(id);
    } catch (e) {
      dev.log('[ORDER_DETAIL] ❌ loadOrder error: $e');
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelOrder() async {
    final current = order.value;
    if (current == null) return;
    isMutating.value = true;
    try {
      await _repository.cancelOrder(current.id);
      await loadOrder(current.id);
      Get.snackbar(
        'Đã huỷ đơn',
        'Đơn hàng #${current.id.substring(0, 8).toUpperCase()} đã được huỷ.',
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      dev.log('[ORDER_DETAIL] ❌ cancelOrder error: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể huỷ đơn: $e',
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> retryPayment() async {
    final current = order.value;
    if (current == null) return;
    isMutating.value = true;
    try {
      final payment = await _paymentRepository.createZaloPayOrder(
        orderId: current.id,
      );
      final result = await ZaloPayService.payOrder(payment.zpTransToken);
      dev.log('[ORDER_DETAIL] ZaloPay result: $result');
      if (result == 'SUCCESS') {
        final confirmed =
            await _paymentRepository.queryPaymentStatus(payment.appTransId);
        dev.log('[ORDER_DETAIL] Server confirmed: $confirmed');
        await loadOrder(current.id);
        Get.snackbar(
          'Thanh toán thành công',
          'Đơn hàng đang được xử lý.',
          backgroundColor: AppColors.successGreen,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else if (result == 'CANCELED') {
        Get.snackbar(
          'Đã huỷ thanh toán',
          'Bạn có thể thử lại bất cứ lúc nào.',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'Thanh toán thất bại',
          'Vui lòng thử lại.',
          backgroundColor: AppColors.errorRed,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      dev.log('[ORDER_DETAIL] ❌ retryPayment error: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể thanh toán: $e',
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isMutating.value = false;
    }
  }
}
