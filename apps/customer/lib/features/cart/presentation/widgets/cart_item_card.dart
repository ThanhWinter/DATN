import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core_ui/core_ui.dart';
import '../../data/models/cart_item_model.dart';
import '../controllers/cart_controller.dart';
import 'cart_quantity_dialog.dart';

class CartItemCard extends GetView<CartController> {
  final CartItemModel item;

  const CartItemCard({super.key, required this.item});

  void _showQuantityDialog() {
    Get.dialog<void>(
      CartQuantityDialog(
        initialQuantity: item.quantity,
        onConfirm: (qty) => controller.setQuantity(item.id, qty),
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.imageUrl != null
                ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                : const Icon(Icons.fastfood, color: AppColors.grey600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.bodyLarge),
                if (item.note != null && item.note!.isNotEmpty)
                  Text(item.note!, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text(
                  '${item.price.toVnd()} ₫',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.primaryOrange),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nút xoá sản phẩm
              GestureDetector(
                onTap: () => controller.removeItem(item.id),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.grey600,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              // Điều chỉnh số lượng: nhấn số để nhập tay
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => controller.decreaseQuantity(item.id),
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.grey600,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 22,
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _showQuantityDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: AppTextStyles.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () => controller.increaseQuantity(item.id),
                    icon: const Icon(
                      Icons.add_circle,
                      color: AppColors.primaryOrange,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 22,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
