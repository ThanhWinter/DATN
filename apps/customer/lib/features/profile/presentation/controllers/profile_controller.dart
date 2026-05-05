import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  final error = Rxn<Object>();
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
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) await _authRepository.unregisterDevice(fcmToken);
      dev.log("[PROFILE] ✅ FCM token unregistered");
    } catch (e) {
      dev.log("[PROFILE] ⚠️ FCM unregister skipped: $e");
    }

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
    if (Get.isRegistered<IApiClient>()) {
      final apiClient = Get.find<IApiClient>();
      apiClient.updateToken(null);
      apiClient.setRefreshToken(null);
    }
    dev.log("[PROFILE] ✅ Local auth cleared — navigating to login");

    await Future.delayed(const Duration(milliseconds: 500));
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> reloadProfile() => _loadData();

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      error.value = null;
      user.value = await _repository.fetchUser();
    } catch (e, stack) {
      dev.log("[PROFILE] ❌ Load failed: $e", error: e, stackTrace: stack);
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }
}
