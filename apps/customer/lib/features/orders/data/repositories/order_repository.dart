import '../models/order_model.dart';

class OrderRepository {
  Future<List<OrderModel>> fetchActiveOrders() async {
    // Simulated network delay
    await Future.delayed(const Duration(seconds: 1));
    return []; // Handled heavily inside mock data controller right now
  }

  Future<List<OrderModel>> fetchHistoryOrders() async {
    await Future.delayed(const Duration(seconds: 1));
    return []; // Handled heavily inside mock data controller right now
  }
}
