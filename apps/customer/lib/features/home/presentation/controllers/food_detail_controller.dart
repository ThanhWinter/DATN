import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../data/models/food_option_model.dart';
import '../../data/models/home_items.dart';
import '../../data/repositories/food_repository.dart';
import '../../../interactions/data/models/interaction_models.dart';
import '../../../interactions/data/repositories/interaction_repository.dart';
import '../widgets/all_reviews_sheet.dart';

class FoodDetailController extends GetxController {
  final FoodRepository _repository;
  final InteractionRepository _interactionRepository;

  FoodDetailController(this._repository, this._interactionRepository);

  // ── State ────────────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final error = Rxn<Object>();
  final food = Rxn<FoodItemModel>();
  final quantity = 1.obs;
  final selectedOptions = <int, List<int>>{};
  final totalPrice = 0.0.obs;
  // Explicit RxBool — không dùng computed getter trong Obx (Rule #2)
  final canAddToCart = false.obs;
  final isFavorite = false.obs; // Rule #2 — explicit RxBool
  final rating = Rx<FoodRatingModel>(FoodRatingModel.empty);
  final reviews = <ReviewModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final foodId = Get.arguments as int?;
    if (foodId != null) _loadFood(foodId);
  }

  // ── Public ───────────────────────────────────────────────────────────────────

  void increaseQty() {
    quantity.value++;
    _recalc();
  }

  void decreaseQty() {
    if (quantity.value > 1) {
      quantity.value--;
      _recalc();
    }
  }

  void toggleOption(int groupId, int itemId, int maxSelect) {
    final current = List<int>.from(selectedOptions[groupId] ?? []);

    if (current.contains(itemId)) {
      current.remove(itemId);
    } else {
      if (maxSelect == 1) {
        current
          ..clear()
          ..add(itemId);
      } else if (current.length < maxSelect) {
        current.add(itemId);
      }
    }

    selectedOptions[groupId] = current;
    _recalc();
    update(['group_$groupId']);
  }

  bool isOptionSelected(int groupId, int itemId) {
    return selectedOptions[groupId]?.contains(itemId) ?? false;
  }

  void addToCart() {
    final f = food.value;
    if (f == null || !canAddToCart.value) return;

    final allSelected = <OptionItemModel>[];
    for (final group in f.optionGroups) {
      final ids = selectedOptions[group.id] ?? [];
      for (final id in ids) {
        final item = group.items.firstWhereOrNull((o) => o.id == id);
        if (item != null) allSelected.add(item);
      }
    }

    final optionExtra =
        allSelected.fold(0.0, (sum, o) => sum + o.priceAdjustment);

    final cartItem = CartItemModel(
      id: buildCartItemId(f.id, allSelected),
      foodId: f.id,
      name: f.name,
      price: f.price + optionExtra,
      quantity: quantity.value,
      imageUrl: f.imageUrl,
      selectedOptions: allSelected,
    );

    Get.find<CartController>().addItem(cartItem);
    dev.log('[FOOD_DETAIL] ✅ Added to cart: ${quantity.value}x ${f.name}');
  }

  Future<void> toggleFavorite() async {
    final f = food.value;
    if (f == null) return;
    try {
      await _interactionRepository.toggleFavorite(f.id);
      isFavorite.value = !isFavorite.value;
      dev.log('[FOOD_DETAIL] ✅ toggleFavorite: ${f.id} → ${isFavorite.value}');
    } catch (e) {
      dev.log('[FOOD_DETAIL] ❌ toggleFavorite error: $e');
    }
  }

  void viewAllReviews() {
    final f = food.value;
    if (f == null) return;
    Get.bottomSheet(
      AllReviewsSheet(foodId: f.id, foodName: f.name),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ── Private ──────────────────────────────────────────────────────────────────

  Future<void> _loadFood(int id) async {
    try {
      isLoading.value = true;
      error.value = null;
      rating.value = FoodRatingModel.empty;
      isFavorite.value = false;
      food.value = await _repository.getFoodById(id);
      if (isClosed) return;
      rating.value = food.value?.rating ?? FoodRatingModel.empty;
      reviews.value = food.value?.reviews ?? [];
      dev.log('[FOOD_DETAIL] ✅ Loaded food: id=$id');
      _recalc();
      isLoading.value = false;
      _loadSecondaryData(id);
    } catch (e) {
      dev.log('[FOOD_DETAIL] ❌ Failed to load food id=$id: $e');
      error.value = e;
      isLoading.value = false;
    }
  }

  void _loadSecondaryData(int id) {
    unawaited(_loadSecondaryDataTask(id));
  }

  Future<void> _loadSecondaryDataTask(int id) async {
    await Future.wait([
      _safeLoadFavorite(id),
    ]);
  }

  Future<void> _safeLoadFavorite(int id) async {
    try {
      final result = await _interactionRepository.checkFavorite(id);
      if (!isClosed) isFavorite.value = result;
    } catch (e) {
      dev.log('[FOOD_DETAIL] ⚠️ checkFavorite error: $e');
      if (!isClosed) isFavorite.value = false;
    }
  }

  // Tính lại price + canAddToCart cùng lúc để tránh gọi 2 vòng lặp
  void _recalc() {
    final f = food.value;
    if (f == null) return;

    double extra = 0;
    bool allGroupsSatisfied = true;

    for (final group in f.optionGroups) {
      final ids = selectedOptions[group.id] ?? [];
      if (ids.length < group.minSelect) allGroupsSatisfied = false;
      for (final id in ids) {
        final item = group.items.firstWhereOrNull((o) => o.id == id);
        if (item != null) extra += item.priceAdjustment;
      }
    }

    totalPrice.value = (f.price + extra) * quantity.value;
    canAddToCart.value = allGroupsSatisfied;
  }
}
