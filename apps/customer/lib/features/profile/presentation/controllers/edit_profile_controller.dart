import 'dart:developer' as dev;
import 'package:core_network/core_network.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/config/app_config.dart';
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
  final isUploadingAvatar = false.obs;
  final errorMessage = ''.obs;
  final selectedAvatarUrl = RxnString();

  @override
  void onInit() {
    super.onInit();
    final user = Get.find<ProfileController>().user.value;
    if (user != null) {
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      phoneController.text = user.phone;
      selectedAvatarUrl.value = user.avatarUrl;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (picked == null) return;

    try {
      isUploadingAvatar.value = true;
      final bytes = await picked.readAsBytes();
      final filename = picked.name.isNotEmpty ? picked.name : 'avatar.jpg';
      final uploadedName = await _mediaRepository.uploadImage(bytes, filename);
      selectedAvatarUrl.value = '${AppConfig.baseUrl}/media/$uploadedName';
      dev.log('[EDIT_PROFILE] ✅ Avatar uploaded: $uploadedName');
    } on ApiException catch (e) {
      dev.log('[EDIT_PROFILE] ❌ Upload failed: ${e.statusCode} ${e.message}');
      Get.snackbar(
        'Upload thất bại',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      dev.log('[EDIT_PROFILE] ❌ Upload error: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tải ảnh lên. Vui lòng thử lại.',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  Future<void> saveProfile() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng nhập đầy đủ họ và tên.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (phone.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(phone)) {
      Get.snackbar(
        'Số điện thoại không hợp lệ',
        'Số điện thoại phải đúng 10 chữ số.',
        snackPosition: SnackPosition.TOP,
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
        avatarUrl: selectedAvatarUrl.value,
      );

      await profileController.reloadProfile();

      await Future.delayed(const Duration(milliseconds: 500));
      Get.back();

      Get.snackbar(
        'Thành công',
        'Cập nhật thông tin thành công.',
        snackPosition: SnackPosition.TOP,
      );
    } on ApiException catch (e) {
      dev.log('[EDIT_PROFILE] ❌ ApiException: ${e.statusCode} ${e.message}');
      errorMessage.value = e.message;
      Get.snackbar(
        'Cập nhật thất bại',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      dev.log('[EDIT_PROFILE] ❌ Unexpected error: $e');
      errorMessage.value = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      Get.snackbar(
        'Lỗi',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
