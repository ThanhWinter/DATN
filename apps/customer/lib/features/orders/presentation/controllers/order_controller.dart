import 'package:get/get.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderController extends GetxController {
  final OrderRepository _repository;

  OrderController(this._repository);

  final RxList<OrderModel> activeOrders = <OrderModel>[].obs;
  final RxList<OrderModel> historyOrders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _repository.fetchActiveOrders(),
        _repository.fetchHistoryOrders(),
      ]);
      activeOrders.assignAll(results[0]);
      historyOrders.assignAll(results[1]);
    } finally {
      isLoading.value = false;
    }
  }
}
