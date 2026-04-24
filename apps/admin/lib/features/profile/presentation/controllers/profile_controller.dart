import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final adminName = 'Admin FoodHit'.obs;
  final adminEmail = 'admin@foodhit.vn'.obs;
  final adminPhone = '0901234567'.obs;

  Future<void> logout() async {
    await Get.find<AuthController>().logout();
  }
}
