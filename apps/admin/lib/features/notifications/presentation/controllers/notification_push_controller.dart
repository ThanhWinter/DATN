import 'dart:developer' as dev;

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositories/notification_push_repository.dart';

class NotificationPushController extends GetxController {
  NotificationPushController(this._repository);

  final NotificationPushRepository _repository;

  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();
  final isSending = false.obs;
  final canSend = false.obs; // Rule #2
  final titlePreview = ''.obs;
  final bodyPreview = ''.obs;

  @override
  void onInit() {
    super.onInit();
    titleCtrl.addListener(_updateCanSend);
    bodyCtrl.addListener(_updateCanSend);
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    bodyCtrl.dispose();
    super.onClose();
  }

  void _updateCanSend() {
    titlePreview.value = titleCtrl.text;
    bodyPreview.value = bodyCtrl.text;
    canSend.value =
        titleCtrl.text.trim().isNotEmpty && bodyCtrl.text.trim().isNotEmpty;
  }

  Future<void> sendBroadcast() async {
    if (!canSend.value || isSending.value) return;
    try {
      isSending.value = true;
      await _repository.broadcastToAll(
        title: titleCtrl.text.trim(),
        body: bodyCtrl.text.trim(),
      );
      dev.log('[NOTIF_PUSH/VM] ✅ Broadcast sent');
      titleCtrl.clear();
      bodyCtrl.clear();
      canSend.value = false;
      titlePreview.value = '';
      bodyPreview.value = '';
      Get.snackbar(
        'Đã gửi!',
        'Thông báo đã được gửi đến tất cả khách hàng.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on UnsupportedError catch (e) {
      dev.log('[NOTIF_PUSH/VM] ❌ sendBroadcast unsupported: $e');
      Get.snackbar(
        'Chưa đồng bộ backend',
        e.message ?? 'Tính năng cần API từ team BE.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      dev.log('[NOTIF_PUSH/VM] ❌ sendBroadcast error: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể gửi thông báo. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }
}
