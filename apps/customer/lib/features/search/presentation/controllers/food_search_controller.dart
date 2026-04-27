import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../home/data/models/home_items.dart';
import '../../../home/presentation/controllers/home_controller.dart';

class FoodSearchController extends GetxController {
  final searchCtrl = TextEditingController();

  final results = <FoodItemModel>[].obs;
  final hasQuery = false.obs;
  final isEmpty = true.obs;

  @override
  void onInit() {
    super.onInit();
    searchCtrl.addListener(_filter);
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  void clearSearch() => searchCtrl.clear();

  void navigateToDetail(FoodItemModel food) {
    Get.toNamed(AppRoutes.foodDetail, arguments: food.id);
  }

  void _filter() {
    final q = searchCtrl.text.trim().toLowerCase();
    hasQuery.value = q.isNotEmpty;
    if (q.isEmpty) {
      results.clear();
      isEmpty.value = true;
      return;
    }
    try {
      final all = Get.find<HomeController>().allFoodItems;
      final filtered = all
          .where((f) =>
              f.name.toLowerCase().contains(q) ||
              (f.categoryName?.toLowerCase().contains(q) ?? false) ||
              (f.description?.toLowerCase().contains(q) ?? false))
          .toList();
      results.assignAll(filtered);
      isEmpty.value = filtered.isEmpty;
    } catch (e) {
      dev.log('[SEARCH] ❌ _filter error: $e');
    }
  }
}
