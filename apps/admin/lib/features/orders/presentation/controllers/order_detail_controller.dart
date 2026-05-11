import 'dart:developer' as dev;

import 'package:get/get.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderDetailController extends GetxController {
  OrderDetailController(this._repository);

  final OrderRepository _repository;

  final isLoading = true.obs;
  final error = Rxn<String>();
  final order = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments as String?;
    if (id != null) _load(id);
  }

  Future<void> _load(String id) async {
    isLoading.value = true;
    error.value = null;
    try {
      order.value = await _repository.getOrderDetail(id);
      dev.log('[ORDER_DETAIL/VM] ✅ Loaded: $id');
    } catch (e) {
      dev.log('[ORDER_DETAIL/VM] ❌ load: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOrder() async {
    final o = order.value;
    if (o != null) {
      await _load(o.id);
    } else {
      final id = Get.arguments as String?;
      if (id != null) await _load(id);
    }
  }

  Future<void> updateStatus(String newStatus) async {
    final o = order.value;
    if (o == null) return;
    try {
      await _repository.updateOrderStatus(o.id, newStatus);
      dev.log('[ORDER_DETAIL/VM] ✅ Status → $newStatus');
      await _load(o.id);
    } catch (e) {
      dev.log('[ORDER_DETAIL/VM] ❌ updateStatus: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
