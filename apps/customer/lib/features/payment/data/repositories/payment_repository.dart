import 'package:core_network/core_network.dart';

class PaymentRepository {
  PaymentRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<({String zpTransToken, String appTransId})> createZaloPayOrder({
    required String orderId,
  }) async {
    final response = await _apiClient.post(
      '/payments/zalopay/create?orderId=$orderId',
    );
    final result = response['result'] as Map<String, dynamic>?;
    if (result == null) {
      throw Exception('Phản hồi ZaloPay không hợp lệ từ máy chủ.');
    }
    final zpTransToken = result['zp_trans_token'] as String?;
    final appTransId = result['app_trans_id'] as String?;
    if (zpTransToken == null || zpTransToken.isEmpty) {
      throw Exception('Không nhận được token thanh toán ZaloPay.');
    }
    if (appTransId == null || appTransId.isEmpty) {
      throw Exception('Không nhận được mã giao dịch ZaloPay.');
    }
    return (zpTransToken: zpTransToken, appTransId: appTransId);
  }

  /// Queries the backend to verify the actual ZaloPay transaction status.
  /// Returns true if payment was confirmed successful by the server.
  Future<bool> queryPaymentStatus(String appTransId) async {
    final response = await _apiClient.post(
      '/payments/zalopay/query?appTransId=$appTransId',
    );
    final result = response['result'] as Map<String, dynamic>? ?? {};
    final returnCode = (result['return_code'] as num?)?.toInt() ?? 0;
    return returnCode == 1;
  }
}
