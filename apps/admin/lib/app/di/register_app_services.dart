import "package:core_network/core_network.dart";
import "package:get/get.dart";

import "../config/app_config.dart";
import "../routes/app_routes.dart";
import "../services/auth_service.dart";
import "../../features/auth/data/repositories/auth_repository.dart";

/// Đăng ký dependency dùng xuyên suốt app. [permanent: true] để GetX không gỡ
/// khi dispose binding/route (tránh `"IApiClient" not found` sau `Get.toNamed` / đổi route).
void registerAppServices() {
  final authService = Get.find<AuthService>();

  if (!Get.isRegistered<IApiClient>()) {
    late final ApiClient apiClient;
    apiClient = ApiClient(
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
        // Dùng trực tiếp biến local — KHÔNG dùng Get.find trong callback
        apiClient.updateToken(null);
        apiClient.setRefreshToken(null);
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(AppRoutes.login);
      },
    );
    final optimizedApiClient = OptimizedApiClient(
      baseUrl: AppConfig.baseUrl,
      innerClient: apiClient,
      enableCache: true,
      cacheTtl: const Duration(minutes: 5),
    );
    Get.put<IApiClient>(optimizedApiClient, permanent: true);
  }

  if (!Get.isRegistered<AuthRepository>()) {
    Get.put<AuthRepository>(
      AuthRepository(Get.find<IApiClient>()),
      permanent: true,
    );
  }
}
