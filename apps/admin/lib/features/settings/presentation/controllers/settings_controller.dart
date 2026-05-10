import 'dart:developer' as dev;

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/settings_models.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsController extends GetxController {
  SettingsController(this._repository);

  final SettingsRepository _repository;

  final storeSetting = Rxn<StoreSettingModel>();
  final isOpen = false.obs;
  final isSaving = false.obs;
  final isLoading = false.obs;
  final error = Rxn<Object>();

  final storeNameCtrl = TextEditingController();
  final hotlineCtrl = TextEditingController();
  final shippingFeeCtrl = TextEditingController();
  final freeShipCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    storeNameCtrl.dispose();
    hotlineCtrl.dispose();
    shippingFeeCtrl.dispose();
    freeShipCtrl.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      error.value = null;
      final setting = await _repository.fetchStoreSetting();
      storeSetting.value = setting;
      isOpen.value = setting.isOpen;
      storeNameCtrl.text = setting.storeName;
      hotlineCtrl.text = setting.hotline;
      shippingFeeCtrl.text = setting.baseShippingFee.toStringAsFixed(0);
      freeShipCtrl.text = setting.freeShipThreshold.toStringAsFixed(0);
      dev.log('[SETTINGS] ✅ Loaded store setting');
    } catch (e) {
      dev.log('[SETTINGS] ❌ loadData: $e');
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveStoreSetting() async {
    final current = storeSetting.value;
    if (current == null) return;
    try {
      isSaving.value = true;
      final updated = current.copyWith(
        storeName: storeNameCtrl.text.trim(),
        hotline: hotlineCtrl.text.trim(),
        isOpen: isOpen.value,
        baseShippingFee: double.tryParse(shippingFeeCtrl.text.trim()) ??
            current.baseShippingFee,
        freeShipThreshold: double.tryParse(freeShipCtrl.text.trim()) ??
            current.freeShipThreshold,
      );
      await _repository.updateStoreSetting(updated);
      storeSetting.value = updated;
      dev.log('[SETTINGS] ✅ Store setting saved');
      Get.snackbar(
        'Đã lưu',
        'Cài đặt cửa hàng đã được cập nhật.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      dev.log('[SETTINGS] ❌ saveStoreSetting: $e');
      Get.snackbar('Lỗi', 'Không thể lưu cài đặt. Vui lòng thử lại.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }
}
