import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  ProfileController(this._apiClient);

  final IApiClient _apiClient;

  final isLoading = false.obs;
  final adminName = ''.obs;
  final adminEmail = ''.obs;
  final adminPhone = ''.obs;
  final adminRoles = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMyInfo();
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
        (data['roles'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
      dev.log('[PROFILE/VM] ✅ Admin info loaded: ${adminEmail.value} | roles=$adminRoles');
    } catch (e) {
      dev.log('[PROFILE/VM] ❌ loadMyInfo error: $e');
      // Không hiển thị lỗi toàn màn hình — profile vẫn render với giá trị rỗng
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    dev.log('[PROFILE/VM] Admin logout');
    await Get.find<AuthController>().logout();
  }
}
