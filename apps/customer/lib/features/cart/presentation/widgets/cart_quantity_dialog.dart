import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core_ui/core_ui.dart';

class CartQuantityDialog extends StatefulWidget {
  final int initialQuantity;
  final void Function(int) onConfirm;

  const CartQuantityDialog({
    super.key,
    required this.initialQuantity,
    required this.onConfirm,
  });

  @override
  State<CartQuantityDialog> createState() => _CartQuantityDialogState();
}

class _CartQuantityDialogState extends State<CartQuantityDialog> {
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
