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

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        // Backend trả về foodName hoặc name tuỳ implementation
        name: json['foodName'] as String? ?? json['name'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
        options: json['options'] as String?,
      );
}

class OrderModel {
  OrderModel({
    required this.id,
    required this.deliveryAddress,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.items,
    this.userId,
    this.customerName,
    this.customerPhone,
    this.note,
    this.couponCode,
    this.paymentMethod = methodCash,
  });

  final String id;
  final String? userId;
  final String? customerName;
  final String? customerPhone;
  final String deliveryAddress;
  final DateTime orderDate;
  final double totalAmount;
  String status;
  final List<OrderItemModel> items;
  final String? note;
  final String? couponCode;
  final String paymentMethod;

  static const methodCash = 'CASH';
  static const methodZaloPay = 'ZALOPAY';

  static const statusPending = 'PENDING';
  static const statusPaid = 'PAID';
  static const statusPreparing = 'PREPARING';
  static const statusDelivering = 'DELIVERING';
  static const statusCompleted = 'COMPLETED';
  static const statusCancelled = 'CANCELLED';

  static const List<String> allStatuses = [
    statusPending,
    statusPaid,
    statusPreparing,
    statusDelivering,
    statusCompleted,
    statusCancelled,
  ];

  static String statusLabel(String s) => switch (s) {
        statusPending => 'Chờ xử lý',
        statusPaid => 'Đã thanh toán',
        statusPreparing => 'Đang chuẩn bị',
        statusDelivering => 'Đang giao hàng',
        statusCompleted => 'Đã hoàn thành',
        statusCancelled => 'Đã huỷ',
        _ => s,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['orderItems'] as List<dynamic>? ?? [];
    final summaries = json['itemsSummary'] as List<dynamic>? ?? [];

    final items = rawItems.isNotEmpty
        ? rawItems
            .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : summaries
            .map((s) => OrderItemModel(
                  name: s as String,
                  quantity: 1,
                  unitPrice: 0,
                ))
            .toList();

    return OrderModel(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'] as String)
          : DateTime.now(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? statusPending,
      items: items,
      note: json['note'] as String?,
      couponCode: json['couponCode'] as String?,
      paymentMethod: json['paymentMethod'] as String? ?? methodCash,
    );
  }
}
