import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core_ui/core_ui.dart'; // Ensure correct import for AppColors and AppTextStyles
import '../controllers/cart_controller.dart';
import '../../data/models/cart_item_model.dart';
// Note: You may need to import specific widgets from core_ui if needed, e.g., PrimaryButton.
// Assuming PrimaryButton or GradientActionButton exists in core_ui.

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Giỏ hàng của bạn',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.cartItems.isEmpty) {
                return const Center(
                  child: Text('Giỏ hàng của bạn đang trống', style: AppTextStyles.bodyLarge),
                );
              }
              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: controller.cartItems.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: AppColors.grey300),
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return _buildCartItem(item);
                },
              );
            }),
          ),
          _buildBottomCheckoutBar(),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
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
                    onTap: () => _showQuantityDialog(item),
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

  void _showQuantityDialog(CartItemModel item) {
    Get.dialog<void>(
      _QuantityInputDialog(
        initialQuantity: item.quantity,
        onConfirm: (qty) => controller.setQuantity(item.id, qty),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildBottomCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grey300)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black54,
            blurRadius: 4,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng:', style: AppTextStyles.h3),
                Obx(() => Text(
                      '${controller.totalPrice.value.toVnd()} ₫',
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.primaryOrangeDark),
                    )),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle checkout action
                  Get.snackbar(
                    'Thông báo',
                    'Chức năng thanh toán đang được phát triển',
                    backgroundColor: AppColors.primaryOrange,
                    colorText: AppColors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Thanh toán', style: AppTextStyles.button),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _QuantityInputDialog extends StatefulWidget {
  final int initialQuantity;
  final void Function(int) onConfirm;

  const _QuantityInputDialog({
    required this.initialQuantity,
    required this.onConfirm,
  });

  @override
  State<_QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<_QuantityInputDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.initialQuantity}');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Chỉnh số lượng', style: AppTextStyles.h3),
      content: TextField(
        controller: _ctrl,
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
          child: Text(
            'Huỷ',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey600),
          ),
        ),
        TextButton(
          onPressed: () {
            final qty = int.tryParse(_ctrl.text.trim());
            if (qty != null) widget.onConfirm(qty);
            Get.back();
          },
          child: Text(
            'Xác nhận',
            style:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryOrange),
          ),
        ),
      ],
    );
  }
}
