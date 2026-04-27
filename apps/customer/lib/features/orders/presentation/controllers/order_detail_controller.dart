import 'dart:developer' as dev;

import 'package:get/get.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderDetailController extends GetxController {
  final OrderRepository _repository;

  OrderDetailController(this._repository);

  final isLoading = false.obs;
  final error = Rxn<Object>();
  final order = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    final orderId = Get.arguments as String?;
    if (orderId != null) _loadOrder(orderId);
  }

  Future<void> _loadOrder(String id) async {
    try {
      isLoading.value = true;
      error.value = null;
      order.value = await _repository.getOrderById(id);
    } catch (e) {
      dev.log('[ORDER_DETAIL] ❌ _loadOrder error: $e');
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }
}
