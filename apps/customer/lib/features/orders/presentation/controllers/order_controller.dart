import 'dart:developer' as dev;

import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderController extends GetxController {
  final OrderRepository _repository;

  OrderController(this._repository);

  final RxList<OrderModel> activeOrders = <OrderModel>[].obs;
  final RxList<OrderModel> historyOrders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final error = Rxn<Object>();

  static const _activeStatuses = {'PENDING', 'PROCESSING', 'DELIVERING'};

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      error.value = null;

      final orders = await _repository.fetchMyOrders();

      final active = orders
          .where((o) => _activeStatuses.contains(o.status.toUpperCase()))
          .toList();
      final history = orders
          .where((o) => !_activeStatuses.contains(o.status.toUpperCase()))
          .toList();

      activeOrders.assignAll(active);
      historyOrders.assignAll(history);
    } catch (e) {
      dev.log('[ORDER] ❌ loadOrders error: $e');
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToDetail(String orderId) {
    Get.toNamed(AppRoutes.orderDetail, arguments: orderId);
  }
}
