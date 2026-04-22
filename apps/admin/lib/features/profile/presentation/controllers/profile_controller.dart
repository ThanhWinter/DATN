import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';

class ProfileController extends GetxController {
  final adminName = 'Admin FoodHit'.obs;
  final adminEmail = 'admin@foodhit.vn'.obs;
  final adminPhone = '0901234567'.obs;

  // Xoá toàn bộ controllers đã đăng ký rồi navigate — tránh Get.find crash
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    Get.deleteAll(force: true);
    Get.offAllNamed(AppRoutes.login);
  }
}
