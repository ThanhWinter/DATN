import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/coupon_model.dart';
import '../controllers/coupon_controller.dart';
import 'coupon_type_toggle.dart';

class EditCouponSheet extends StatefulWidget {
  const EditCouponSheet({required this.coupon, super.key});

  final CouponModel coupon;

  @override
  State<EditCouponSheet> createState() => _EditCouponSheetState();
}

class _EditCouponSheetState extends State<EditCouponSheet> {
  late final _codeCtrl = TextEditingController(text: widget.coupon.code);
  late final _valueCtrl = TextEditingController(
      text: widget.coupon.discountValue.toInt().toString());
  late final _minOrderCtrl = TextEditingController(
      text: widget.coupon.minOrderValue?.toInt().toString() ?? '');
  late final _maxDiscountCtrl = TextEditingController(
      text: widget.coupon.maxDiscount?.toInt().toString() ?? '');
  late final _usageLimitCtrl =
      TextEditingController(text: widget.coupon.usageLimit?.toString() ?? '');
  late String _type = widget.coupon.discountType;
  late DateTime _expiresAt = widget.coupon.expiresAt;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _valueCtrl.dispose();
    _minOrderCtrl.dispose();
    _maxDiscountCtrl.dispose();
    _usageLimitCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt.isAfter(DateTime.now())
          ? _expiresAt
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  void _submit() {
    if (_codeCtrl.text.trim().isEmpty || _valueCtrl.text.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
      return;
    }
    final value = double.tryParse(_valueCtrl.text);
    if (value == null) return;
    Get.find<CouponController>().updateCoupon(
      widget.coupon.id,
      CouponModel(
        id: widget.coupon.id,
        code: _codeCtrl.text.trim().toUpperCase(),
        discountType: _type,
        discountValue: value,
        expiresAt: _expiresAt,
        minOrderValue: double.tryParse(_minOrderCtrl.text),
        maxDiscount: double.tryParse(_maxDiscountCtrl.text),
        usageLimit: int.tryParse(_usageLimitCtrl.text),
        usedCount: widget.coupon.usedCount,
      ),
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9 - keyboardHeight,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Sửa mã khuyến mãi', style: AppTextStyles.h3),
              const SizedBox(height: 20),
              TextField(
                controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Mã coupon *',
                  prefixIcon: Icon(Icons.local_offer_outlined),
                  hintText: 'VD: SUMMER20',
                ),
              ),
              const SizedBox(height: 14),
              CouponTypeToggle(
                selectedType: _type,
                onChanged: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _valueCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _type == CouponModel.typePercent
                      ? 'Giá trị giảm (%) *'
                      : 'Số tiền giảm (đ) *',
                  prefixIcon: const Icon(Icons.discount_outlined),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minOrderCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Đơn tối thiểu (đ)',
                        prefixIcon: Icon(Icons.shopping_bag_outlined),
                      ),
                    ),
                  ),
                  if (_type == CouponModel.typePercent) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _maxDiscountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giảm tối đa (đ)',
                          prefixIcon: Icon(Icons.monetization_on_outlined),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _usageLimitCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Giới hạn lượt dùng',
                        prefixIcon: Icon(Icons.people_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ngày hết hạn',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(_fmtDate(_expiresAt),
                            style: AppTextStyles.bodyMedium),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(label: 'Lưu thay đổi', onPressed: _submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
