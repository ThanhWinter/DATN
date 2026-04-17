import 'package:get/get.dart';

import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../data/models/home_items.dart';

class FoodDetailController extends GetxController {
  final FoodItemModel item;

  FoodDetailController({required this.item});

  final quantity = 1.obs;

  int get totalPrice => item.priceVnd * quantity.value;

  void increase() => quantity.value++;

  void decrease() {
    if (quantity.value > 1) quantity.value--;
  }

  void setQuantity(int qty) {
    if (qty > 0) quantity.value = qty;
  }

  void addToCart(String note) {
    Get.find<CartController>().addItem(
      CartItemModel(
        id: item.id.toString(),
        name: item.name,
        price: item.priceVnd.toDouble(),
        quantity: quantity.value,
        note: note.trim().isEmpty ? null : note.trim(),
        imageUrl: item.imageUrl,
      ),
    );
    Get.back();
  }
}
