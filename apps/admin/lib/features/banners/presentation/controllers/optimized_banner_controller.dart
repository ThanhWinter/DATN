import 'dart:developer' as dev;
import 'dart:typed_data';


import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../settings/data/models/settings_models.dart';
import '../../../settings/data/repositories/settings_repository.dart';

/// Optimized Banner Controller with async improvements and better state management
class OptimizedBannerController extends GetxController {
  OptimizedBannerController(this._repository);

  final SettingsRepository _repository;

  // Reactive state variables
  final banners = <BannerModel>[].obs;
  final isLoading = false.obs;
  final error = Rxn<String>();
  final isUploading = false.obs;
  final searchText = ''.obs;
  final selectedCategory = Rxn<String>();

  // Computed reactive values
  late final RxList<BannerModel> filteredBanners;
  late final RxInt activeBannerCount;
  late final RxInt inactiveBannerCount;

  late final Worker _bannersWorker;
  late final Worker _categoryWorker;
  late final Worker _searchWorker;

  @override
  void onInit() {
    super.onInit();
    _setupComputedValues();
    _setupSearchListener();
    loadData();
  }

  void _setupComputedValues() {
    // Filtered banners based on search and category
    filteredBanners = <BannerModel>[].obs;

    // Computed counts
    activeBannerCount = 0.obs;
    inactiveBannerCount = 0.obs;

    // Update computed values when banners change
    _bannersWorker = ever(banners, (_) => _updateComputedValues());
    _categoryWorker = ever(selectedCategory, (_) => _updateFilteredBanners());
  }

