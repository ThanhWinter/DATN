import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositories/profile_admin_repository.dart';

class ChangePasswordController extends GetxController {
  ChangePasswordController(this._repository);

  final ProfileAdminRepository _repository;

  final newPasswordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final showNew = false.obs;
  final showConfirm = false.obs;
  final isSaving = false.obs;

  // Regex backend yêu cầu: 8-16 ký tự, có chữ hoa, thường, số, ký tự đặc biệt
  static final _pwRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,16}$');

  String? _userId;

  @override
  void onInit() {
    super.onInit();
    _loadUserId();
  }

  @override
  void onClose() {
    newPasswordCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadUserId() async {
    try {
      final data = await _repository.getMyInfo();
      _userId = data['id'] as String?;
    } catch (e) {
      dev.log('[CHANGE_PW/VM] ❌ _loadUserId error: $e');
    }
  }

  Future<void> save() async {
    final pw = newPasswordCtrl.text;
    final confirm = confirmCtrl.text;

    if (pw != confirm) {
      Get.snackbar('Lỗi', 'Mật khẩu xác nhận không khớp.',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
      return;
    }
    if (!_pwRegex.hasMatch(pw)) {
      Get.snackbar(
        'Mật khẩu không hợp lệ',
        'Cần 8–16 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt (@\$!%*?&).',
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }
    final id = _userId;
    if (id == null) return;

    isSaving.value = true;
    try {
      await _repository.changePassword(userId: id, newPassword: pw);
      Get.back();
      Get.snackbar(
        'Đã đổi mật khẩu',
        'Mật khẩu mới đã được áp dụng.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      dev.log('[CHANGE_PW/VM] ✅ Password changed');
    } on ApiException catch (e) {
      dev.log('[CHANGE_PW/VM] ❌ ApiException: ${e.statusCode} ${e.message}');
      Get.snackbar('Lỗi', e.message,
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } catch (e) {
      dev.log('[CHANGE_PW/VM] ❌ save error: $e');
      Get.snackbar('Lỗi', 'Không thể đổi mật khẩu: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isSaving.value = false;
    }
  }
}
