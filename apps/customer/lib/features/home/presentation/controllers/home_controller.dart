import 'dart:developer' as dev;
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import '../../data/models/home_items.dart';
import '../../data/repositories/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _repository;

  HomeController(this._repository);

  // ── Loading / Error ──────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final error = Rxn<Object>();

  // ── Vị trí giao hàng ─────────────────────────────────────────────────────────
  final locationName = ''.obs;
  final isLocating = false.obs;
  final pickerAddress = ''.obs;

  // ── Thông báo ────────────────────────────────────────────────────────────────
  NotificationController get _notificationController =>
      Get.find<NotificationController>();
  final RxInt unreadNotificationCount = 0.obs;

  // ── Danh mục ─────────────────────────────────────────────────────────────────
  final categories = <CategoryItem>[].obs;
  final selectedCategoryId = Rxn<int>(); // null = Tất cả

  // ── Store setting ────────────────────────────────────────────────────────────
  final storeSetting = Rxn<StoreSettingModel>();
  bool get isStoreOpen => storeSetting.value?.isOpen ?? true;

  // ── Banner quảng cáo ─────────────────────────────────────────────────────────
  final promoBanners = <HomePromoBannerItem>[].obs;

  // ── Toàn bộ món + phân trang ảo UI (chunk 20) ───────────────────────────────
  final List<FoodItemModel> _foodsMaster = [];
  List<FoodItemModel> _filteredView = [];
  int _visibleCount = 0;
  static const int _uiChunk = 20;

  final loadedFoodItems = <FoodItemModel>[].obs;
  /// Số món sau khi lọc danh mục (để hiển thị "x / y món").
  final totalFoodCount = 0.obs;

  /// Toàn bộ món đã tải — dùng cho tìm kiếm client-side.
  List<FoodItemModel> get allFoodItems => List.unmodifiable(_foodsMaster);

  Worker? _unreadSyncWorker;

  @override
  void onInit() {
    super.onInit();
    unreadNotificationCount.value = _notificationController.unreadCount.value;
    _unreadSyncWorker = ever(_notificationController.unreadCount,
        (val) => unreadNotificationCount.value = val);
    SchedulerBinding.instance.addPostFrameCallback((_) => loadData());
  }

  @override
  void onClose() {
    _unreadSyncWorker?.dispose();
    super.onClose();
  }

  Future<void> selectCategory(int? id) async {
    selectedCategoryId.value = id;
    await _applyFilters(resetWindow: true);
  }

  void navigateToFoodDetail(FoodItemModel item) {
    Get.toNamed(AppRoutes.foodDetail, arguments: item.id);
  }

  // ── Location Picker ──────────────────────────────────────────────────────────

  void initPickerLocation() {
    pickerAddress.value = locationName.value;
    fetchCurrentLocation();
  }

  void updatePickerAddress(String address) {
    pickerAddress.value = address;
  }

  Future<void> fetchCurrentLocation() async {
    try {
      isLocating.value = true;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Không có quyền vị trí',
          'Vui lòng cấp quyền vị trí trong cài đặt điện thoại',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      pickerAddress.value = await _repository.reverseGeocode(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      dev.log('[HOME] ❌ fetchCurrentLocation error: $e');
      Get.snackbar(
        'Lỗi vị trí',
        'Không thể lấy vị trí hiện tại. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLocating.value = false;
    }
  }

  void confirmPickerLocation() {
    if (pickerAddress.value.isNotEmpty) {
      locationName.value = pickerAddress.value;
    }
    Get.back();
  }

  // ── Client-side filtered list + UI window ───────────────────────────────────

  Future<void> _computeFiltered() async {
    final id = selectedCategoryId.value;
    final master = _foodsMaster;
    if (master.length > 200) {
      _filteredView = await Isolate.run(() {
        if (id == null) return List<FoodItemModel>.from(master);
        return master.where((f) => f.categoryId == id).toList();
      });
    } else {
      _filteredView = id == null
          ? List<FoodItemModel>.from(master)
          : master.where((f) => f.categoryId == id).toList();
    }
    totalFoodCount.value = _filteredView.length;
  }

  void _applyUiSlice() {
    final end = math.min(_visibleCount, _filteredView.length);
    if (end <= 0) {
      loadedFoodItems.clear();
    } else {
      loadedFoodItems.assignAll(_filteredView.sublist(0, end));
    }
  }

  Future<void> _applyFilters({required bool resetWindow}) async {
    await _computeFiltered();
    if (resetWindow) {
      _visibleCount = math.min(_uiChunk, math.max(_filteredView.length, 0));
    } else {
      _visibleCount = math.min(_visibleCount, _filteredView.length);
    }
    _applyUiSlice();
  }

  bool get hasMoreFoods => _visibleCount < _filteredView.length;

  void loadMoreFoods() {
    if (!hasMoreFoods) return;
    _visibleCount = math.min(
      _visibleCount + _uiChunk,
      _filteredView.length,
    );
    _applyUiSlice();
  }

  // ── Initial load ─────────────────────────────────────────────────────────────

  /// Gọi API không quan trọng: nếu lỗi thì trả về [fallback] thay vì ném exception.
  Future<T> _safe<T>(Future<T> Function() fn, T fallback) async {
    try {
      return await fn();
    } catch (e) {
      dev.log('[HOME] ⚠️ non-critical API error (ignored): $e');
      return fallback;
    }
  }

  Future<void> loadData() async {
    isLoading.value = true;
    error.value = null;
    try {
      // Categories và Foods là bắt buộc — nếu fail sẽ hiện màn hình lỗi.
      // Banners và StoreSetting là phụ trợ — nếu fail thì dùng giá trị mặc định.
      final results = await Future.wait([
        _repository.fetchCategories(),
        _safe(
          _repository.fetchPromoBanners,
          <HomePromoBannerItem>[],
        ),
        _repository.fetchFoodItems(),
        _safe(
          _repository.fetchStoreSetting,
          const StoreSettingModel(
            storeName: '',
            hotline: '',
            isOpen: true,
            baseShippingFee: 0,
            freeShipThreshold: 0,
          ),
        ),
      ]);

      categories.assignAll(results[0] as List<CategoryItem>);
      promoBanners.assignAll(
        (results[1] as List<HomePromoBannerItem>).where((b) => b.isActive),
      );
      storeSetting.value = results[3] as StoreSettingModel;

      _foodsMaster
        ..clear()
        ..addAll(results[2] as List<FoodItemModel>);
      await _applyFilters(resetWindow: true);

      await Future.delayed(Duration.zero);
      isLoading.value = false;
    } catch (e) {
      dev.log('[HOME] ❌ _loadData error: $e');
      error.value = e;
      isLoading.value = false;
    }
  }
}
