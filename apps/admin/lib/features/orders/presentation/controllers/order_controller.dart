import 'dart:developer' as dev;

import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderController extends GetxController {
  OrderController(this._repository);

  final OrderRepository _repository;

  final isLoading = true.obs;
  final error = Rxn<String>();
  final isUpdating = false.obs;

  final pendingOrders = <OrderModel>[].obs;
  final activeOrders = <OrderModel>[].obs;
  final completedOrders = <OrderModel>[].obs;
  final cancelledOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    dev.log('[ORDER/VM] Loading orders...');
    isLoading.value = true;
    error.value = null;
    try {
      final all = await _repository.fetchOrders();
      _distribute(all);
      dev.log('[ORDER/VM] ✅ Loaded ${all.length} orders');
    } catch (e) {
      dev.log('[ORDER/VM] ❌ loadOrders error: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _distribute(List<OrderModel> all) {
    pendingOrders.value = all
        .where((o) => [
              OrderModel.statusPending,
              OrderModel.statusPaid,
            ].contains(o.status))
        .toList();

    activeOrders.value = all
        .where((o) => [
              OrderModel.statusPreparing,
              OrderModel.statusDelivering,
            ].contains(o.status))
        .toList();

    completedOrders.value =
        all.where((o) => o.status == OrderModel.statusCompleted).toList();
    cancelledOrders.value =
        all.where((o) => o.status == OrderModel.statusCancelled).toList();
  }

  Future<void> updateStatus(OrderModel order, String newStatus) async {
    dev.log('[ORDER/VM] Updating order ${order.id}: ${order.status} → $newStatus');
    isUpdating.value = true;
    try {
      await _repository.updateOrderStatus(order.id, newStatus);
      order.status = newStatus;
      final all = [
        ...pendingOrders,
        ...activeOrders,
        ...completedOrders,
        ...cancelledOrders,
      ];
      _distribute(all);
      Get.snackbar(
        'Cập nhật thành công',
        'Đơn ${order.id} → ${OrderModel.statusLabel(newStatus)}',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      dev.log('[ORDER/VM] ✅ Order ${order.id} status updated to $newStatus');
    } catch (e) {
      dev.log('[ORDER/VM] ❌ updateStatus error: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật đơn hàng: $e',
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }
}
