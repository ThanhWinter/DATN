extension CurrencyFormatExt on num {
  /// Chuyển đổi số thành chuỗi định dạng tiền tệ có dấu chấm phẩy (VD: 1.000.000)
  String toVnd() {
    final str = toStringAsFixed(0);
    return str.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }
}
