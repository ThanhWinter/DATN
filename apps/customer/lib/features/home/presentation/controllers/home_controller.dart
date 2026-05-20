import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:core_utils/core_utils.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../data/models/home_items.dart';
import '../../data/repositories/home_repository.dart';

class HomeController extends GetxController with AutoRefreshMixin {
  final HomeRepository _repository;

  HomeController(this._repository);

  // ── Loading / Error ──────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final error = Rxn<Object>();

  // ── Vị trí giao hàng ─────────────────────────────────────────────────────────
  final locationName = ''.obs;
  final isLocating = false.obs;
  final pickerAddress = ''.obs;

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

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      loadData();
      startPolling(const Duration(seconds: 5), _silentRefresh);
    });
  }

  void selectCategory(int? id) {
    selectedCategoryId.value = id;
    _computeFiltered();
    _visibleCount = math.min(_uiChunk, math.max(_filteredView.length, 0));
    _applyUiSlice();
  }

  void navigateToFoodDetail(FoodItemModel item) {
    Get.toNamed(AppRoutes.foodDetail, arguments: item.id);
  }

  // ── Location Picker ──────────────────────────────────────────────────────────

  void initPickerLocation() {
    // Chỉ sync địa chỉ hiện tại vào picker — GPS fetch là opt-in khi user nhấn nút.
    pickerAddress.value = locationName.value;
  }

  void updatePickerAddress(String address) {
    pickerAddress.value = address;
  }

  Future<void> fetchCurrentLocation() async {
    try {
      isLocating.value = true;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'GPS chưa bật',
          'Vui lòng bật GPS trong cài đặt điện thoại',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        Get.snackbar(
          'Không có quyền vị trí',
          'Vui lòng cấp quyền vị trí trong cài đặt điện thoại',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.medium),
        ).timeout(const Duration(seconds: 10));
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        Get.snackbar(
          'Không lấy được vị trí',
          'Vui lòng nhập địa chỉ thủ công hoặc thử lại.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      pickerAddress.value = await _repository.reverseGeocode(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      dev.log('[HOME] ❌ fetchCurrentLocation error: $e');
      Get.snackbar(
        'Lỗi vị trí',
        'Không thể lấy vị trí. Vui lòng nhập địa chỉ thủ công.',
        snackPosition: SnackPosition.TOP,
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

  void _computeFiltered() {
    final id = selectedCategoryId.value;
    _filteredView = id == null
        ? List<FoodItemModel>.from(_foodsMaster)
        : _foodsMaster.where((f) => f.categoryId == id).toList();
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

  void _applyFilters({required bool resetWindow}) {
    _computeFiltered();
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

  /// Polling ngầm — không bật skeleton, chỉ cập nhật dữ liệu.
  Future<void> _silentRefresh() async {
    try {
      _repository.clearCache();
      final results = await Future.wait([
        _repository.fetchCategories(),
        _safe(_repository.fetchPromoBanners, <HomePromoBannerItem>[]),
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
      final newCats = results[0] as List<CategoryItem>;
      categories.assignAll(newCats);

      // Nếu category đang chọn bị xóa khỏi server → reset về "Tất cả"
      final selId = selectedCategoryId.value;
      if (selId != null && !newCats.any((c) => c.id == selId)) {
        selectedCategoryId.value = null;
      }

      promoBanners.assignAll(
        (results[1] as List<HomePromoBannerItem>).where((b) => b.isActive),
      );
      storeSetting.value = results[3] as StoreSettingModel;
      _foodsMaster
        ..clear()
        ..addAll(_visibleFoods(results[2] as List<FoodItemModel>));
      _applyFilters(resetWindow: false);
    } catch (e) {
      dev.log('[HOME] ⚠️ silentRefresh error (ignored): $e');
    }
  }

  Future<void> loadData() async {
    isLoading.value = true;
    error.value = null;
    try {
      _repository.clearCache();
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
        ..addAll(_visibleFoods(results[2] as List<FoodItemModel>));
      _applyFilters(resetWindow: true);

      await Future.delayed(Duration.zero);
      isLoading.value = false;
    } catch (e) {
      dev.log('[HOME] ❌ _loadData error: $e');
      error.value = e;
      isLoading.value = false;
    }
  }

  Iterable<FoodItemModel> _visibleFoods(Iterable<FoodItemModel> foods) {
    return foods.where((food) => food.isAvailable);
  }
}
