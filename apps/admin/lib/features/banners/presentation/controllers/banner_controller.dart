import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../../settings/data/models/settings_models.dart';
import '../../../settings/data/repositories/settings_repository.dart';

class BannerController extends GetxController {
  BannerController(this._repository);

  final SettingsRepository _repository;

  final banners = <BannerModel>[].obs;
  final isLoading = true.obs;
  final error = Rxn<Object>();
  final isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      error.value = null;
      banners.assignAll(await _repository.fetchBanners());
      dev.log('[BANNER] ✅ Loaded ${banners.length} banners');
    } catch (e) {
      dev.log('[BANNER] ❌ loadData: $e');
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
      dev.log('[BANNER] ✅ Added: id=${banner.id}');
      Get.snackbar(
        'Thành công',
        'Banner "${banner.title}" đã được thêm.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      dev.log('[BANNER] ❌ addBanner: $e');
      Get.snackbar('Lỗi', 'Không thể thêm banner. Vui lòng thử lại.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> toggleStatus(BannerModel banner) async {
    final newStatus = !banner.isActive;
    final idx = banners.indexWhere((b) => b.id == banner.id);
    if (idx == -1) return;
    banners[idx] = banner.copyWith(isActive: newStatus); // optimistic
    try {
      await _repository.toggleBannerStatus(banner.id, isActive: newStatus);
      dev.log('[BANNER] ✅ Toggle ${banner.id} → $newStatus');
    } catch (e) {
      banners[idx] = banner.copyWith(isActive: banner.isActive); // rollback
      dev.log('[BANNER] ❌ toggleStatus rollback: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái.',
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
      dev.log('[BANNER] ✅ Updated: $id');
      Get.snackbar(
        'Đã lưu',
        'Banner đã được cập nhật.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      dev.log('[BANNER] ❌ updateBanner: $e');
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
      dev.log('[BANNER] ✅ Deleted: $id');
      Get.snackbar('Đã xoá', 'Banner đã được xoá.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      dev.log('[BANNER] ❌ deleteBanner: $e');
      Get.snackbar('Lỗi', 'Không thể xoá banner.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
