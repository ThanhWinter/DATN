import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:core_network/core_network.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../app/services/auth_service.dart';
import '../../data/repositories/media_repository.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_controller.dart';

class EditProfileController extends GetxController {
  final ProfileRepository _repository;
  final MediaRepository _mediaRepository;

  EditProfileController(this._repository, this._mediaRepository);

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final avatarBytes = Rxn<Uint8List>();
  final currentAvatarUrl = RxnString();

  @override
  void onInit() {
    super.onInit();
    final user = Get.find<ProfileController>().user.value;
    if (user != null) {
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      phoneController.text = user.phone;
      currentAvatarUrl.value = user.avatarUrl;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (xFile == null) return;
    avatarBytes.value = await xFile.readAsBytes();
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

    final profileController = Get.find<ProfileController>();
    final userId = profileController.user.value?.id;
    if (userId == null || userId.isEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Upload avatar first if user picked a new one
      final bytes = avatarBytes.value;
      if (bytes != null) {
        final url = await _mediaRepository.uploadImage(
          bytes,
          'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        dev.log('[EDIT_PROFILE] ✅ Avatar uploaded: $url');
        await Get.find<AuthService>().saveAvatarUrl(url);
      }

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
