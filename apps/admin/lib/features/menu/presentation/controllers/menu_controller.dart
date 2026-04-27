import 'dart:developer' as dev;

import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../data/models/category_model.dart';
import '../../data/models/food_model.dart';
import '../../data/repositories/menu_repository.dart';

class MenuController extends GetxController {
  MenuController(this._repository);

  final MenuRepository _repository;

  final isLoading = true.obs;
  final error = Rxn<String>();
  final categories = <CategoryModel>[].obs;
  final foods = <FoodModel>[].obs;
  final filteredFoods = <FoodModel>[].obs;
  final selectedCategoryId = Rxn<int>();
  final isMutating = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Chỉ debounce search — selectCategory và mutation vẫn gọi _applyFilter() trực tiếp
    debounce(
      searchQuery,
      (_) => _applyFilter(),
      time: const Duration(milliseconds: 400),
    );
    loadData();
  }

  Future<void> loadData() async {
    dev.log('[MENU/VM] Loading menu data...');
    isLoading.value = true;
    error.value = null;
    try {
      final results = await Future.wait([
        _repository.fetchCategories(),
        _repository.fetchFoods(),
      ]);
      categories.value = results[0] as List<CategoryModel>;
      foods.value = results[1] as List<FoodModel>;
      _applyFilter();
      dev.log(
          '[MENU/VM] ✅ Loaded ${categories.length} categories, ${foods.length} foods');
    } catch (e) {
      dev.log('[MENU/VM] ❌ loadData error: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(int? id) {
    selectedCategoryId.value = id;
    _applyFilter();
  }

  void updateSearch(String q) {
    searchQuery.value = q.trim().toLowerCase();
    // filter chạy sau 400ms qua debounce worker ở onInit
  }

  void _applyFilter() {
    final id = selectedCategoryId.value;
    final q = searchQuery.value;
    var result = id == null
        ? List.of(foods)
        : foods.where((f) => f.categoryId == id).toList();
    if (q.isNotEmpty) {
      result = result.where((f) => f.name.toLowerCase().contains(q)).toList();
    }
    filteredFoods.value = result;
  }

  // -------------------------------------------------------------------------
  // CATEGORY MUTATIONS
  // -------------------------------------------------------------------------

  Future<void> addCategory(
    String name, {
    String? description,
    List<int>? imageBytes,
    String? imageFilename,
  }) async {
    dev.log('[MENU/VM] Creating category: $name');
    isMutating.value = true;
    try {
      final created = await _repository.createCategory(
        name: name,
        description: description,
        imageBytes: imageBytes,
        imageFilename: imageFilename,
      );
      categories.add(created);
      Get.snackbar(
        'Thành công',
        'Đã thêm danh mục "${created.name}"',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      dev.log('[MENU/VM] ✅ Category added: id=${created.id}');
    } catch (e) {
      dev.log('[MENU/VM] ❌ addCategory error: $e');
      Get.snackbar('Lỗi', 'Không thể thêm danh mục: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> deleteCategory(int id) async {
    dev.log('[MENU/VM] Deleting category id=$id');
    isMutating.value = true;
    try {
      await _repository.deleteCategory(id);
      categories.removeWhere((c) => c.id == id);
      if (selectedCategoryId.value == id) selectCategory(null);
      _applyFilter();
      Get.snackbar(
        'Đã xoá',
        'Danh mục đã được xoá',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      dev.log('[MENU/VM] ✅ Category $id deleted');
    } catch (e) {
      dev.log('[MENU/VM] ❌ deleteCategory error: $e');
      Get.snackbar('Lỗi', 'Không thể xoá danh mục: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isMutating.value = false;
    }
  }

  // -------------------------------------------------------------------------
  // FOOD MUTATIONS
  // -------------------------------------------------------------------------

  Future<void> addFood(
    String name,
    double price,
    int categoryId, {
    String? description,
    List<int>? imageBytes,
    String? imageFilename,
  }) async {
    dev.log('[MENU/VM] Creating food: $name');
    isMutating.value = true;
    try {
      final created = await _repository.createFood(
        name: name,
        price: price,
        categoryId: categoryId,
        description: description,
        imageBytes: imageBytes,
        imageFilename: imageFilename,
      );
      foods.add(created);
      _applyFilter();
      Get.snackbar(
        'Thành công',
        'Đã thêm món "${created.name}"',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      dev.log('[MENU/VM] ✅ Food added: id=${created.id}');
    } catch (e) {
      dev.log('[MENU/VM] ❌ addFood error: $e');
      Get.snackbar('Lỗi', 'Không thể thêm món ăn: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> toggleAvailability(FoodModel food) async {
    final newStatus = !food.isAvailable;
    dev.log('[MENU/VM] Toggling food id=${food.id} to $newStatus');
    try {
      await _repository.toggleFoodStatus(food.id, newStatus);
      food.isAvailable = newStatus;
      foods.refresh();
      _applyFilter();
      dev.log('[MENU/VM] ✅ Food ${food.id} isAvailable=${food.isAvailable}');
    } catch (e) {
      dev.log('[MENU/VM] ❌ toggleAvailability error: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái món: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    }
  }

  Future<void> deleteFood(int id) async {
    dev.log('[MENU/VM] Deleting food id=$id');
    isMutating.value = true;
    try {
      await _repository.deleteFood(id);
      foods.removeWhere((f) => f.id == id);
      _applyFilter();
      Get.snackbar('Đã xoá', 'Món ăn đã được xoá',
          backgroundColor: AppColors.successGreen, colorText: AppColors.white);
      dev.log('[MENU/VM] ✅ Food $id deleted');
    } catch (e) {
      dev.log('[MENU/VM] ❌ deleteFood error: $e');
      Get.snackbar('Lỗi', 'Không thể xoá món ăn: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> updateFood(
    int id, {
    required String name,
    required double price,
    required int categoryId,
    String? description,
  }) async {
    dev.log('[MENU/VM] Updating food id=$id: $name');
    isMutating.value = true;
    try {
      final updated = await _repository.updateFood(
        id,
        name: name,
        price: price,
        categoryId: categoryId,
        description: description,
      );
      final idx = foods.indexWhere((f) => f.id == id);
      if (idx != -1) foods[idx] = updated;
      _applyFilter();
      Get.snackbar('Đã cập nhật', 'Thông tin món ăn đã được cập nhật',
          backgroundColor: AppColors.successGreen, colorText: AppColors.white);
      dev.log('[MENU/VM] ✅ Food $id updated');
    } catch (e) {
      dev.log('[MENU/VM] ❌ updateFood error: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật món ăn: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isMutating.value = false;
    }
  }
}
