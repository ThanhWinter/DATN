import 'dart:developer' as dev;
import 'package:core_network/core_network.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositories/profile_repository.dart';
import 'profile_controller.dart';

class EditProfileController extends GetxController {
  final ProfileRepository _repository;

  EditProfileController(this._repository);

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final user = Get.find<ProfileController>().user.value;
    if (user != null) {
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      phoneController.text = user.phone;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> saveProfile() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng nhập đầy đủ họ và tên.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (phone.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(phone)) {
      Get.snackbar(
        'Số điện thoại không hợp lệ',
        'Số điện thoại phải đúng 10 chữ số.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final profileController = Get.find<ProfileController>();
    final userId = profileController.user.value?.id;
    if (userId == null || userId.isEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _repository.updateProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      await profileController.reloadProfile();

      // Rule #3: delay trước khi điều hướng để tránh lỗi giao diện sau async
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back();

      Get.snackbar(
        'Thành công',
        'Cập nhật thông tin thành công.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      dev.log('[EDIT_PROFILE] ❌ ApiException: ${e.statusCode} ${e.message}');
      errorMessage.value = e.message;
      Get.snackbar(
        'Cập nhật thất bại',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      dev.log('[EDIT_PROFILE] ❌ Unexpected error: $e');
      errorMessage.value = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      Get.snackbar(
        'Lỗi',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
