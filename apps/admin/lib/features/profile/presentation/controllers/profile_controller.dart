import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:core_utils/core_utils.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/data/repositories/statistic_repository.dart';

class ProfileController extends GetxController with AutoRefreshMixin {
  ProfileController(this._apiClient, this._statisticRepository);

  final IApiClient _apiClient;
  final StatisticRepository _statisticRepository;

  final isLoading = false.obs;
  final adminName = ''.obs;
  final adminEmail = ''.obs;
  final adminPhone = ''.obs;
  final adminRoles = <String>[].obs;

  // Dashboard stats — displayed on profile tab
  final todayOrders = 0.obs;
  final todayRevenue = 0.0.obs;
  final totalFoods = 0.obs;
  final isStatsLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyInfo();
    loadStats();
    startPolling(const Duration(seconds: 120), _silentRefresh);
  }

  Future<void> _silentRefresh() async {
    try {
      final res = await _apiClient.get('/users/my-info');
      final data = res['result'] as Map<String, dynamic>;
      adminName.value =
          '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
      adminEmail.value = data['email'] as String? ?? '';
      adminPhone.value = data['phone'] as String? ?? '';
      adminRoles.assignAll(
        (data['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            [],
      );
      final stats = await _statisticRepository.getDashboard();
      todayOrders.value = stats.todayOrders;
      todayRevenue.value = stats.todayRevenue;
      totalFoods.value = stats.totalFoods;
    } catch (e) {
      dev.log('[PROFILE/VM] ⚠️ silentRefresh error (ignored): $e');
    }
  }

  Future<void> reload() async {
    await Future.wait([
      loadMyInfo(),
      loadStats(),
    ]);
  }

  Future<void> loadMyInfo() async {
    dev.log('[PROFILE/VM] Loading admin info...');
    isLoading.value = true;
    try {
      final res = await _apiClient.get('/users/my-info');
      final data = res['result'] as Map<String, dynamic>;
      final firstName = data['firstName'] as String? ?? '';
      final lastName = data['lastName'] as String? ?? '';
      adminName.value = '$firstName $lastName'.trim();
      adminEmail.value = data['email'] as String? ?? '';
      adminPhone.value = data['phone'] as String? ?? '';
      adminRoles.assignAll(
        (data['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            [],
      );
      dev.log('[PROFILE/VM] ✅ loaded: ${adminEmail.value}');
    } catch (e) {
      dev.log('[PROFILE/VM] ❌ loadMyInfo: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStats() async {
    try {
      isStatsLoading.value = true;
      final stats = await _statisticRepository.getDashboard();
      todayOrders.value = stats.todayOrders;
      todayRevenue.value = stats.todayRevenue;
      totalFoods.value = stats.totalFoods;
      dev.log('[PROFILE/VM] ✅ stats loaded');
    } catch (e) {
      dev.log('[PROFILE/VM] ⚠️ stats load skipped: $e');
    } finally {
      isStatsLoading.value = false;
    }
  }

  Future<void> logout() async {
    dev.log('[PROFILE/VM] Admin logout');
    await Get.find<AuthController>().logout();
  }
}
