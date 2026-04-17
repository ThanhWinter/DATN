import "package:get/get.dart";

import "../../../../app/routes/app_routes.dart";
import "../../../cart/data/models/cart_item_model.dart";
import "../../../cart/presentation/controllers/cart_controller.dart";
import "../../../notifications/presentation/controllers/notification_controller.dart";
import "../../data/models/home_items.dart";

class HomeController extends GetxController {
  // ── Loading / Error ──────────────────────────────────────────────────────
  final isLoading = false.obs;
  final error = Rxn<Object>();

  // ── Tab ──────────────────────────────────────────────────────────────────
  final selectedTabIndex = 0.obs;

  // ── App bar collapse state (dùng để ẩn/hiện title khi scroll) ────────────
  final isAppBarCollapsed = false.obs;

  // ── User ─────────────────────────────────────────────────────────────────
  final userInitial = "H".obs;

  // ── Thông tin nhà hàng ───────────────────────────────────────────────────
  final restaurantInfo = Rxn<RestaurantInfo>();

  // ── Promo banner ─────────────────────────────────────────────────────────
  final promoBanner = Rxn<HomePromoBannerItem>();

  // ── Danh mục ─────────────────────────────────────────────────────────────
  final categories = <CategoryItem>[].obs;
  final selectedCategorySlug = "all".obs;

  // ── Món ăn ───────────────────────────────────────────────────────────────
  final _allFoodItems = <FoodItemModel>[];
  final filteredFoodItems = <FoodItemModel>[].obs;

