import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
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

  // ── Trạng thái lấy vị trí ────────────────────────────────────────────────────
  final isLocating = false.obs;
  final pickerAddress = ''.obs;

  // ── Thông báo ────────────────────────────────────────────────────────────────
  NotificationController get _notificationController =>
      Get.find<NotificationController>();
  final RxInt unreadNotificationCount = 0.obs;

  // ── Danh mục có hình ảnh ─────────────────────────────────────────────────────
  final categories = <CategoryItem>[].obs;
  final selectedCategorySlug = 'all'.obs;

  // ── Banner quảng cáo ─────────────────────────────────────────────────────────
  final promoBanners = <HomePromoBannerItem>[].obs;

  // ── Tất cả món ăn ────────────────────────────────────────────────────────────
  final _allFoodItems = <FoodItemModel>[];
  final filteredFoodItems = <FoodItemModel>[].obs;

  // ── Món ăn phổ biến nhất ─────────────────────────────────────────────────────
  final popularItems = <FoodItemModel>[].obs;
  final popularCount = 0.obs;
  final isPopularEmpty = true.obs;

  CartController get _cartController => Get.find<CartController>();

  @override
  void onInit() {
    super.onInit();
    unreadNotificationCount.value = _notificationController.unreadCount.value;
    ever(_notificationController.unreadCount,
        (val) => unreadNotificationCount.value = val);
    _loadData();
  }

  void selectCategory(String slug) {
    selectedCategorySlug.value = slug;
    _applyFilter();
  }

  void addToCart(FoodItemModel item) {
    _cartController.addItem(
      CartItemModel(
        id: item.id.toString(),
        name: item.name,
        price: item.priceVnd.toDouble(),
        quantity: 1,
        imageUrl: item.imageUrl,
      ),
    );
  }

  // ── Location Picker ──────────────────────────────────────────────────────────

  void initPickerLocation() {
    pickerAddress.value = locationName.value;
    // Tự động hỏi quyền & lấy GPS ngay khi sheet mở
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

      final address = await _repository.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      pickerAddress.value = address;
    } catch (_) {
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
    if (selectedCategorySlug.value == 'all') {
      filteredFoodItems.assignAll(_allFoodItems);
    } else {
      filteredFoodItems.assignAll(
        _allFoodItems
            .where((item) => item.categorySlug == selectedCategorySlug.value)
            .toList(),
      );
    }
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      error.value = null;

      final results = await Future.wait([
        _repository.fetchCategories(),
        _repository.fetchPromoBanners(),
        _repository.fetchFoodItems(),
      ]);

      categories.assignAll(results[0] as List<CategoryItem>);
      promoBanners.assignAll(results[1] as List<HomePromoBannerItem>);

      _allFoodItems
        ..clear()
        ..addAll(results[2] as List<FoodItemModel>);
      filteredFoodItems.assignAll(_allFoodItems);

      final popular = _allFoodItems
          .where((item) => item.isPopular && item.isAvailable)
          .toList();
      popularItems.assignAll(popular);
      popularCount.value = popular.length;
      isPopularEmpty.value = popular.isEmpty;
    } catch (e) {
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }
}
