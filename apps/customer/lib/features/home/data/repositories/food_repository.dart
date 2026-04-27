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
}
