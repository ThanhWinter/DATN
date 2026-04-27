import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/category_model.dart';
import '../models/food_model.dart';

class MenuRepository {
  MenuRepository(this._apiClient);

  final IApiClient _apiClient;

  // -------------------------------------------------------------------------
  // CATEGORIES
  // -------------------------------------------------------------------------

  Future<List<CategoryModel>> fetchCategories() async {
    dev.log('[MENU/REPO] Fetching categories...');
    final res = await _apiClient.get('/categories');
    final list = res['result'] as List<dynamic>;
    dev.log('[MENU/REPO] ✅ Got ${list.length} categories');
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    List<int>? imageBytes,
    String? imageFilename,
  }) async {
    dev.log('[MENU/REPO] Creating category: $name');
    final res = await _apiClient.multipartPost(
      '/categories',
      fields: {
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
      files: imageBytes != null
          ? [
              (
                field: 'file',
                bytes: imageBytes,
                filename: imageFilename ?? 'category.jpg',
                contentType: 'image/jpeg',
              )
            ]
          : null,
    );
    final created =
        CategoryModel.fromJson(res['result'] as Map<String, dynamic>);
    dev.log('[MENU/REPO] ✅ Category created: id=${created.id}');
    return created;
  }

  Future<void> deleteCategory(int id) async {
    dev.log('[MENU/REPO] Deleting category id=$id');
    await _apiClient.delete('/categories/$id');
    dev.log('[MENU/REPO] ✅ Category $id deleted');
  }

  // -------------------------------------------------------------------------
  // FOODS
  // -------------------------------------------------------------------------

  Future<List<FoodModel>> fetchFoods() async {
    dev.log('[MENU/REPO] Fetching foods from backend...');
    final res = await _apiClient.get('/foods');
    final list = res['result'] as List<dynamic>;
    dev.log('[MENU/REPO] ✅ Got ${list.length} foods');
    return list
        .map((e) => FoodModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FoodModel> createFood({
    required String name,
    required double price,
    required int categoryId,
    String? description,
    List<int>? imageBytes,
    String? imageFilename,
  }) async {
    dev.log(
        '[MENU/REPO] Creating food: $name | price=$price | categoryId=$categoryId');
    final res = await _apiClient.multipartPost(
      '/foods',
      fields: {
        'name': name,
        'price': price.toString(),
        'categoryId': categoryId.toString(),
        if (description != null && description.isNotEmpty)
          'description': description,
      },
      files: imageBytes != null
          ? [
              (
                field: 'file',
                bytes: imageBytes,
                filename: imageFilename ?? 'food.jpg',
                contentType: 'image/jpeg',
              )
            ]
          : null,
    );
    final created = FoodModel.fromJson(res['result'] as Map<String, dynamic>);
    dev.log('[MENU/REPO] ✅ Food created: id=${created.id}');
    return created;
  }

  Future<void> toggleFoodStatus(int id, bool isAvailable) async {
    dev.log(
        '[MENU/REPO] Toggling food status: id=$id to isAvailable=$isAvailable');
    await _apiClient.patch(
      '/foods/$id/status',
      query: {'isAvailable': isAvailable.toString()},
    );
    dev.log('[MENU/REPO] ✅ Food $id status updated to $isAvailable');
  }

  Future<void> deleteFood(int id) async {
    dev.log('[MENU/REPO] Deleting food id=$id');
    await _apiClient.delete('/foods/$id');
    dev.log('[MENU/REPO] ✅ Food $id deleted');
  }

  Future<FoodModel> updateFood(
    int id, {
    required String name,
    required double price,
    required int categoryId,
    String? description,
  }) async {
    dev.log('[MENU/REPO] Updating food id=$id: $name | price=$price');
    final res = await _apiClient.put(
      '/foods/$id',
      body: {
        'name': name,
        'price': price,
        'categoryId': categoryId,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    final updated = FoodModel.fromJson(res['result'] as Map<String, dynamic>);
    dev.log('[MENU/REPO] ✅ Food $id updated');
    return updated;
  }
}
