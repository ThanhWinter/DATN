import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/services/auth_service.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/data/repositories/order_repository.dart';
import '../../data/models/profile_models.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository;
  final AuthRepository _authRepository;
  final AuthService _authService;
  final OrderRepository _orderRepository;

  ProfileController(
    this._repository,
    this._authRepository,
    this._authService,
    this._orderRepository,
  );

  final user = Rxn<UserModel>();
  final isLoading = true.obs;
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

      // Chạy song song — orders failure không chặn profile hiển thị
      final userFuture = _repository.fetchUser();
      final ordersFuture = _orderRepository.fetchMyOrders().catchError(
        (_) => <OrderModel>[],
      );

      final rawUser = await userFuture;
      final orders = await ordersFuture;

      final completed = orders
          .where((o) => o.status.toUpperCase() == 'COMPLETED')
          .toList();
      final totalSaved = completed.fold(
        0.0,
        (sum, o) => sum + o.discountAmount,
      );

      user.value = UserModel(
        id: rawUser.id,
        firstName: rawUser.firstName,
        lastName: rawUser.lastName,
        email: rawUser.email,
        phone: rawUser.phone,
        avatarUrl: rawUser.avatarUrl,
        totalOrders: completed.length,
        totalSaved: totalSaved,
      );
    } catch (e, stack) {
      dev.log("[PROFILE] ❌ Load failed: $e", error: e, stackTrace: stack);
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }
}
