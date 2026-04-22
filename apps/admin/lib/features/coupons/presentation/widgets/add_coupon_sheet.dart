import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/coupon_model.dart';
import '../controllers/coupon_controller.dart';

class AddCouponSheet extends StatefulWidget {
  const AddCouponSheet({super.key});

  @override
  State<AddCouponSheet> createState() => _AddCouponSheetState();
}

class _AddCouponSheetState extends State<AddCouponSheet> {
  final _codeCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _minOrderCtrl = TextEditingController();
  final _maxDiscountCtrl = TextEditingController();
  final _usageLimitCtrl = TextEditingController();
  String _type = CouponModel.typePercent;
  DateTime _expiresAt = DateTime.now().add(const Duration(days: 30));

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
      initialDate: _expiresAt,
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
    Get.find<CouponController>().addCoupon(CouponModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      code: _codeCtrl.text.trim().toUpperCase(),
      discountType: _type,
      discountValue: value,
      expiresAt: _expiresAt,
      minOrderValue: double.tryParse(_minOrderCtrl.text),
      maxDiscount: double.tryParse(_maxDiscountCtrl.text),
      usageLimit: int.tryParse(_usageLimitCtrl.text),
    ));
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tạo mã khuyến mãi', style: AppTextStyles.h3),
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
            Row(
              children: [
                Expanded(
                  child: _TypeButton(
                    label: 'Theo %',
                    icon: Icons.percent,
                    selected: _type == CouponModel.typePercent,
                    onTap: () => setState(() => _type = CouponModel.typePercent),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TypeButton(
                    label: 'Số tiền cố định',
                    icon: Icons.attach_money,
                    selected: _type == CouponModel.typeFixed,
                    onTap: () => setState(() => _type = CouponModel.typeFixed),
                  ),
                ),
              ],
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
              child: PrimaryButton(label: 'Tạo mã khuyến mãi', onPressed: _submit),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryOrange.withValues(alpha: 0.1)
              : AppColors.grey100,
          border: Border.all(
            color: selected ? AppColors.primaryOrange : AppColors.grey300,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? AppColors.primaryOrange : AppColors.grey600),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: selected ? AppColors.primaryOrange : AppColors.textGrey,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                )),
          ],
        ),
      ),
    );
  }
}
