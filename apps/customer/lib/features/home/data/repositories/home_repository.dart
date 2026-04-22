import 'package:core_network/core_network.dart';

import '../models/home_items.dart';

class HomeRepository {
  // ApiClient xử lý Isolate.run() tại tầng network — không parse JSON ở đây
  final _nominatimClient = ApiClient(
    baseUrl: 'https://nominatim.openstreetmap.org',
    defaultHeaders: const {
      'Content-Type': 'application/json',
      'User-Agent': 'FoodHitCustomerApp/1.0 (contact@foodhit.vn)',
    },
  );

  Future<List<HomePromoBannerItem>> fetchPromoBanners() async {
    // TODO: mock data
    return const [
      HomePromoBannerItem(
        title: 'Mua 1 Tặng 1',
        subtitle: 'Áp dụng cuối tuần này',
        badgeText: 'Ưu đãi',
        imageUrl:
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=70',
      ),
      HomePromoBannerItem(
        title: 'Miễn phí giao hàng',
        subtitle: 'Đơn từ 99K',
        badgeText: 'Hôm nay',
        imageUrl:
            'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=70',
      ),
      HomePromoBannerItem(
        title: 'Combo tiết kiệm',
        subtitle: 'Giảm đến 30%',
        badgeText: 'Hot',
        imageUrl:
            'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?auto=format&fit=crop&w=800&q=70',
      ),
    ];
  }

  Future<List<CategoryItem>> fetchCategories() async {
    // TODO: mock data
    return const [
      CategoryItem(
        name: 'Bún/Phở\nMỳ/Cháo',
        slug: 'bun',
        imageUrl:
            'https://images.unsplash.com/photo-1617196034796-73c7fba0bdc0?auto=format&fit=crop&w=200&q=70',
      ),
      CategoryItem(
        name: 'Cơm/Cơm\ntấm',
        slug: 'com',
        imageUrl:
            'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=200&q=70',
      ),
      CategoryItem(
        name: 'Thức ăn\nnhanh',
        slug: 'fastfood',
        imageUrl:
            'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=200&q=70',
      ),
      CategoryItem(
        name: 'Món truyền\nthống/Đặc',
        slug: 'traditional',
        imageUrl:
            'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?auto=format&fit=crop&w=200&q=70',
      ),
      CategoryItem(
        name: 'Trà sữa\n& Cafe',
        slug: 'drink',
        imageUrl:
            'https://images.unsplash.com/photo-1558857563-b371033873b8?auto=format&fit=crop&w=200&q=70',
      ),
      CategoryItem(
        name: 'Tráng\nmiệng',
        slug: 'dessert',
        imageUrl:
            'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=200&q=70',
      ),
    ];
  }

  Future<List<FoodItemModel>> fetchFoodItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: mock data
    return const [
      FoodItemModel(
        id: 1,
        name: 'Cơm sườn nướng',
        description: 'Sườn nướng mật ong, cơm trắng dẻo',
        priceVnd: 65000,
        categorySlug: 'com',
        isPopular: true,
        imageUrl:
            'https://images.unsplash.com/photo-1628294895950-9805252327bc?auto=format&fit=crop&w=600&q=60',
      ),
      FoodItemModel(
        id: 2,
        name: 'Cơm gà xối mỡ',
        description: 'Gà da giòn, cơm thơm, nước mắm ớt',
        priceVnd: 60000,
        categorySlug: 'com',
        isPopular: true,
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
        isPopular: true,
        imageUrl:
            'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=600&q=60',
      ),
      FoodItemModel(
        id: 5,
        name: 'Phở bò tái nạm',
        description: 'Phở tươi, thịt bò tái, nạm mềm',
        priceVnd: 65000,
        categorySlug: 'bun',
        isPopular: true,
        imageUrl:
            'https://images.unsplash.com/photo-1617196034796-73c7fba0bdc0?auto=format&fit=crop&w=600&q=60',
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
        isPopular: true,
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
        id: 10,
        name: 'Trà đào cam sả',
        description: 'Trà tươi, đào mật, cam tươi, sả',
        priceVnd: 35000,
        categorySlug: 'drink',
        isPopular: true,
      ),
      FoodItemModel(
        id: 11,
        name: 'Cà phê sữa đá',
        description: 'Phin Việt Nam truyền thống',
        priceVnd: 25000,
        categorySlug: 'drink',
      ),
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
        isPopular: true,
      ),
    ];
  }

  Future<String> reverseGeocode(double lat, double lng) async {
    try {
      // Isolate.run() đã nằm trong ApiClient._handleResponse — không dùng lại ở đây
      final data = await _nominatimClient.get(
        '/reverse',
        query: {
          'format': 'json',
          'lat': lat.toStringAsFixed(7),
          'lon': lng.toStringAsFixed(7),
          'zoom': '18',
          'accept-language': 'vi',
        },
      );
      return data['display_name']?.toString() ?? 'Không xác định được địa chỉ';
    } catch (_) {
      return 'Không xác định được địa chỉ';
    }
  }
}
