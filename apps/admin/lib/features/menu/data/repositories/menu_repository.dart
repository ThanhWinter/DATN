import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/category_model.dart';
import '../models/food_model.dart';
import '../models/option_group_model.dart';

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

  Future<CategoryModel> updateCategory(
    int id, {
    required String name,
    String? description,
    List<int>? imageBytes,
    String? imageFilename,
  }) async {
    dev.log(
        '[MENU/REPO] Updating category id=$id: $name | hasImage=${imageBytes != null}');
    final Map<String, dynamic> res;
    if (imageBytes != null) {
      res = await _apiClient.multipartPut(
        '/categories/$id',
        fields: {
          'name': name,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
        files: [
          (
            field: 'file',
            bytes: imageBytes,
            filename: imageFilename ?? 'category.jpg',
            contentType: 'image/jpeg',
          )
        ],
      );
    } else {
      res = await _apiClient.multipartPut(
        '/categories/$id',
        fields: {
          'name': name,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );
    }
    final updated =
        CategoryModel.fromJson(res['result'] as Map<String, dynamic>);
    dev.log('[MENU/REPO] ✅ Category $id updated');
    return updated;
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
    final res = await _apiClient.get('/foods/admin/all');
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
        'price': price == price.truncateToDouble()
            ? price.toInt().toString()
            : price.toString(),
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

  // -------------------------------------------------------------------------
  // OPTIONS
  // -------------------------------------------------------------------------

  Future<List<OptionGroupModel>> fetchOptionGroups(int foodId) async {
    dev.log('[MENU/REPO] Fetching option groups for food $foodId...');
    final res = await _apiClient.get('/options/admin/food/$foodId');
    final list = res['result'] as List<dynamic>? ?? [];
    dev.log('[MENU/REPO] ✅ Got ${list.length} option groups');
    return list
        .map((e) => OptionGroupModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OptionGroupModel> createOptionGroup({
    required int foodId,
    required String name,
    required int minSelect,
    required int maxSelect,
    required List<Map<String, dynamic>> items,
  }) async {
    dev.log('[MENU/REPO] Creating option group "$name" for food $foodId');
    final res = await _apiClient.post(
      '/options/food/$foodId',
      body: {
        'name': name,
        'minSelect': minSelect,
        'maxSelect': maxSelect,
        'foodId': foodId,
        'items': items,
      },
    );
    final created =
        OptionGroupModel.fromJson(res['result'] as Map<String, dynamic>);
    dev.log('[MENU/REPO] ✅ Option group created: id=${created.id}');
    return created;
  }

  Future<OptionGroupModel> updateOptionGroup({
    required int groupId,
    required int foodId,
    required String name,
    required int minSelect,
    required int maxSelect,
    required List<Map<String, dynamic>> items,
  }) async {
    dev.log('[MENU/REPO] Updating option group $groupId');
    final res = await _apiClient.put(
      '/options/groups/$groupId',
      body: {
        'name': name,
        'minSelect': minSelect,
        'maxSelect': maxSelect,
        'foodId': foodId,
        'items': items,
      },
    );
    final updated =
        OptionGroupModel.fromJson(res['result'] as Map<String, dynamic>);
    dev.log('[MENU/REPO] ✅ Option group updated: id=${updated.id}');
    return updated;
  }

  Future<void> deleteOptionGroup(int groupId) async {
    dev.log('[MENU/REPO] Deleting option group $groupId');
    await _apiClient.delete('/options/groups/$groupId');
    dev.log('[MENU/REPO] ✅ Option group $groupId deleted');
  }

  Future<FoodModel> updateFood(
    int id, {
    required String name,
    required double price,
    required int categoryId,
    String? description,
    List<int>? imageBytes,
    String? imageFilename,
  }) async {
    dev.log(
        '[MENU/REPO] Updating food id=$id: $name | price=$price | hasImage=${imageBytes != null}');

    final priceStr = price == price.truncateToDouble()
        ? price.toInt().toString()
        : price.toString();
    final Map<String, dynamic> res;
    if (imageBytes != null) {
      res = await _apiClient.multipartPut(
        '/foods/$id',
        fields: {
          'name': name,
          'price': priceStr,
          'categoryId': categoryId.toString(),
          if (description != null && description.isNotEmpty)
            'description': description,
        },
        files: [
          (
            field: 'file',
            bytes: imageBytes,
            filename: imageFilename ?? 'food.jpg',
            contentType: 'image/jpeg',
          )
        ],
      );
    } else {
      res = await _apiClient.multipartPut(
        '/foods/$id',
        fields: {
          'name': name,
          'price': priceStr,
          'categoryId': categoryId.toString(),
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );
    }

    final updated = FoodModel.fromJson(res['result'] as Map<String, dynamic>);
    dev.log('[MENU/REPO] ✅ Food $id updated');
    return updated;
  }
}
