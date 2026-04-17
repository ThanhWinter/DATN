import '../models/cart_item_model.dart';

class CartRepository {
  // TODO: Implement actual API fetch
  Future<List<CartItemModel>> fetchCartItems() async {
    // Simulated network delay
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}
