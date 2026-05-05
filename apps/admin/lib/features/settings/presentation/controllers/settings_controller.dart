import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/settings_models.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsController extends GetxController {
  SettingsController(this._repository);

  final SettingsRepository _repository;

  // ── Banners ──────────────────────────────────────────────────────────────
  final banners = <BannerModel>[].obs;
  final isBannerEmpty = true.obs; // Rule #2
  final isUploading = false.obs; // Rule #2

  // ── Store Setting ─────────────────────────────────────────────────────────
  final storeSetting = Rxn<StoreSettingModel>();
  final isOpen = false.obs; // Rule #2
  final isSaving = false.obs; // Rule #2

  final storeNameCtrl = TextEditingController();
  final hotlineCtrl = TextEditingController();
  final shippingFeeCtrl = TextEditingController();
  final freeShipCtrl = TextEditingController();

  // ── Common ────────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final error = Rxn<Object>();

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
      final results = await Future.wait([
        _repository.fetchBanners(),
        _repository.fetchStoreSetting(),
      ]);
      banners.assignAll(results[0] as List<BannerModel>);
      isBannerEmpty.value = banners.isEmpty;
      final setting = results[1] as StoreSettingModel;
      storeSetting.value = setting;
      isOpen.value = setting.isOpen;
      storeNameCtrl.text = setting.storeName;
      hotlineCtrl.text = setting.hotline;
      shippingFeeCtrl.text = setting.baseShippingFee.toStringAsFixed(0);
      freeShipCtrl.text = setting.freeShipThreshold.toStringAsFixed(0);
      dev.log('[SETTINGS/VM] ✅ Loaded ${banners.length} banners, isOpen=${setting.isOpen}');
    } catch (e) {
      dev.log('[SETTINGS/VM] ❌ loadData error: $e');
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBanner({
    required String title,
    required Uint8List bytes,
    required String filename,
    String? linkUrl,
  }) async {
    try {
      isUploading.value = true;
      final banner = await _repository.createBanner(
        title: title,
        imageBytes: bytes,
        filename: filename,
        linkUrl: linkUrl,
      );
      banners.add(banner);
      isBannerEmpty.value = false;
      dev.log('[SETTINGS/VM] ✅ Banner added: id=${banner.id}');
      Get.snackbar(
        'Thành công',
        'Banner "${banner.title}" đã được thêm.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      dev.log('[SETTINGS/VM] ❌ addBanner error: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể thêm banner. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> toggleBannerStatus(BannerModel banner) async {
    final newStatus = !banner.isActive;
    final idx = banners.indexWhere((b) => b.id == banner.id);
    if (idx == -1) return;
    banners[idx] = banner.copyWith(isActive: newStatus); // optimistic
    dev.log('[SETTINGS/VM] ⚡ Banner ${banner.id} → isActive=$newStatus (optimistic)');
    try {
      await _repository.toggleBannerStatus(banner.id, isActive: newStatus);
      dev.log('[SETTINGS/VM] ✅ Banner ${banner.id} toggle confirmed');
    } catch (e) {
      banners[idx] = banner.copyWith(isActive: banner.isActive); // rollback
      dev.log('[SETTINGS/VM] ❌ toggleBannerStatus rollback: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái banner.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateBanner({
    required int id,
    required String title,
    String? linkUrl,
    List<int>? imageBytes,
    String? filename,
  }) async {
    try {
      isUploading.value = true;
      final updated = await _repository.updateBanner(
        id: id,
        title: title,
        linkUrl: linkUrl,
        imageBytes: imageBytes,
        filename: filename,
      );
      final idx = banners.indexWhere((b) => b.id == id);
      if (idx != -1) banners[idx] = updated;
      dev.log('[SETTINGS/VM] ✅ Banner updated: $id');
      Get.snackbar('Đã lưu', 'Banner đã được cập nhật.',
          backgroundColor: AppColors.successGreen,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      dev.log('[SETTINGS/VM] ❌ updateBanner: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật banner.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> deleteBanner(int id) async {
    try {
      await _repository.deleteBanner(id);
      banners.removeWhere((b) => b.id == id);
      isBannerEmpty.value = banners.isEmpty;
      dev.log('[SETTINGS/VM] ✅ Banner $id deleted');
      Get.snackbar('Đã xoá', 'Banner đã được xoá.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      dev.log('[SETTINGS/VM] ❌ deleteBanner error: $e');
      Get.snackbar('Lỗi', 'Không thể xoá banner.', snackPosition: SnackPosition.BOTTOM);
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
        baseShippingFee:
            double.tryParse(shippingFeeCtrl.text.trim()) ?? current.baseShippingFee,
        freeShipThreshold:
            double.tryParse(freeShipCtrl.text.trim()) ?? current.freeShipThreshold,
      );
      await _repository.updateStoreSetting(updated);
      storeSetting.value = updated;
      dev.log('[SETTINGS/VM] ✅ Store setting saved: isOpen=${updated.isOpen}');
      Get.snackbar(
        'Đã lưu',
        'Cài đặt cửa hàng đã được cập nhật.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      dev.log('[SETTINGS/VM] ❌ saveStoreSetting error: $e');
      Get.snackbar('Lỗi', 'Không thể lưu cài đặt. Vui lòng thử lại.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }
}
