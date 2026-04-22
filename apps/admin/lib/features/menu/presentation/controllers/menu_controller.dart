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
  // TODO: mock data
  final filteredFoods = <FoodModel>[].obs;
  final selectedCategoryId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
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
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(int? id) {
    selectedCategoryId.value = id;
    _applyFilter();
  }

  void _applyFilter() {
    final id = selectedCategoryId.value;
    filteredFoods.value = id == null
        ? List.of(foods)
        : foods.where((f) => f.categoryId == id).toList();
  }

  void toggleAvailability(FoodModel food) {
    food.isAvailable = !food.isAvailable;
    foods.refresh();
    _applyFilter();
  }

  void addFood(FoodModel food) {
    foods.add(food);
    _applyFilter();
  }

  void addCategory(CategoryModel category) {
    categories.add(category);
  }

  void deleteCategory(int id) {
    categories.removeWhere((c) => c.id == id);
    if (selectedCategoryId.value == id) selectCategory(null);
  }
}
