import "package:core_network/core_network.dart";
import "package:get/get.dart";

import "../config/app_config.dart";
import "../routes/app_routes.dart";
import "../services/auth_service.dart";
import "../../features/auth/data/repositories/auth_repository.dart";

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    final authService = Get.find<AuthService>();

    Get.lazyPut<IApiClient>(
      () => ApiClient(
        baseUrl: AppConfig.baseUrl,
        token: authService.getToken(),
        refreshToken: authService.refreshToken,
        onTokenRefreshed: (accessToken, refreshToken) async {
          await authService.saveToken(
            accessToken,
            refreshToken: refreshToken,
          );
        },
        onAuthFailed: () async {
          await authService.clearAuth();
          await Future.delayed(const Duration(milliseconds: 500));
          Get.offAllNamed(AppRoutes.login);
        },
      ),
      fenix: true,
    );

    Get.lazyPut<AuthRepository>(
      () => AuthRepository(Get.find<IApiClient>()),
      fenix: true,
    );
  }
}
