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
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.errorRed,
        child: const Icon(Icons.delete_outline, color: AppColors.white, size: 22),
      ),
      onDismissed: (_) => controller.removeItem(item.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imageUrl != null
                  ? AppNetworkImage(
                      url: item.imageUrl!,
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                      errorWidget: _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.selectedOptions.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.optionsLabel,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primaryOrange),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.note != null && item.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(item.note!, style: AppTextStyles.bodySmall),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    '${item.price.toVnd()} ₫',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.primaryOrange),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QtyButton(
                  icon: Icons.remove,
                  onTap: () => controller.decreaseQuantity(item.id),
                ),
                GestureDetector(
                  onTap: _showQuantityDialog,
                  child: SizedBox(
                    width: 28,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                _QtyButton(
                  icon: Icons.add,
                  onTap: () => controller.increaseQuantity(item.id),
                  filled: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 68,
      height: 68,
      color: AppColors.grey200,
      child: const Icon(Icons.fastfood_outlined, color: AppColors.grey400, size: 28),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: filled ? AppColors.primaryOrange : AppColors.transparent,
          border: filled
              ? null
              : Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: filled ? AppColors.white : AppColors.textDark,
        ),
      ),
    );
  }
}
