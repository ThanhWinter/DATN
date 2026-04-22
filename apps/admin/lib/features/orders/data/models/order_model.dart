class OrderItemModel {
  const OrderItemModel({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.options,
  });

  final String name;
  final int quantity;
  final double unitPrice;
  final String? options;
}

class OrderModel {
  OrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.items,
    this.note,
    this.couponCode,
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final DateTime orderDate;
  final double totalAmount;
  String status;
  final List<OrderItemModel> items;
  final String? note;
  final String? couponCode;

  static const statusPending = 'PENDING';
  static const statusConfirmed = 'CONFIRMED';
  static const statusPreparing = 'PREPARING';
  static const statusReady = 'READY';
  static const statusDelivered = 'DELIVERED';
  static const statusCancelled = 'CANCELLED';

  static const List<String> allStatuses = [
    statusPending,
    statusConfirmed,
    statusPreparing,
    statusReady,
    statusDelivered,
    statusCancelled,
  ];

  static String statusLabel(String s) => switch (s) {
    statusPending => 'Chờ xác nhận',
    statusConfirmed => 'Đã xác nhận',
    statusPreparing => 'Đang chuẩn bị',
    statusReady => 'Sẵn sàng giao',
    statusDelivered => 'Đã giao',
    statusCancelled => 'Đã huỷ',
    _ => s,
  };
}
