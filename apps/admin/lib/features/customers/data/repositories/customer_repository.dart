import '../models/customer_model.dart';

class CustomerRepository {
  Future<List<CustomerModel>> fetchCustomers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: mock data
    return [
      CustomerModel(
        id: 'u001', firstName: 'Nguyễn Văn', lastName: 'An',
        email: 'an.nguyen@gmail.com', phone: '0901234567',
        createdAt: DateTime(2024, 1, 15),
        totalOrders: 12, totalSpent: 850000,
      ),
      CustomerModel(
        id: 'u002', firstName: 'Trần Thị', lastName: 'Bình',
        email: 'binh.tran@gmail.com', phone: '0912345678',
        createdAt: DateTime(2024, 3, 20), gender: 2,
        totalOrders: 5, totalSpent: 320000,
      ),
      CustomerModel(
        id: 'u003', firstName: 'Lê Hoàng', lastName: 'Cường',
        email: 'cuong.le@gmail.com', phone: '0923456789',
        createdAt: DateTime(2024, 5, 10),
        totalOrders: 28, totalSpent: 2100000,
      ),
      CustomerModel(
        id: 'u004', firstName: 'Phạm Minh', lastName: 'Đức',
        email: 'duc.pham@gmail.com', phone: '0934567890',
        createdAt: DateTime(2024, 6, 3),
        totalOrders: 3, totalSpent: 195000,
      ),
      CustomerModel(
        id: 'u005', firstName: 'Hoàng Thị', lastName: 'Lan',
        email: 'lan.hoang@gmail.com', phone: '0945678901',
        createdAt: DateTime(2024, 7, 22), gender: 2,
        totalOrders: 17, totalSpent: 1230000,
      ),
      CustomerModel(
        id: 'u006', firstName: 'Võ Thanh', lastName: 'Hà',
        email: 'ha.vo@gmail.com', phone: '0956789012',
        createdAt: DateTime(2024, 8, 5), gender: 2,
        totalOrders: 8, totalSpent: 540000,
      ),
      CustomerModel(
        id: 'u007', firstName: 'Đặng Quốc', lastName: 'Toản',
        email: 'toan.dang@gmail.com', phone: '0967890123',
        createdAt: DateTime(2024, 9, 14),
        totalOrders: 1, totalSpent: 65000,
      ),
    ];
  }
}
