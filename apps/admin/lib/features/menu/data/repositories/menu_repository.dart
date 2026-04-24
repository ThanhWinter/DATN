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
    dev.log('[MENU/REPO] ⚠️ fetchFoods() đang dùng mock data để demo giao diện Hết hàng.');
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      FoodModel(
        id: 1,
        name: 'Cơm Sườn Nướng Muối Ớt',
        price: 65000,
        categoryId: 1,
        categoryName: 'Cơm tấm',
        description: 'Sườn nướng thơm nồng vị muối ớt, ăn kèm đồ chua.',
        imageUrl: 'https://statics.vinpearl.com/com-tam-sai-gon-1_1620102143.JPG',
        isAvailable: true,
      ),
      FoodModel(
        id: 2,
        name: 'Phở Bò Tái Nạm',
        price: 75000,
        categoryId: 2,
        categoryName: 'Phở',
        description: 'Nước dùng đậm đà, thịt bò tươi ngon mỗi ngày.',
        imageUrl: 'https://i.ytimg.com/vi/6S9H-4-M-bU/maxresdefault.jpg',
        isAvailable: false, // Demo trạng thái HẾT HÀNG
      ),
      FoodModel(
        id: 3,
        name: 'Trà Đào Cam Sả',
        price: 35000,
        categoryId: 3,
        categoryName: 'Đồ uống',
        description: 'Giải nhiệt cực đã với hương đào và sả tươi.',
        imageUrl: 'https://dayphache.edu.vn/wp-content/uploads/2018/06/tra-dao-cam-sa.jpg',
        isAvailable: true,
      ),
    ];
  }

  Future<FoodModel> createFood({
    required String name,
    required double price,
    required int categoryId,
    String? description,
    List<int>? imageBytes,
    String? imageFilename,
  }) async {
    dev.log('[MENU/REPO] Creating food: $name | price=$price | categoryId=$categoryId');
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
    dev.log('[MENU/REPO] Toggling food status: id=$id to isAvailable=$isAvailable');
    await _apiClient.patch(
      '/foods/$id/status',
      query: {'isAvailable': isAvailable.toString()},
    );
    dev.log('[MENU/REPO] ✅ Food $id status updated to $isAvailable');
  }
}
