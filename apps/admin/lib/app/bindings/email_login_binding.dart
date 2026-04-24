import 'package:get/get.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/email_login_controller.dart';
import '../services/auth_service.dart';

class EmailLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailLoginController>(
      () => EmailLoginController(
        Get.find<AuthRepository>(),
        Get.find<AuthService>(),
      ),
    );
  }
}
