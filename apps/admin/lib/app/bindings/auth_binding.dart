import "package:core_network/core_network.dart";
import "package:get/get.dart";

import "../../features/auth/data/repositories/auth_repository.dart";
import "../../features/auth/presentation/controllers/auth_controller.dart";

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IApiClient>(
      () => ApiClient(baseUrl: "https://example.com/api"),
      fenix: true,
    );

    Get.lazyPut<AuthRepository>(
      () => AuthRepository(Get.find<IApiClient>()),
      fenix: true,
    );

    Get.lazyPut<AuthController>(
      () => AuthController(Get.find<AuthRepository>()),
    );
  }
}
