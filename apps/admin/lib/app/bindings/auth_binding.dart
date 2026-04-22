import 'package:get/get.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<AuthController>(() => AuthController(Get.find<AuthRepository>()));
  }
}
