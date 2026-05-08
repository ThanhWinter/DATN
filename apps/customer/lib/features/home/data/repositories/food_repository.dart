import 'package:core_network/core_network.dart';

import '../models/home_items.dart';

class FoodRepository {
  FoodRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<FoodItemModel> getFoodById(int id) async {
    final response = await _apiClient.get('/foods/$id');
    final result = response['result'] as Map<String, dynamic>;
    return FoodItemModel.fromJson(result);
  }

  Future<List<FoodItemModel>> getFoodsByCategory(int categoryId) async {
    final response = await _apiClient.get('/foods/category/$categoryId');
    final list = response['result'] as List<dynamic>? ?? [];
    return list
        .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
