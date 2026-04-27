import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/home_items.dart';

class HomeRepository {
  HomeRepository(this._apiClient);

  final IApiClient _apiClient;

  final _nominatimClient = ApiClient(
    baseUrl: 'https://nominatim.openstreetmap.org',
    defaultHeaders: const {
      'Content-Type': 'application/json',
      'User-Agent': 'FoodHitCustomerApp/1.0 (contact@foodhit.vn)',
    },
  );

  Future<List<HomePromoBannerItem>> fetchPromoBanners() async {
    final response = await _apiClient.get('/settings/banners');
    final list = response['result'] as List<dynamic>? ?? [];
    return list
        .map((e) => HomePromoBannerItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StoreSettingModel> fetchStoreSetting() async {
    final response = await _apiClient.get('/settings/store');
    return StoreSettingModel.fromJson(
        response['result'] as Map<String, dynamic>);
  }

  Future<List<CategoryItem>> fetchCategories() async {
    final response = await _apiClient.get('/categories');
    final list = response['result'] as List<dynamic>? ?? [];
    return list
        .map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<FoodItemModel>> fetchFoodItems() async {
    final response = await _apiClient.get('/foods');
    final list = response['result'] as List<dynamic>? ?? [];
    return list
        .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<FoodItemModel>> fetchFoodsByCategory(int categoryId) async {
    final response = await _apiClient.get('/foods/category/$categoryId');
    final list = response['result'] as List<dynamic>? ?? [];
    return list
        .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> reverseGeocode(double lat, double lng) async {
    try {
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
    } catch (e) {
      dev.log('[HOME] ⚠️ reverseGeocode error: $e');
      return 'Không xác định được địa chỉ';
    }
  }
}
