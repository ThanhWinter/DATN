import 'package:get/get.dart';

import '../../data/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';

class CartController extends GetxController {
  final CartRepository _repository;

  CartController(this._repository);

  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxDouble totalPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await _repository.fetchCartItems();
    cartItems.assignAll(items);
    _recalcTotal();
  }

  void increaseQuantity(String id) {
    final index = cartItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      cartItems[index] = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + 1,
      );
      _recalcTotal();
    }
  }

  void decreaseQuantity(String id) {
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
    cartItems.removeWhere((item) => item.id == id);
    _recalcTotal();
  }

  void setQuantity(String id, int quantity) {
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
    cartItems.clear();
    totalPrice.value = 0;
  }

  // Cùng key (foodId + options giống nhau) → tăng quantity
  // Khác key (cùng food, options khác) → item mới
  void addItem(CartItemModel newItem) {
    final index = cartItems.indexWhere((item) => item.id == newItem.id);
    if (index != -1) {
      cartItems[index] = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + newItem.quantity,
      );
    } else {
      cartItems.add(newItem);
    }
    _recalcTotal();
  }

  void _recalcTotal() {
    totalPrice.value = cartItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );
  }
}
