import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/services/auth_service.dart';
import '../../data/repositories/profile_repository.dart';

class ChangePasswordController extends GetxController {
  ChangePasswordController(this._repository, this._authService);

  final ProfileRepository _repository;
  final AuthService _authService;

  final newPasswordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final showNew = false.obs;
  final showConfirm = false.obs;
  final isSaving = false.obs;

  static final _pwRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,16}$');

  @override
  void onClose() {
    newPasswordCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
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

    final userId = _authService.getUserId();
    if (userId == null) return;

    isSaving.value = true;
    try {
      await _repository.changePassword(userId: userId, newPassword: pw);
      Get.back();
      Get.snackbar(
        'Đã đổi mật khẩu',
        'Mật khẩu mới đã được áp dụng.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      dev.log('[CHANGE_PW/CUSTOMER] ✅ Password changed');
    } on ApiException catch (e) {
      dev.log('[CHANGE_PW/CUSTOMER] ❌ ${e.statusCode} ${e.message}');
      Get.snackbar('Lỗi', e.message,
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } catch (e) {
      dev.log('[CHANGE_PW/CUSTOMER] ❌ $e');
      Get.snackbar('Lỗi', 'Không thể đổi mật khẩu: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isSaving.value = false;
    }
  }
}
