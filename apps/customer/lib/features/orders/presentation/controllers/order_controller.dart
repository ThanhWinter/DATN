import 'dart:async';
import 'dart:developer' as dev;

import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../main/presentation/controllers/main_controller.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderController extends GetxController {
  final OrderRepository _repository;

  OrderController(this._repository);

  final RxList<OrderModel> activeOrders = <OrderModel>[].obs;
  final RxList<OrderModel> historyOrders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final error = Rxn<Object>();

  static const _activeStatuses = {'PENDING', 'PAID', 'PREPARING', 'DELIVERING'};

  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => loadOrders(),
    );
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
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
      if (Get.isRegistered<MainController>()) {
        Get.find<MainController>()
            .syncActiveOrderBadgeFromOrderTab(activeOrders.length);
      }
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
