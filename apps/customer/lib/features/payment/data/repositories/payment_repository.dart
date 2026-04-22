import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../../../../app/config/app_config.dart';

class PaymentRepository {
  static const _createOrderUrl = 'https://sb-openapi.zalopay.vn/v2/create';

  Future<String> createZaloPayOrder({
    required String appUser,
    required int amount,
    required List<Map<String, dynamic>> items,
  }) async {
    final appTime = DateTime.now().millisecondsSinceEpoch;
    final appTransId = _generateAppTransId();
    final embedData = jsonEncode({'redirecturl': 'zpdk-${AppConfig.zaloPayAppId}://'});
    final itemsJson = jsonEncode(items);
    final description = 'Thanh toán đơn hàng #$appTransId';

    final rawData =
        '${AppConfig.zaloPayAppId}|$appTransId|$appUser|$amount|$appTime|$embedData|$itemsJson';
    final mac = _hmacSha256(AppConfig.zaloPayKey1, rawData);

    final response = await http
        .post(
          Uri.parse(_createOrderUrl),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'app_id': AppConfig.zaloPayAppId.toString(),
            'app_user': appUser,
            'app_time': appTime.toString(),
            'amount': amount.toString(),
            'app_trans_id': appTransId,
            'embed_data': embedData,
            'item': itemsJson,
            'description': description,
            'mac': mac,
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Không thể kết nối ZaloPay (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['return_code'] != 1) {
      throw Exception(body['return_message'] ?? 'Tạo đơn hàng thất bại');
    }

    return body['zp_trans_token'] as String;
  }

  String _generateAppTransId() {
    final now = DateTime.now();
    final yy = now.year.toString().substring(2);
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '$yy$mm${dd}_${now.millisecondsSinceEpoch}';
  }

  String _hmacSha256(String key, String data) {
    final hmac = Hmac(sha256, utf8.encode(key));
    return hmac.convert(utf8.encode(data)).toString();
  }
}
