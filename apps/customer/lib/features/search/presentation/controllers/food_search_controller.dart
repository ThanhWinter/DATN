import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../home/data/models/home_items.dart';
import '../../../home/presentation/controllers/home_controller.dart';

/// Tìm kiếm trên cache [HomeController._foodsMaster], debounce 300ms + phân trang ảo 20.
class FoodSearchController extends GetxController {
  final searchCtrl = TextEditingController();

  final results = <FoodItemModel>[].obs;
  final hasQuery = false.obs;
  final isEmpty = true.obs;

  final List<FoodItemModel> _matchedAll = [];
  int _visibleEnd = 0;
  static const int _chunk = 20;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchCtrl.removeListener(_onSearchChanged);
    searchCtrl.dispose();
    super.onClose();
  }

  void clearSearch() => searchCtrl.clear();

  void navigateToDetail(FoodItemModel food) {
    Get.toNamed(AppRoutes.foodDetail, arguments: food.id);
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _applySearch);
  }

  void _applySearch() {
    final q = searchCtrl.text.trim().toLowerCase();
    hasQuery.value = q.isNotEmpty;
    if (q.isEmpty) {
      results.clear();
      _matchedAll.clear();
      isEmpty.value = true;
      _visibleEnd = 0;
      return;
    }

    try {
      final all = Get.find<HomeController>().allFoodItems;
      _matchedAll
        ..clear()
        ..addAll(all.where((f) {
          return f.name.toLowerCase().contains(q) ||
              (f.description?.toLowerCase().contains(q) ?? false) ||
              (f.categoryName?.toLowerCase().contains(q) ?? false);
        }));

      _visibleEnd = math.min(_chunk, _matchedAll.length);
      if (_visibleEnd <= 0) {
        results.clear();
      } else {
        results.assignAll(_matchedAll.sublist(0, _visibleEnd));
      }
      isEmpty.value = results.isEmpty;
    } catch (e) {
      results.clear();
      isEmpty.value = true;
    }
  }

  bool get hasMoreResults => _visibleEnd < _matchedAll.length;

  void loadMore() {
    if (!hasMoreResults) return;
    _visibleEnd = math.min(_visibleEnd + _chunk, _matchedAll.length);
    results.assignAll(_matchedAll.sublist(0, _visibleEnd));
  }

  void onScrollNearEnd() => loadMore();
}
