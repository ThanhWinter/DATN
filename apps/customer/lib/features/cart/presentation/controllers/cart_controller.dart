import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../main/presentation/controllers/main_controller.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';

class CartController extends GetxController {
  final CartRepository _repository;

  CartController(this._repository);

  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxDouble totalPrice = 0.0.obs;

  /// Tránh race: user thêm món trước khi snapshot server về → không ghi đè giỏ local.
  bool _initialHydrationApplied = false;
  bool _cartMutatedBeforeHydration = false;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await _repository.fetchCartItems();
    if (!_initialHydrationApplied) {
      if (!_cartMutatedBeforeHydration) {
        cartItems.assignAll(items);
      }
      _initialHydrationApplied = true;
    }
    _recalcTotal();
    _syncMainCartBadge();
  }

  void _notifyCartMutationBeforeHydration() {
    if (!_initialHydrationApplied) {
      _cartMutatedBeforeHydration = true;
    }
  }

  void increaseQuantity(String id) {
    _notifyCartMutationBeforeHydration();
    final index = cartItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      cartItems[index] = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + 1,
      );
      _recalcTotal();
    }
  }

  void decreaseQuantity(String id) {
    _notifyCartMutationBeforeHydration();
    final index = cartItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (cartItems[index].quantity > 1) {
        cartItems[index] = cartItems[index].copyWith(
          quantity: cartItems[index].quantity - 1,
        );
      } else {
        cartItems.removeAt(index);
      }
      _recalcTotal();
    }
  }

  void removeItem(String id) {
    _notifyCartMutationBeforeHydration();
    cartItems.removeWhere((item) => item.id == id);
    _recalcTotal();
  }

  void setQuantity(String id, int quantity) {
    _notifyCartMutationBeforeHydration();
    if (quantity <= 0) {
      removeItem(id);
      return;
    }
    final index = cartItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      cartItems[index] = cartItems[index].copyWith(quantity: quantity);
      _recalcTotal();
    }
  }

  void clearCart() {
    _notifyCartMutationBeforeHydration();
    cartItems.clear();
    totalPrice.value = 0;
    _syncMainCartBadge();
  }

  // Cùng key (foodId + options giống nhau) → tăng quantity
  // Khác key (cùng food, options khác) → item mới
  void addItem(CartItemModel newItem) {
    _notifyCartMutationBeforeHydration();
    final index = cartItems.indexWhere((item) => item.id == newItem.id);
    if (index != -1) {
      cartItems[index] = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + newItem.quantity,
      );
    } else {
      cartItems.add(newItem);
    }
    _recalcTotal();
    Get.snackbar(
      'Đã thêm vào giỏ',
      '${newItem.quantity}x ${newItem.name}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xFF1C1C1C),
      colorText: const Color(0xFFFFFFFF),
      borderRadius: 12,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      icon: const Icon(Icons.check_circle_rounded,
          color: Color(0xFF10B981), size: 22),
    );
  }

  void _recalcTotal() {
    totalPrice.value = cartItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );
    _syncMainCartBadge();
  }

  void _syncMainCartBadge() {
    if (!Get.isRegistered<MainController>()) return;
    final sum = cartItems.fold<int>(0, (a, b) => a + b.quantity);
    Get.find<MainController>().cartItemBadgeCount.value = sum;
  }
}
