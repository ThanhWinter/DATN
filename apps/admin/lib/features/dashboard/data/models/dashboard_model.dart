class DashboardModel {
  const DashboardModel({
    required this.todayOrders,
    required this.todayRevenue,
    required this.totalFoods,
  });

  final int todayOrders;
  final double todayRevenue;
  final int totalFoods;

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        todayOrders: (json['todayOrders'] as num).toInt(),
        todayRevenue: (json['todayRevenue'] as num).toDouble(),
        totalFoods: (json['totalFoods'] as num).toInt(),
      );

  static const empty = DashboardModel(
    todayOrders: 0,
    todayRevenue: 0,
    totalFoods: 0,
  );
}
