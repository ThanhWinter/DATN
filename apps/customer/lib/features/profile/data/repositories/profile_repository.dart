import '../models/profile_models.dart';

class ProfileRepository {
  Future<UserModel> fetchUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: mock data
    return const UserModel(
      id: 'u001',
      fullName: 'Hoàng Bình Định',
      email: 'dinhlol2003@gmail.com',
      phone: '0901 234 567',
      totalOrders: 15,
      totalSaved: 85000,
    );
  }
}