  void _setupSearchListener() {
    _searchWorker = debounce<String>(searchText, (_) => _updateFilteredBanners(), time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    _bannersWorker.dispose();
    _categoryWorker.dispose();
    _searchWorker.dispose();
    super.onClose();
  }

  void _updateComputedValues() {
    final active = banners.where((b) => b.isActive).length;
    final inactive = banners.length - active;

    activeBannerCount.value = active;
    inactiveBannerCount.value = inactive;

    _updateFilteredBanners();
  }

  void _updateFilteredBanners() {
    var filtered = banners.where((banner) {
      final matchesSearch = searchText.value.isEmpty ||
          banner.title.toLowerCase().contains(searchText.value.toLowerCase());
      final matchesCategory = selectedCategory.value == null ||
          selectedCategory.value == 'all' ||
          _matchesCategory(banner, selectedCategory.value!);
      return matchesSearch && matchesCategory;
    }).toList();

    filteredBanners.assignAll(filtered);
  }

  bool _matchesCategory(BannerModel banner, String category) {
    // Simple category matching - can be enhanced
    switch (category) {
      case 'active':
        return banner.isActive;
      case 'inactive':
        return !banner.isActive;
      default:
        return true;
    }
  }

  /// Load data with error handling and loading states
  Future<void> loadData({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
      error.value = null;
    }

    try {
      final stopwatch = Stopwatch()..start();
      final data = await _repository.fetchBanners();
      stopwatch.stop();

      banners.assignAll(data);

      dev.log(
          '[BANNER] ✅ Loaded ${banners.length} banners in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      error.value = e.toString();
      dev.log('[BANNER] ❌ loadData: $e');

      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách banner. Vui lòng thử lại.',
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  /// Refresh data with pull-to-refresh support
  Future<void> refreshData() async {
    await loadData(showLoading: false);
  }

  /// Add banner with optimistic updates
  Future<void> addBanner({
    required String title,
    required Uint8List bytes,
    required String filename,
    String? linkUrl,
  }) async {
    // Optimistic UI update
    final tempBanner = BannerModel(
      id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
      title: title,
      imageUrl: null, // Will be updated after upload
      linkUrl: linkUrl,
      isActive: true,
      displayOrder: banners.length,
    );

    banners.insert(0, tempBanner); // Add to top of list
    isUploading.value = true;

    try {
      final stopwatch = Stopwatch()..start();
      final banner = await _repository.createBanner(
        title: title,
        imageBytes: bytes,
        filename: filename,
        linkUrl: linkUrl,
      );
      stopwatch.stop();

      // Replace temporary banner with real one
      final tempIndex = banners.indexWhere((b) => b.id == tempBanner.id);
      if (tempIndex != -1) {
        banners[tempIndex] = banner;
      }

      dev.log(
          '[BANNER] ✅ Added banner ${banner.id} in ${stopwatch.elapsedMilliseconds}ms');

      Get.snackbar(
        'Thành công',
        'Banner "${banner.title}" đã được thêm.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Remove optimistic update on error
      banners.removeWhere((b) => b.id == tempBanner.id);

      dev.log('[BANNER] ❌ addBanner: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể thêm banner. Vui lòng thử lại.',
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploading.value = false;
    }
  }

  /// Toggle status with optimistic updates
  Future<void> toggleStatus(BannerModel banner) async {
    final originalStatus = banner.isActive;
    final newStatus = !originalStatus;
    final idx = banners.indexWhere((b) => b.id == banner.id);

    if (idx == -1) return;

    // Optimistic update
    banners[idx] = banner.copyWith(isActive: newStatus);

    try {
      await _repository.toggleBannerStatus(banner.id, isActive: newStatus);
      dev.log('[BANNER] ✅ Toggle ${banner.id} → $newStatus');
    } catch (e) {
      // Rollback on error
      banners[idx] = banner.copyWith(isActive: originalStatus);
      dev.log('[BANNER] ❌ toggleStatus rollback: $e');

      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật trạng thái.',
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Update banner with optimistic updates
  Future<void> updateBanner({
    required int id,
    required String title,
    String? linkUrl,
    List<int>? imageBytes,
    String? filename,
  }) async {
    final originalBanner = banners.firstWhereOrNull((b) => b.id == id);
    if (originalBanner == null) return;

    // Optimistic update — cập nhật title/linkUrl ngay để UI phản hồi tức thì
    final idx = banners.indexWhere((b) => b.id == id);
    if (idx != -1) {
      banners[idx] = originalBanner.copyWith(title: title, linkUrl: linkUrl);
    }

    isUploading.value = true;

    try {
      final stopwatch = Stopwatch()..start();
      final finalBanner = await _repository.updateBanner(
        id: id,
        title: title,
        linkUrl: linkUrl,
        imageBytes: imageBytes,
        filename: filename,
      );
      stopwatch.stop();

      // Update with final data from server
      final finalIdx = banners.indexWhere((b) => b.id == id);
      if (finalIdx != -1) {
        banners[finalIdx] = finalBanner;
      }

      dev.log(
          '[BANNER] ✅ Updated banner $id in ${stopwatch.elapsedMilliseconds}ms');

      Get.snackbar(
        'Đã lưu',
        'Banner đã được cập nhật.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Rollback on error
      final rollbackBanner = originalBanner;

      final rollbackIdx = banners.indexWhere((b) => b.id == id);
      if (rollbackIdx != -1) {
        banners[rollbackIdx] = rollbackBanner;
      }

      dev.log('[BANNER] ❌ updateBanner rollback: $e');

      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật banner.',
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploading.value = false;
    }
  }

  /// Delete banner with optimistic updates
  Future<void> deleteBanner(BannerModel banner) async {
    // Confirm deletion
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa banner "${banner.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Optimistic removal
    final originalIndex = banners.indexWhere((b) => b.id == banner.id);
    if (originalIndex == -1) return;

    final removedBanner = banners.removeAt(originalIndex);

    try {
      await _repository.deleteBanner(banner.id);
      dev.log('[BANNER] ✅ Deleted banner ${banner.id}');

      Get.snackbar(
        'Đã xoá',
        'Banner đã được xoá.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Rollback on error
      banners.insert(originalIndex, removedBanner);
      dev.log('[BANNER] ❌ deleteBanner rollback: $e');

      Get.snackbar(
        'Lỗi',
        'Không thể xoá banner.',
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Batch operations
  Future<void> batchToggleStatus(
      List<BannerModel> bannerList, bool newStatus) async {
    final originalStates = bannerList.map((b) => b.isActive).toList();

    // Optimistic updates
    for (int i = 0; i < bannerList.length; i++) {
      final idx = banners.indexWhere((b) => b.id == bannerList[i].id);
      if (idx != -1) {
        banners[idx] = bannerList[i].copyWith(isActive: newStatus);
      }
    }

    try {
      await Future.wait(
        bannerList.map((banner) =>
            _repository.toggleBannerStatus(banner.id, isActive: newStatus)),
      );

      dev.log('[BANNER] ✅ Batch toggled ${bannerList.length} banners');

      Get.snackbar(
        'Thành công',
        'Đã cập nhật ${bannerList.length} banner.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Rollback all changes
      for (int i = 0; i < bannerList.length; i++) {
        final idx = banners.indexWhere((b) => b.id == bannerList[i].id);
        if (idx != -1) {
          banners[idx] = bannerList[i].copyWith(isActive: originalStates[i]);
        }
      }

      dev.log('[BANNER] ❌ batchToggleStatus rollback: $e');

      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật các banner đã chọn.',
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Search functionality
  void searchBanners(String query) {
    searchText.value = query;
  }

  /// Filter by category
  void filterByCategory(String? category) {
    selectedCategory.value = category;
  }

  /// Clear filters
  void clearFilters() {
    searchText.value = '';
    selectedCategory.value = null;
  }
}
