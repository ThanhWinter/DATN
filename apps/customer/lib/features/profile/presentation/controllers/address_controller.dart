import 'dart:developer' as dev;

import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../data/models/address_model.dart';
import '../../data/repositories/address_repository.dart';

class AddressController extends GetxController {
  AddressController(this._repository);

  final AddressRepository _repository;

  final isLoading = true.obs;
  final error = Rxn<Object>();
  final addresses = <UserAddressModel>[].obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    isLoading.value = true;
    error.value = null;
    try {
      addresses.assignAll(await _repository.fetchAddresses());
      dev.log('[ADDRESS/VM] ✅ Loaded ${addresses.length} addresses');
    } catch (e) {
      dev.log('[ADDRESS/VM] ❌ load: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAddress({
    required String fullAddress,
    String? label,
  }) async {
    isSubmitting.value = true;
    try {
      final addr = await _repository.createAddress(
        fullAddress: fullAddress,
        label: label,
      );
      addresses.add(addr);
      Get.back();
      dev.log('[ADDRESS/VM] ✅ Created: ${addr.id}');
      Get.snackbar(
        'Đã lưu',
        'Địa chỉ mới đã được thêm.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      dev.log('[ADDRESS/VM] ❌ create: $e');
      Get.snackbar('Lỗi', 'Không thể thêm địa chỉ.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateAddress({
    required int id,
    required String fullAddress,
    String? label,
  }) async {
    isSubmitting.value = true;
    try {
      final updated = await _repository.updateAddress(
        id: id,
        fullAddress: fullAddress,
        label: label,
      );
      final idx = addresses.indexWhere((a) => a.id == id);
      if (idx != -1) addresses[idx] = updated;
      Get.back();
      dev.log('[ADDRESS/VM] ✅ Updated: $id');
      Get.snackbar(
        'Đã lưu',
        'Địa chỉ đã được cập nhật.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      dev.log('[ADDRESS/VM] ❌ update: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật địa chỉ.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      await _repository.deleteAddress(id);
      addresses.removeWhere((a) => a.id == id);
      dev.log('[ADDRESS/VM] ✅ Deleted: $id');
      Get.snackbar('Đã xoá', 'Địa chỉ đã được xoá.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      dev.log('[ADDRESS/VM] ❌ delete: $e');
      Get.snackbar('Lỗi', 'Không thể xoá địa chỉ.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> setDefault(int id) async {
    try {
      await _repository.setDefaultAddress(id);
      for (var i = 0; i < addresses.length; i++) {
        addresses[i] = addresses[i].copyWith(isDefault: addresses[i].id == id);
      }
      dev.log('[ADDRESS/VM] ✅ Default set: $id');
    } catch (e) {
      dev.log('[ADDRESS/VM] ❌ setDefault: $e');
      Get.snackbar('Lỗi', 'Không thể đặt địa chỉ mặc định.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
