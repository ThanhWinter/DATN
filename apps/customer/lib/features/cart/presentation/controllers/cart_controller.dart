import 'package:get/get.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';

class CartController extends GetxController {
  // ignore: unused_field
  final CartRepository _repository = CartRepository();

  // RxList for state
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;

  // RxDouble to avoid computing inside Obx/rebuild storms
  final RxDouble totalPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    // // TODO: mock data (Tạm thời tắt để hiển thị trạng thái Giỏ Hàng Trống)
    cartItems.value = [];
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

  void calculateTotalPrice() {
    double total = 0.0;
    for (var item in cartItems) {
      total += item.price * item.quantity;
    }
    totalPrice.value = total;
  }

  void addItem(CartItemModel newItem) {
    final index = cartItems.indexWhere((item) => item.id == newItem.id);
    if (index != -1) {
      increaseQuantity(newItem.id);
    } else {
      cartItems.add(newItem);
      calculateTotalPrice();
    }
  }
}
