import 'package:flutter/services.dart';

extension CurrencyFormatExt on num {
  /// Chuyển đổi số thành chuỗi định dạng tiền tệ có dấu chấm phẩy (VD: 1.000.000)
  String toVnd() {
    final str = toStringAsFixed(0);
    return str.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final formatted = digits.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
