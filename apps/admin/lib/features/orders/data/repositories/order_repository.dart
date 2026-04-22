import '../models/order_model.dart';

class OrderRepository {
  Future<List<OrderModel>> fetchOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: mock data
    return [
      OrderModel(
        id: 'FH-001234',
        customerName: 'Nguyễn Văn An',
        customerPhone: '0901234567',
        deliveryAddress: '123 Lê Lợi, Q.1, TP.HCM',
        orderDate: DateTime.now().subtract(const Duration(minutes: 5)),
        totalAmount: 155000,
        status: OrderModel.statusPending,
        items: const [
          OrderItemModel(name: 'Cơm sườn nướng', quantity: 2, unitPrice: 65000),
          OrderItemModel(name: 'Trà đào cam sả', quantity: 1, unitPrice: 35000,
              options: 'Ít đường, nhiều đá'),
        ],
        note: 'Không hành',
      ),
      OrderModel(
        id: 'FH-001235',
        customerName: 'Trần Thị Bình',
        customerPhone: '0912345678',
        deliveryAddress: '45 Nguyễn Huệ, Q.1, TP.HCM',
        orderDate: DateTime.now().subtract(const Duration(minutes: 18)),
        totalAmount: 130000,
        status: OrderModel.statusConfirmed,
        items: const [
          OrderItemModel(name: 'Phở bò tái nạm', quantity: 1, unitPrice: 65000),
          OrderItemModel(name: 'Cà phê sữa đá', quantity: 2, unitPrice: 25000),
          OrderItemModel(name: 'Chè thái', quantity: 1, unitPrice: 30000),
        ],
        couponCode: 'WELCOME10',
      ),
      OrderModel(
        id: 'FH-001236',
        customerName: 'Lê Hoàng Cường',
        customerPhone: '0923456789',
        deliveryAddress: '78 Pasteur, Q.3, TP.HCM',
        orderDate: DateTime.now().subtract(const Duration(minutes: 32)),
        totalAmount: 70000,
        status: OrderModel.statusPreparing,
        items: const [
          OrderItemModel(name: 'Cơm tấm đặc biệt', quantity: 1, unitPrice: 70000),
        ],
      ),
      OrderModel(
        id: 'FH-001237',
        customerName: 'Phạm Minh Đức',
        customerPhone: '0934567890',
        deliveryAddress: '12 Đinh Tiên Hoàng, Q.Bình Thạnh, TP.HCM',
        orderDate: DateTime.now().subtract(const Duration(hours: 1)),
        totalAmount: 95000,
        status: OrderModel.statusReady,
        items: const [
          OrderItemModel(name: 'Bún bò Huế', quantity: 1, unitPrice: 60000),
          OrderItemModel(name: 'Sinh tố bơ sữa', quantity: 1, unitPrice: 40000),
        ],
      ),
      OrderModel(
        id: 'FH-001230',
        customerName: 'Hoàng Thị Lan',
        customerPhone: '0945678901',
        deliveryAddress: '56 Cách Mạng Tháng 8, Q.3, TP.HCM',
        orderDate: DateTime.now().subtract(const Duration(hours: 3)),
        totalAmount: 200000,
        status: OrderModel.statusDelivered,
        items: const [
          OrderItemModel(name: 'Cơm gà xối mỡ', quantity: 2, unitPrice: 60000),
          OrderItemModel(name: 'Trà đào cam sả', quantity: 2, unitPrice: 35000),
          OrderItemModel(name: 'Bánh flan caramel', quantity: 2, unitPrice: 25000),
        ],
      ),
      OrderModel(
        id: 'FH-001228',
        customerName: 'Võ Thanh Hà',
        customerPhone: '0956789012',
        deliveryAddress: '99 Bùi Viện, Q.1, TP.HCM',
        orderDate: DateTime.now().subtract(const Duration(hours: 5)),
        totalAmount: 65000,
        status: OrderModel.statusCancelled,
        items: const [
          OrderItemModel(name: 'Cơm sườn nướng', quantity: 1, unitPrice: 65000),
        ],
        note: 'Khách huỷ vì chờ lâu',
      ),
    ];
  }
}
