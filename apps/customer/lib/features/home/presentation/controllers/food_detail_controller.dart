import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../data/models/home_items.dart';

class FoodDetailController extends GetxController {
  final FoodItemModel item;

  FoodDetailController({required this.item});

  final quantity = 1.obs;
  final noteController = TextEditingController();

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }

  int get totalPrice => item.priceVnd * quantity.value;

  void increase() => quantity.value++;

  void decrease() {
    if (quantity.value > 1) quantity.value--;
  }

  void showQuantityDialog() {
    final ctrl = TextEditingController(text: '${quantity.value}');
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Chỉnh số lượng', style: AppTextStyles.h3),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          textAlign: TextAlign.center,
          style: AppTextStyles.h2,
          decoration: InputDecoration(
            hintText: 'Nhập số lượng',
            hintStyle: AppTextStyles.bodySmall,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryOrange),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Huỷ',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.grey600)),
          ),
          TextButton(
            onPressed: () {
              final qty = int.tryParse(ctrl.text.trim());
              if (qty != null && qty > 0) quantity.value = qty;
              Get.back();
            },
            child: Text('Xác nhận',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.primaryOrange)),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void addToCart() {
    Get.find<CartController>().addItem(
      CartItemModel(
        id: item.id.toString(),
        name: item.name,
        price: item.priceVnd.toDouble(),
        quantity: quantity.value,
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
        imageUrl: item.imageUrl,
      ),
    );
    Get.back();
    Get.snackbar(
      'Đã thêm vào giỏ',
      '${item.name} x${quantity.value}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primaryOrange,
      colorText: AppColors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }
}
