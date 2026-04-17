import 'package:get/get.dart';

import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import '../../data/models/home_items.dart';
import '../../data/repositories/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _repository;

  HomeController(this._repository);

  // ── Loading / Error ──────────────────────────────────────────────────────
  final isLoading = false.obs;
  final error = Rxn<Object>();

  // ── App bar collapse state ────────────────────────────────────────────────
  final isAppBarCollapsed = false.obs;

  // ── User ─────────────────────────────────────────────────────────────────
  final userInitial = 'H'.obs;

  // ── Thông tin nhà hàng ───────────────────────────────────────────────────
  final restaurantInfo = Rxn<RestaurantInfo>();

  // ── Promo banner ─────────────────────────────────────────────────────────
  final promoBanner = Rxn<HomePromoBannerItem>();

  // ── Danh mục ─────────────────────────────────────────────────────────────
  final categories = <CategoryItem>[].obs;
  final selectedCategorySlug = 'all'.obs;

  // ── Món ăn ───────────────────────────────────────────────────────────────
  final _allFoodItems = <FoodItemModel>[];
  final filteredFoodItems = <FoodItemModel>[].obs;
  final isFilteredEmpty = true.obs;
  final filteredCount = 0.obs;

  // ── Giỏ hàng ─────────────────────────────────────────────────────────────
  CartController get _cartController => Get.find<CartController>();

  // ── Thông báo (badge đếm) ─────────────────────────────────────────────────
  NotificationController get _notificationController =>
      Get.find<NotificationController>();

  RxInt get unreadNotificationCount => _notificationController.unreadCount;

  @override
  void onInit() {
    super.onInit();
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

  // ── Private ──────────────────────────────────────────────────────────────

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
    _syncFilteredMeta();
  }

  void _syncFilteredMeta() {
    isFilteredEmpty.value = filteredFoodItems.isEmpty;
    filteredCount.value = filteredFoodItems.length;
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      error.value = null;

      restaurantInfo.value = await _repository.fetchRestaurantInfo();
      promoBanner.value = await _repository.fetchPromoBanner();
      categories.assignAll(await _repository.fetchCategories());
      _allFoodItems
        ..clear()
        ..addAll(await _repository.fetchFoodItems());
      filteredFoodItems.assignAll(_allFoodItems);
      _syncFilteredMeta();
    } catch (e) {
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }
}
