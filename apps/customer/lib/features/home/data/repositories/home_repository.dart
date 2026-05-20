import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:isolate';

import 'package:core_network/core_network.dart';
import 'package:http/http.dart' as http;

import '../models/home_items.dart';

List<FoodItemModel> _parseFoodList(List<dynamic> raw) =>
    raw.map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>)).toList();

const _nominatimUserAgent = 'FoodHitCustomerApp/1.0 (contact@foodhit.vn)';

class HomeRepository {
  HomeRepository(this._apiClient);

  final IApiClient _apiClient;

  void clearCache() {
    final client = _apiClient;
    if (client is OptimizedApiClient) {
      client.clearCache();
    }
  }

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
    if (list.isEmpty) return [];
    return Isolate.run(() => _parseFoodList(list));
  }

  Future<List<FoodItemModel>> fetchFoodsByCategory(int categoryId) async {
    final response = await _apiClient.get('/foods/category/$categoryId');
    final list = response['result'] as List<dynamic>? ?? [];
    if (list.isEmpty) return [];
    return Isolate.run(() => _parseFoodList(list));
  }

  Future<String> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'json',
        'lat': lat.toStringAsFixed(7),
        'lon': lng.toStringAsFixed(7),
        'zoom': '18',
        'accept-language': 'vi',
      });
      final res = await http.get(uri, headers: {
        'User-Agent': _nominatimUserAgent
      }).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) {
        dev.log('[HOME] ⚠️ reverseGeocode HTTP ${res.statusCode}');
        return 'Không xác định được địa chỉ';
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['display_name']?.toString() ?? 'Không xác định được địa chỉ';
    } catch (e) {
      dev.log('[HOME] ⚠️ reverseGeocode error: $e');
      return 'Không xác định được địa chỉ';
    }
  }
}
