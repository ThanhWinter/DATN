import 'dart:developer' as dev;

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/config/app_config.dart';
import '../../data/repositories/profile_admin_repository.dart';
import 'profile_controller.dart';

class PersonalInfoController extends GetxController {
  PersonalInfoController(this._repository);

  final ProfileAdminRepository _repository;

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final isLoading = true.obs;
  final isSaving = false.obs;
  final isUploadingAvatar = false.obs;
  final avatarUrl = Rxn<String>();
  final adminEmail = ''.obs;

  String? _userId;

  @override
  void onInit() {
    super.onInit();
    _loadMyInfo();
  }

  @override
  void onClose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadMyInfo() async {
    try {
      final data = await _repository.getMyInfo();
      _userId = data['id'] as String?;
      firstNameCtrl.text = data['firstName'] as String? ?? '';
      lastNameCtrl.text = data['lastName'] as String? ?? '';
      phoneCtrl.text = data['phone'] as String? ?? '';
      adminEmail.value = data['email'] as String? ?? '';
      avatarUrl.value = data['avatarUrl'] as String?;
      dev.log('[PERSONAL_INFO/VM] ✅ Loaded info for $_userId');
    } catch (e) {
      dev.log('[PERSONAL_INFO/VM] ❌ loadMyInfo error: $e');
      Get.snackbar('Lỗi', 'Không thể tải thông tin: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked == null) return;

    isUploadingAvatar.value = true;
    try {
      final bytes = await picked.readAsBytes();
      final filename = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final uploadedName = await _repository.uploadAvatar(bytes, filename);
      avatarUrl.value = '${AppConfig.baseUrl}/media/$uploadedName';
      dev.log('[PERSONAL_INFO/VM] ✅ Avatar uploaded: ${avatarUrl.value}');
    } catch (e) {
      dev.log('[PERSONAL_INFO/VM] ❌ pickAvatar error: $e');
      Get.snackbar('Lỗi', 'Không thể tải ảnh lên: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  Future<void> save() async {
    final id = _userId;
    if (id == null) return;

    isSaving.value = true;
    try {
      await _repository.updateProfile(
        userId: id,
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        avatarUrl: avatarUrl.value,
      );
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().loadMyInfo();
      }
      Get.back(result: true);
      Get.snackbar(
        'Đã lưu',
        'Thông tin cá nhân đã được cập nhật.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      dev.log('[PERSONAL_INFO/VM] ✅ Profile saved');
    } catch (e) {
      dev.log('[PERSONAL_INFO/VM] ❌ save error: $e');
      Get.snackbar('Lỗi', 'Không thể lưu thông tin: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isSaving.value = false;
    }
  }
}
