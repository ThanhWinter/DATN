import 'dart:developer' as dev;

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

  // ── Tất cả món ăn ────────────────────────────────────────────────────────────
  final _allFoodItems = <FoodItemModel>[];
  List<FoodItemModel> get allFoodItems => List.unmodifiable(_allFoodItems);
  final filteredFoodItems = <FoodItemModel>[].obs;
  final isFilteredEmpty = true.obs;

  // ── Nổi bật (6 món đầu tiên available) ──────────────────────────────────────
  final featuredItems = <FoodItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    unreadNotificationCount.value = _notificationController.unreadCount.value;
    ever(_notificationController.unreadCount,
        (val) => unreadNotificationCount.value = val);
    _loadData();
  }

  void selectCategory(int? id) {
    selectedCategoryId.value = id;
    _applyFilter();
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

  // ── Private ──────────────────────────────────────────────────────────────────

  void _applyFilter() {
    final id = selectedCategoryId.value;
    final filtered = id == null
        ? _allFoodItems
        : _allFoodItems.where((item) => item.categoryId == id).toList();
    filteredFoodItems.assignAll(filtered);
    isFilteredEmpty.value = filtered.isEmpty;
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    error.value = null;
    try {
      final results = await Future.wait([
        _repository.fetchCategories(),
        _repository.fetchPromoBanners(),
        _repository.fetchFoodItems(),
        _repository.fetchStoreSetting(),
      ]);

      categories.assignAll(results[0] as List<CategoryItem>);
      promoBanners.assignAll(results[1] as List<HomePromoBannerItem>);
      storeSetting.value = results[3] as StoreSettingModel;

      _allFoodItems
        ..clear()
        ..addAll(results[2] as List<FoodItemModel>);

      filteredFoodItems.assignAll(_allFoodItems);
      isFilteredEmpty.value = _allFoodItems.isEmpty;

      featuredItems.assignAll(
        _allFoodItems.where((item) => item.isAvailable).take(6),
      );

      // Yield one event-loop turn so any pending touch events (e.g. tab tap)
      // can be processed before HomeView rebuilds from scratch.
      await Future.delayed(Duration.zero);
      isLoading.value = false;
    } catch (e) {
      dev.log('[HOME] ❌ _loadData error: $e');
      error.value = e;
      isLoading.value = false;
    }
  }
}
