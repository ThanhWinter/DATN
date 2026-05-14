import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:core_network/core_network.dart';
import 'package:core_ui/core_ui.dart';
import 'package:core_utils/core_utils.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../data/models/category_model.dart';
import '../../data/models/food_model.dart';
import '../../data/models/option_group_model.dart';
import '../../data/repositories/menu_repository.dart';

class MenuController extends GetxController with AutoRefreshMixin {
  MenuController(this._repository);

  final MenuRepository _repository;

  final isLoading = true.obs;
  final error = Rxn<String>();
  final categories = <CategoryModel>[].obs;
  final foods = <FoodModel>[].obs;
  final selectedCategoryId = Rxn<int>();
  final isMutating = false.obs;
  final searchQuery = ''.obs;
  final activeMenuTab = 0.obs; // 0 = categories, 1 = foods

  final totalFoodCount = 0.obs;
  final availableFoodCount = 0.obs;
  final unavailableFoodCount = 0.obs;

  // ── Client-side cache (toàn bộ món từ API) + phân trang ảo UI ─────────────
  final List<FoodModel> _foodsMaster = [];

  List<FoodModel> _filteredView = [];
  int _visibleCount = 0;
  static const int _uiChunk = 20;

  Timer? _loadMoreDebounce;

  @override
  void onInit() {
    super.onInit();
    debounce(
      searchQuery,
      (_) => _applyFilters(resetWindow: true),
      time: const Duration(milliseconds: 300),
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      loadData();
      startPolling(const Duration(seconds: 60), _silentRefresh);
    });
  }

  Future<void> _silentRefresh() async {
    try {
      final results = await Future.wait([
        _repository.fetchCategories(),
        _repository.fetchFoods(),
      ]);
      categories.value = results[0] as List<CategoryModel>;
      _foodsMaster
        ..clear()
        ..addAll(results[1] as List<FoodModel>);
      _syncStatsFromMaster();
      _applyFilters(resetWindow: false);
    } catch (e) {
      dev.log('[MENU/VM] ⚠️ silentRefresh error (ignored): $e');
    }
  }

  Future<void> loadData() async {
    dev.log('[MENU/VM] Loading menu (full list + client UI window)...');
    isLoading.value = true;
    error.value = null;
    try {
      final results = await Future.wait([
        _repository.fetchCategories(),
        _repository.fetchFoods(),
      ]);
      categories.value = results[0] as List<CategoryModel>;
      _foodsMaster
        ..clear()
        ..addAll(results[1] as List<FoodModel>);
      _syncStatsFromMaster();
      _applyFilters(resetWindow: true);
      dev.log(
          '[MENU/VM] ✅ ${categories.length} categories, master=${_foodsMaster.length} foods, UI=${foods.length}');
    } catch (e) {
      dev.log('[MENU/VM] ❌ loadData error: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _syncStatsFromMaster() {
    totalFoodCount.value = _foodsMaster.length;
    availableFoodCount.value = _foodsMaster.where((f) => f.isAvailable).length;
    unavailableFoodCount.value =
        _foodsMaster.where((f) => !f.isAvailable).length;
  }

  List<FoodModel> _computeFiltered() {
    final id = selectedCategoryId.value;
    final q = searchQuery.value;
    var list = id == null
        ? List<FoodModel>.from(_foodsMaster)
        : _foodsMaster.where((f) => f.categoryId == id).toList();
    if (q.isNotEmpty) {
      list = list.where((f) => f.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  void _applyFilters({required bool resetWindow}) {
    _filteredView = _computeFiltered();
    if (resetWindow) {
      _visibleCount = math.min(_uiChunk, math.max(_filteredView.length, 0));
    } else {
      _visibleCount = math.min(_visibleCount, _filteredView.length);
    }
    _applyUiSlice();
  }

  void _applyUiSlice() {
    final end = math.min(_visibleCount, _filteredView.length);
    if (end <= 0) {
      foods.clear();
    } else {
      foods.assignAll(_filteredView.sublist(0, end));
    }
  }

  bool get hasMoreUi => _visibleCount < _filteredView.length;

  void selectCategory(int? id) {
    selectedCategoryId.value = id;
    _applyFilters(resetWindow: true);
  }

  void showCategoriesTab() => activeMenuTab.value = 0;

  void showFoodsTab() => activeMenuTab.value = 1;

  void openFoodsForCategory(int id) {
    selectedCategoryId.value = id;
    activeMenuTab.value = 1;
    _applyFilters(resetWindow: true);
  }

  bool get isFiltered =>
      selectedCategoryId.value != null || searchQuery.value.isNotEmpty;

  void clearFilters() {
    selectedCategoryId.value = null;
    searchQuery.value = '';
    _applyFilters(resetWindow: true);
  }

  void updateSearch(String q) {
    searchQuery.value = q.trim().toLowerCase();
  }

  void maybeLoadMoreVisibleFoods() {
    if (activeMenuTab.value != 1) return;
    _loadMoreDebounce?.cancel();
    _loadMoreDebounce = Timer(const Duration(milliseconds: 200), loadMoreFoods);
  }

  void loadMoreFoods() {
    if (!hasMoreUi) return;
    _visibleCount = math.min(
      _visibleCount + _uiChunk,
      _filteredView.length,
    );
    _applyUiSlice();
  }

  @override
  void onClose() {
    _loadMoreDebounce?.cancel();
    _foodsMaster.clear();
    super.onClose();
  }

  List<FoodModel> get visibleFoodsForList => foods.toList();

  int categoryFoodCount(int categoryId) =>
      _foodsMaster.where((food) => food.categoryId == categoryId).length;

  int categoryAvailableFoodCount(int categoryId) => _foodsMaster
      .where((food) => food.categoryId == categoryId && food.isAvailable)
      .length;

  Future<CategoryModel> getCategoryDetail(int id) =>
      _repository.fetchCategoryById(id);

  Future<void> _refetchFoodsMaster() async {
    final list = await _repository.fetchFoods();
    _foodsMaster
      ..clear()
      ..addAll(list);
    _syncStatsFromMaster();
    _applyFilters(resetWindow: true);
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

  Future<void> updateCategory(
    int id, {
    required String name,
    String? description,
    List<int>? imageBytes,
    String? imageFilename,
  }) async {
    dev.log('[MENU/VM] Updating category id=$id: $name');
    isMutating.value = true;
    try {
      final updated = await _repository.updateCategory(
        id,
        name: name,
        description: description,
        imageBytes: imageBytes,
        imageFilename: imageFilename,
      );
      final idx = categories.indexWhere((c) => c.id == id);
      if (idx != -1) categories[idx] = updated;
      Get.snackbar(
        'Đã cập nhật',
        'Danh mục "${updated.name}" đã được cập nhật',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      dev.log('[MENU/VM] ✅ Category $id updated');
    } catch (e) {
      dev.log('[MENU/VM] ❌ updateCategory error: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật danh mục: $e',
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
      if (selectedCategoryId.value == id) {
        selectedCategoryId.value = null;
      }
      await _refetchFoodsMaster();
      Get.snackbar(
        'Đã xoá',
        'Danh mục đã được xoá',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      dev.log('[MENU/VM] ✅ Category $id deleted');
    } catch (e) {
      dev.log('[MENU/VM] ❌ deleteCategory error: $e');
      final msg = e is ApiException && e.statusCode == 409
          ? 'Danh mục này vẫn còn món ăn liên kết, vui lòng xoá hoặc chuyển danh mục cho các món ăn trước.'
          : 'Không thể xoá danh mục: $e';
      Get.snackbar('Không thể xoá', msg,
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
      _foodsMaster.insert(0, created);
      _syncStatsFromMaster();
      _applyFilters(resetWindow: true);
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
    final prevStatus = food.isAvailable;
    final newStatus = !prevStatus;
    dev.log('[MENU/VM] Toggling food id=${food.id}: $prevStatus → $newStatus');

    // Optimistic update — phản hồi tức thì cho Switch
    food.isAvailable = newStatus;
    final mi = _foodsMaster.indexWhere((f) => f.id == food.id);
    if (mi != -1) _foodsMaster[mi].isAvailable = newStatus;
    _syncStatsFromMaster();
    foods.refresh();

    try {
      await _repository.toggleFoodStatus(food.id, newStatus);
      dev.log('[MENU/VM] ✅ Food ${food.id} isAvailable=$newStatus');
    } catch (e) {
      // Revert on error — gạt Switch về vị trí cũ, tránh crash demo
      food.isAvailable = prevStatus;
      if (mi != -1) _foodsMaster[mi].isAvailable = prevStatus;
      _syncStatsFromMaster();
      foods.refresh();
      dev.log(
          '[MENU/VM] ❌ toggleAvailability error: $e — reverted to $prevStatus');
      Get.snackbar(
        'Không thể cập nhật',
        'Đã hoàn tác trạng thái. Vui lòng thử lại sau.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
      );
    }
  }

  Future<void> deleteFood(int id) async {
    dev.log('[MENU/VM] Deleting food id=$id');
    isMutating.value = true;
    try {
      await _repository.deleteFood(id);
      _foodsMaster.removeWhere((f) => f.id == id);
      _syncStatsFromMaster();
      _applyFilters(resetWindow: false);
      Get.snackbar('Đã xoá', 'Món ăn đã được xoá',
          backgroundColor: AppColors.emerald, colorText: AppColors.white);
      dev.log('[MENU/VM] ✅ Food $id deleted');
    } catch (e) {
      dev.log('[MENU/VM] ❌ deleteFood error: $e');
      Get.snackbar('Lỗi', 'Không thể xoá món ăn: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isMutating.value = false;
    }
  }

  // -------------------------------------------------------------------------
  // OPTION GROUPS
  // -------------------------------------------------------------------------

  final optionGroups = <OptionGroupModel>[].obs;
  final isOptionLoading = false.obs;
  final optionError = Rxn<String>();

  Future<void> loadOptionGroups(int foodId) async {
    dev.log('[MENU/VM] Loading option groups for food $foodId...');
    isOptionLoading.value = true;
    optionError.value = null;
    try {
      optionGroups.value = await _repository.fetchOptionGroups(foodId);
      dev.log('[MENU/VM] ✅ Loaded ${optionGroups.length} option groups');
    } catch (e) {
      dev.log('[MENU/VM] ❌ loadOptionGroups error: $e');
      optionError.value = e.toString();
    } finally {
      isOptionLoading.value = false;
    }
  }

  Future<void> createOptionGroup({
    required int foodId,
    required String name,
    required int minSelect,
    required int maxSelect,
    required List<Map<String, dynamic>> items,
  }) async {
    dev.log('[MENU/VM] Creating option group "$name"');
    isMutating.value = true;
    try {
      final created = await _repository.createOptionGroup(
        foodId: foodId,
        name: name,
        minSelect: minSelect,
        maxSelect: maxSelect,
        items: items,
      );
      optionGroups.add(created);
      Get.snackbar('Thành công', 'Đã thêm nhóm "${created.name}"',
          backgroundColor: AppColors.emerald, colorText: AppColors.white);
      dev.log('[MENU/VM] ✅ Option group created: id=${created.id}');
    } catch (e) {
      dev.log('[MENU/VM] ❌ createOptionGroup error: $e');
      Get.snackbar('Lỗi', 'Không thể thêm nhóm tuỳ chọn: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> updateOptionGroup({
    required int groupId,
    required int foodId,
    required String name,
    required int minSelect,
    required int maxSelect,
    required List<Map<String, dynamic>> items,
  }) async {
    dev.log('[MENU/VM] Updating option group $groupId');
    isMutating.value = true;
    try {
      final updated = await _repository.updateOptionGroup(
        groupId: groupId,
        foodId: foodId,
        name: name,
        minSelect: minSelect,
        maxSelect: maxSelect,
        items: items,
      );
      final idx = optionGroups.indexWhere((g) => g.id == groupId);
      if (idx != -1) optionGroups[idx] = updated;
      Get.snackbar('Đã cập nhật', 'Nhóm "${updated.name}" đã được cập nhật',
          backgroundColor: AppColors.emerald, colorText: AppColors.white);
      dev.log('[MENU/VM] ✅ Option group $groupId updated');
    } catch (e) {
      dev.log('[MENU/VM] ❌ updateOptionGroup error: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật nhóm tuỳ chọn: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> deleteOptionGroup(int groupId) async {
    dev.log('[MENU/VM] Deleting option group $groupId');
    isMutating.value = true;
    try {
      await _repository.deleteOptionGroup(groupId);
      optionGroups.removeWhere((g) => g.id == groupId);
      Get.snackbar('Đã xoá', 'Nhóm tuỳ chọn đã được xoá',
          backgroundColor: AppColors.emerald, colorText: AppColors.white);
      dev.log('[MENU/VM] ✅ Option group $groupId deleted');
    } catch (e) {
      dev.log('[MENU/VM] ❌ deleteOptionGroup error: $e');
      Get.snackbar('Lỗi', 'Không thể xoá nhóm tuỳ chọn: $e',
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
    List<int>? imageBytes,
    String? imageFilename,
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
        imageBytes: imageBytes,
        imageFilename: imageFilename,
      );
      final mi = _foodsMaster.indexWhere((f) => f.id == id);
      if (mi != -1) _foodsMaster[mi] = updated;
      _syncStatsFromMaster();
      _applyFilters(resetWindow: false);
      Get.snackbar('Đã cập nhật', 'Thông tin món ăn đã được cập nhật',
          backgroundColor: AppColors.emerald, colorText: AppColors.white);
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
