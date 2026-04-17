import 'package:get/get.dart';

import '../../data/models/profile_models.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository;

  ProfileController(this._repository);

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
    await Future.delayed(const Duration(milliseconds: 500));
    Get.offAllNamed('/login');
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      user.value = await _repository.fetchUser();
    } finally {
      isLoading.value = false;
    }
  }
}
