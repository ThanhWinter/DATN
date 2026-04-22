import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderController extends GetxController {
  OrderController(this._repository);

  final OrderRepository _repository;

  final isLoading = true.obs;
  final error = Rxn<String>();

  // TODO: mock data
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
    isLoading.value = true;
    error.value = null;
    try {
      final all = await _repository.fetchOrders();
      _distribute(all);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _distribute(List<OrderModel> all) {
    pendingOrders.value =
        all.where((o) => o.status == OrderModel.statusPending).toList();
    activeOrders.value = all
        .where((o) => [
              OrderModel.statusConfirmed,
              OrderModel.statusPreparing,
              OrderModel.statusReady,
            ].contains(o.status))
        .toList();
    completedOrders.value =
        all.where((o) => o.status == OrderModel.statusDelivered).toList();
    cancelledOrders.value =
        all.where((o) => o.status == OrderModel.statusCancelled).toList();
  }

  void updateStatus(OrderModel order, String newStatus) {
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
  }
}
