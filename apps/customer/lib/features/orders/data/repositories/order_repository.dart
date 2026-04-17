import '../models/order_model.dart';

class OrderRepository {
  Future<List<OrderModel>> fetchActiveOrders() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: mock data
    return [
      OrderModel(
        id: 'FH-903120',
        orderDate: DateTime.now().subtract(const Duration(minutes: 15)),
        totalAmount: 155000,
        status: 'active',
        itemsSummary: ['2x Cơm Tấm Sườn Bì Chả', '1x Trà Đào Cam Sả'],
      ),
      OrderModel(
        id: 'FH-983192',
        orderDate: DateTime.now().subtract(const Duration(minutes: 45)),
        totalAmount: 85000,
        status: 'active',
        itemsSummary: ['1x Phở Bò Kobe Đặc Biệt'],
      ),
    ];
  }

  Future<List<OrderModel>> fetchHistoryOrders() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: mock data
    return [
      OrderModel(
        id: 'FH-102934',
        orderDate: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        totalAmount: 45000,
        status: 'completed',
        itemsSummary: ['1x Trà Sữa Trân Châu Đường Đen'],
      ),
      OrderModel(
        id: 'FH-093842',
        orderDate: DateTime.now().subtract(const Duration(days: 3)),
        totalAmount: 110000,
        status: 'cancelled',
        itemsSummary: ['1x Bún Bò Huế', '1x Sinh tố bơ sữa'],
      ),
      OrderModel(
        id: 'FH-981231',
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        totalAmount: 250000,
        status: 'completed',
        itemsSummary: ['1x Gà Rán Gia Đình', '2x Pepsi', '1x Khoai Tây Chiên'],
      ),
    ];
  }
}
