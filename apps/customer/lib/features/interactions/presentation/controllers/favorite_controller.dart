import 'dart:developer' as dev;

import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../data/models/interaction_models.dart';
import '../../data/repositories/interaction_repository.dart';

class FavoriteController extends GetxController {
  final InteractionRepository _repository;

  FavoriteController(this._repository);

  final favorites = <FavoriteItemModel>[].obs;
  final isLoading = false.obs;
  final error = Rxn<Object>();
  final isEmpty = true.obs; // Rule #2 — explicit RxBool

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      error.value = null;
      final items = await _repository.getMyFavorites();
      favorites.assignAll(items);
      isEmpty.value = items.isEmpty;
    } catch (e) {
      dev.log('[FAVORITE] ❌ loadFavorites error: $e');
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFavorite(int foodId) async {
    try {
      await _repository.toggleFavorite(foodId);
      favorites.removeWhere((f) => f.foodId == foodId);
      isEmpty.value = favorites.isEmpty;
    } catch (e) {
      dev.log('[FAVORITE] ❌ removeFavorite error: $e');
    }
  }

  void navigateToFoodDetail(int foodId) {
    Get.toNamed(AppRoutes.foodDetail, arguments: foodId);
  }
}
