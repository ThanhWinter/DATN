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
    calculateTotalPrice();
  }

  void increaseQuantity(String id) {
    final index = cartItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = cartItems[index];
      cartItems[index] = item.copyWith(quantity: item.quantity + 1);
      calculateTotalPrice();
    }
  }

  void decreaseQuantity(String id) {
    final index = cartItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = cartItems[index];
      if (item.quantity > 1) {
        cartItems[index] = item.copyWith(quantity: item.quantity - 1);
      } else {
        cartItems.removeAt(index);
      }
      calculateTotalPrice();
    }
  }

  void removeItem(String id) {
    cartItems.removeWhere((item) => item.id == id);
    calculateTotalPrice();
  }

  void setQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeItem(id);
      return;
    }
    final index = cartItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      cartItems[index] = cartItems[index].copyWith(quantity: quantity);
      calculateTotalPrice();
    }
  }

  void clearCart() {
    cartItems.clear();
    totalPrice.value = 0;
  }

  void calculateTotalPrice() {
    totalPrice.value = cartItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );
  }

  void addItem(CartItemModel newItem) {
    final index = cartItems.indexWhere((item) => item.id == newItem.id);
    if (index != -1) {
      final item = cartItems[index];
      cartItems[index] =
          item.copyWith(quantity: item.quantity + newItem.quantity);
      calculateTotalPrice();
    } else {
      cartItems.add(newItem);
      calculateTotalPrice();
    }
  }
}
