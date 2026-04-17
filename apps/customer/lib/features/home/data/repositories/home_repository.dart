import '../models/home_items.dart';

class HomeRepository {
  Future<RestaurantInfo> fetchRestaurantInfo() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: mock data
    return const RestaurantInfo(
      name: 'FoodHit Kitchen',
      rating: 4.8,
      reviewCount: 1340,
      deliveryTime: '20-30 phút',
      coverImageUrl:
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=80',
      description: 'Ẩm thực Việt Nam truyền thống — Giao hàng nhanh tận nơi',
    );
  }

  Future<HomePromoBannerItem> fetchPromoBanner() async {
    // TODO: mock data
    return const HomePromoBannerItem(
      title: 'Miễn phí giao hàng hôm nay',
      subtitle: 'Áp dụng cho đơn từ 99K. Không cần mã giảm giá.',
      imageUrl:
          'https://images.unsplash.com/photo-1556740749-887f6717d7e4?auto=format&fit=crop&w=1200&q=60',
    );
  }

  Future<List<CategoryItem>> fetchCategories() async {
    // TODO: mock data
    return const [
      CategoryItem(name: 'Tất cả', slug: 'all'),
      CategoryItem(name: 'Cơm', slug: 'com'),
      CategoryItem(name: 'Bún', slug: 'bun'),
      CategoryItem(name: 'Đồ uống', slug: 'drink'),
      CategoryItem(name: 'Tráng miệng', slug: 'dessert'),
    ];
  }

  Future<List<FoodItemModel>> fetchFoodItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: mock data
    return const [
      // ─── Cơm ──────────────────────────────────────────────────────────────
      FoodItemModel(
        id: 1,
        name: 'Cơm sườn nướng',
        description: 'Sườn nướng mật ong, cơm trắng dẻo',
        priceVnd: 65000,
        categorySlug: 'com',
        imageUrl:
            'https://images.unsplash.com/photo-1628294895950-9805252327bc?auto=format&fit=crop&w=600&q=60',
      ),
      FoodItemModel(
        id: 2,
        name: 'Cơm gà xối mỡ',
        description: 'Gà da giòn, cơm thơm, nước mắm ớt',
        priceVnd: 60000,
        categorySlug: 'com',
        imageUrl:
            'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?auto=format&fit=crop&w=600&q=60',
      ),
      FoodItemModel(
        id: 3,
        name: 'Cơm chiên Dương Châu',
        description: 'Cơm chiên trứng, tôm, lạp xưởng',
        priceVnd: 55000,
        categorySlug: 'com',
      ),
      FoodItemModel(
        id: 4,
        name: 'Cơm tấm đặc biệt',
        description: 'Sườn bì chả, trứng ốp la',
        priceVnd: 70000,
        categorySlug: 'com',
        imageUrl:
            'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=600&q=60',
      ),

      // ─── Bún ──────────────────────────────────────────────────────────────
      FoodItemModel(
        id: 5,
        name: 'Phở bò tái nạm',
        description: 'Phở tươi, thịt bò tái, nạm mềm',
        priceVnd: 65000,
        categorySlug: 'bun',
        imageUrl:
            'https://images.unsplash.com/photo-1617093727343-374698b1b08d?auto=format&fit=crop&w=600&q=60',
      ),
      FoodItemModel(
        id: 6,
        name: 'Bún bò Huế',
        description: 'Bún bò chuẩn vị Huế, chả cua, mắm ruốc',
        priceVnd: 60000,
        categorySlug: 'bun',
      ),
      FoodItemModel(
        id: 7,
        name: 'Bún chả Hà Nội',
        description: 'Chả nướng than hoa, bún tươi, nem cuốn',
        priceVnd: 65000,
        categorySlug: 'bun',
        imageUrl:
            'https://images.unsplash.com/photo-1617196034796-73c7fba0bdc0?auto=format&fit=crop&w=600&q=60',
      ),
      FoodItemModel(
        id: 8,
        name: 'Mì Quảng',
        description: 'Mì vàng, tôm thịt, rau sống, bánh tráng',
        priceVnd: 55000,
        categorySlug: 'bun',
      ),
      FoodItemModel(
        id: 9,
        name: 'Bún riêu cua',
        description: 'Riêu cua đồng, đậu phụ chiên, cà chua',
        priceVnd: 55000,
        categorySlug: 'bun',
        imageUrl:
            'https://images.unsplash.com/photo-1604909052743-94e838986d24?auto=format&fit=crop&w=600&q=60',
      ),

      // ─── Đồ uống ──────────────────────────────────────────────────────────
      FoodItemModel(
        id: 10,
        name: 'Trà đào cam sả',
        description: 'Trà tươi, đào mật, cam tươi, sả',
        priceVnd: 35000,
        categorySlug: 'drink',
      ),
      FoodItemModel(
        id: 11,
        name: 'Cà phê sữa đá',
        description: 'Phin Việt Nam truyền thống',
        priceVnd: 25000,
        categorySlug: 'drink',
      ),
      FoodItemModel(
        id: 12,
        name: 'Nước ép cam tươi',
        description: '100% cam vắt tươi, không đường',
        priceVnd: 30000,
        categorySlug: 'drink',
      ),
      FoodItemModel(
        id: 13,
        name: 'Sinh tố bơ sữa',
        description: 'Bơ Đắk Lắk, sữa đặc, đá xay',
        priceVnd: 40000,
        categorySlug: 'drink',
      ),

      // ─── Tráng miệng ──────────────────────────────────────────────────────
      FoodItemModel(
        id: 14,
        name: 'Chè thái',
        description: 'Thạch, trân châu, nước cốt dừa, đá bào',
        priceVnd: 30000,
        categorySlug: 'dessert',
      ),
      FoodItemModel(
        id: 15,
        name: 'Bánh flan caramel',
        description: 'Flan mềm mịn, caramel đắng nhẹ',
        priceVnd: 25000,
        categorySlug: 'dessert',
      ),
      FoodItemModel(
        id: 16,
        name: 'Kem tươi matcha',
        description: 'Matcha Nhật, kem tươi Hokkaido',
        priceVnd: 45000,
        categorySlug: 'dessert',
        isAvailable: false,
      ),
    ];
  }
}
