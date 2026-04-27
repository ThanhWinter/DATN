import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/services/auth_service.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../data/models/profile_models.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository;
  final AuthRepository _authRepository;
  final AuthService _authService;

  ProfileController(this._repository, this._authRepository, this._authService);

  final user = Rxn<UserModel>();
  final isLoading = false.obs;
  final notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  Future<void> logout() async {
    dev.log("[PROFILE] Logging out — calling server to invalidate token");

    try {
      final token = _authService.getToken();
      if (token != null && token.isNotEmpty) {
        await _authRepository.logout(token: token);
        dev.log("[PROFILE] ✅ Token invalidated on server");
      }
    } catch (e) {
      // Dù server lỗi vẫn cho logout local để không kẹt user
      dev.log("[PROFILE] ⚠️ Server logout failed (proceeding locally): $e");
    }

    await _authService.clearAuth();
    final apiClient = Get.find<IApiClient>();
    apiClient.updateToken(null);
    apiClient.setRefreshToken(null);
    dev.log("[PROFILE] ✅ Local auth cleared — navigating to login");

    await Future.delayed(const Duration(milliseconds: 500));
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> reloadProfile() => _loadData();

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      user.value = await _repository.fetchUser();
    } finally {
      isLoading.value = false;
    }
  }
}
