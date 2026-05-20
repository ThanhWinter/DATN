import 'dart:developer' as dev;
import 'dart:io';

import 'package:core_network/core_network.dart';
import 'package:http/http.dart' as http;

import '../models/dashboard_model.dart';

class StatisticRepository {
  StatisticRepository(this._apiClient, this._baseUrl);

  final IApiClient _apiClient;
  final String _baseUrl;

  Future<DashboardModel> getDashboard() async {
    dev.log('[STAT/REPO] Fetching dashboard stats...');
    final res = await _apiClient.get('/statistics/admin/dashboard');
    final dashboard =
        DashboardModel.fromJson(res['result'] as Map<String, dynamic>);
    dev.log(
        '[STAT/REPO] ✅ orders=${dashboard.todayOrders} revenue=${dashboard.todayRevenue}');
    return dashboard;
  }

  /// Ghi thẳng phản hồi HTTP xuống [targetFile] — không giữ toàn bộ [Uint8List] trong RAM.
  Future<void> exportRevenueToFile({
    required String token,
    required DateTime date,
    required File targetFile,
  }) async {
    final dateStr = [
      date.year.toString(),
      date.month.toString().padLeft(2, '0'),
      date.day.toString().padLeft(2, '0'),
    ].join('-');
    final uri =
        Uri.parse('$_baseUrl/statistics/admin/export-revenue?date=$dateStr');
    dev.log(
        '[STAT/REPO] Streaming export revenue for $dateStr → ${targetFile.path}');

    final client = http.Client();
    try {
      final request = http.Request('GET', uri);
      request.headers['Authorization'] = 'Bearer $token';
      final streamed = await client.send(request);

      if (streamed.statusCode != 200) {
        final errBody = await streamed.stream.bytesToString();
        dev.log('[STAT/REPO] export failed: ${streamed.statusCode} $errBody');
        throw ApiException(
          statusCode: streamed.statusCode,
          message: 'Xuất báo cáo thất bại',
        );
      }

      final sink = targetFile.openWrite();
      try {
        await streamed.stream.pipe(sink);
      } catch (e) {
        // pipe() đã đóng hoặc đang đóng sink — đảm bảo flush trước khi xoá
        try {
          await sink.close();
        } catch (_) {}
        // Xoá file bị hỏng để tránh user mở file thiếu dữ liệu
        try {
          await targetFile.delete();
        } catch (_) {}
        rethrow;
      }
      dev.log('[STAT/REPO] ✅ Streamed export to disk');
    } finally {
      client.close();
    }
  }
}