  // ── Giỏ hàng (badge đếm) ─────────────────────────────────────────────────
  CartController get _cartController {
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController(), permanent: true);
    }
    return Get.find<CartController>();
  }

  int get cartItemCount =>
      _cartController.cartItems.fold(0, (sum, item) => sum + item.quantity);

  // ── Thông báo (badge đếm) ────────────────────────────────────────────────
  NotificationController get _notificationController {
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController(), permanent: true);
    }
    return Get.find<NotificationController>();
  }

  int get unreadNotificationCount => _notificationController.unreadCount.value;
  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void onTabChanged(int index) {
    if (index == 1) {
      Get.toNamed(AppRoutes.cart);
    } else if (index == 2) {
      Get.toNamed(AppRoutes.orders);
    } else {
      selectedTabIndex.value = index;
    }
  }

  void selectCategory(String slug) {
    selectedCategorySlug.value = slug;
    _applyFilter();
  }

  void addToCart(FoodItemModel item) {
    // Đẩy dữ liệu từ Home sang Cart model
    _cartController.addItem(
      CartItemModel(
        id: item.id.toString(),
        name: item.name,
        price: item.priceVnd.toDouble(),
        quantity: 1,
        imageUrl: item.imageUrl,
      ),
    );

    Get.snackbar(
      "Đã thêm vào giỏ",
      item.name,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }

  // ── Private ──────────────────────────────────────────────────────────────

  void _applyFilter() {
    if (selectedCategorySlug.value == "all") {
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

      // TODO: mock data — thay bằng API thật khi backend sẵn sàng
      await Future.delayed(const Duration(milliseconds: 400));

      // TODO: mock data
      restaurantInfo.value = const RestaurantInfo(
        name: "FoodHit Kitchen",
        rating: 4.8,
        reviewCount: 1340,
        deliveryTime: "20-30 phút",
        coverImageUrl:
            "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=80",
        description: "Ẩm thực Việt Nam truyền thống — Giao hàng nhanh tận nơi",
      );

      // TODO: mock data
      promoBanner.value = const HomePromoBannerItem(
        title: "Miễn phí giao hàng hôm nay",
        subtitle: "Áp dụng cho đơn từ 99K. Không cần mã giảm giá.",
        imageUrl:
            "https://images.unsplash.com/photo-1556740749-887f6717d7e4?auto=format&fit=crop&w=1200&q=60",
      );

      // TODO: mock data
      categories.assignAll([
        const CategoryItem(name: "Tất cả", slug: "all"),
        const CategoryItem(name: "Cơm", slug: "com"),
        const CategoryItem(name: "Bún & Phở", slug: "bun"),
        const CategoryItem(name: "Đồ uống", slug: "drink"),
        const CategoryItem(name: "Tráng miệng", slug: "dessert"),
      ]);

      // TODO: mock data
      _allFoodItems
        ..clear()
        ..addAll([
          // ─── Cơm ────────────────────────────────────────────────────────
          const FoodItemModel(
            id: 1,
            name: "Cơm sườn nướng",
            description: "Sườn nướng mật ong, cơm trắng dẻo",
            priceVnd: 65000,
            categorySlug: "com",
            imageUrl:
                "https://images.unsplash.com/photo-1628294895950-9805252327bc?auto=format&fit=crop&w=600&q=60",
          ),
          const FoodItemModel(
            id: 2,
            name: "Cơm gà xối mỡ",
            description: "Gà da giòn, cơm thơm, nước mắm ớt",
            priceVnd: 60000,
            categorySlug: "com",
            imageUrl:
                "https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?auto=format&fit=crop&w=600&q=60",
          ),
          const FoodItemModel(
            id: 3,
            name: "Cơm chiên Dương Châu",
            description: "Cơm chiên trứng, tôm, lạp xưởng",
            priceVnd: 55000,
            categorySlug: "com",
          ),
          const FoodItemModel(
            id: 4,
            name: "Cơm tấm đặc biệt",
            description: "Sườn bì chả, trứng ốp la",
            priceVnd: 70000,
            categorySlug: "com",
            imageUrl:
                "https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=600&q=60",
          ),

          // ─── Bún & Phở ──────────────────────────────────────────────────
          const FoodItemModel(
            id: 5,
            name: "Phở bò tái nạm",
            description: "Phở tươi, thịt bò tái, nạm mềm",
            priceVnd: 65000,
            categorySlug: "bun",
            imageUrl:
                "https://images.unsplash.com/photo-1617093727343-374698b1b08d?auto=format&fit=crop&w=600&q=60",
          ),
          const FoodItemModel(
            id: 6,
            name: "Bún bò Huế",
            description: "Bún bò chuẩn vị Huế, chả cua, mắm ruốc",
            priceVnd: 60000,
            categorySlug: "bun",
          ),
          const FoodItemModel(
            id: 7,
            name: "Bún chả Hà Nội",
            description: "Chả nướng than hoa, bún tươi, nem cuốn",
            priceVnd: 65000,
            categorySlug: "bun",
            imageUrl:
                "https://images.unsplash.com/photo-1617196034796-73c7fba0bdc0?auto=format&fit=crop&w=600&q=60",
          ),
          const FoodItemModel(
            id: 8,
            name: "Mì Quảng",
            description: "Mì vàng, tôm thịt, rau sống, bánh tráng",
            priceVnd: 55000,
            categorySlug: "bun",
          ),
          const FoodItemModel(
            id: 9,
            name: "Bún riêu cua",
            description: "Riêu cua đồng, đậu phụ chiên, cà chua",
            priceVnd: 55000,
            categorySlug: "bun",
            imageUrl:
                "https://images.unsplash.com/photo-1604909052743-94e838986d24?auto=format&fit=crop&w=600&q=60",
          ),

          // ─── Đồ uống ────────────────────────────────────────────────────
          const FoodItemModel(
            id: 10,
            name: "Trà đào cam sả",
            description: "Trà tươi, đào mật, cam tươi, sả",
            priceVnd: 35000,
            categorySlug: "drink",
          ),
          const FoodItemModel(
            id: 11,
            name: "Cà phê sữa đá",
            description: "Phin Việt Nam truyền thống",
            priceVnd: 25000,
            categorySlug: "drink",
          ),
          const FoodItemModel(
            id: 12,
            name: "Nước ép cam tươi",
            description: "100% cam vắt tươi, không đường",
            priceVnd: 30000,
            categorySlug: "drink",
          ),
          const FoodItemModel(
            id: 13,
            name: "Sinh tố bơ sữa",
            description: "Bơ Đắk Lắk, sữa đặc, đá xay",
            priceVnd: 40000,
            categorySlug: "drink",
          ),

          // ─── Tráng miệng ─────────────────────────────────────────────────
          const FoodItemModel(
            id: 14,
            name: "Chè thái",
            description: "Thạch, trân châu, nước cốt dừa, đá bào",
            priceVnd: 30000,
            categorySlug: "dessert",
          ),
          const FoodItemModel(
            id: 15,
            name: "Bánh flan caramel",
            description: "Flan mềm mịn, caramel đắng nhẹ",
            priceVnd: 25000,
            categorySlug: "dessert",
          ),
          const FoodItemModel(
            id: 16,
            name: "Kem tươi matcha",
            description: "Matcha Nhật, kem tươi Hokkaido",
            priceVnd: 45000,
            categorySlug: "dessert",
            isAvailable: false,
          ),
        ]);

      filteredFoodItems.assignAll(_allFoodItems);
    } catch (e) {
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }
}
