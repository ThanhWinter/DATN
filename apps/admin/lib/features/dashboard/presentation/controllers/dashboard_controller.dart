import 'dart:developer' as dev;
import 'dart:io';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../app/services/auth_service.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/statistic_repository.dart';

class DashboardController extends GetxController {
  DashboardController(this._repository);

  final StatisticRepository _repository;

  final isLoading = true.obs;
  final error = Rxn<String>();
  final isExporting = false.obs;
  final stats = Rx<DashboardModel>(DashboardModel.empty);

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    error.value = null;
    try {
      stats.value = await _repository.getDashboard();
      dev.log('[DASHBOARD/VM] ✅ Stats loaded');
    } catch (e) {
      dev.log('[DASHBOARD/VM] ❌ loadDashboard: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportRevenue(DateTime date) async {
    if (isExporting.value) return;
    final token = Get.find<AuthService>().getToken();
    if (token == null) return;
    isExporting.value = true;
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception('Không thể truy cập bộ nhớ ngoài');
      final dateStr = [
        date.year.toString(),
        date.month.toString().padLeft(2, '0'),
        date.day.toString().padLeft(2, '0'),
      ].join('-');
      final file = File('${dir.path}/Doanh_Thu_$dateStr.xlsx');
      await _repository.exportRevenueToFile(
        token: token,
        date: date,
        targetFile: file,
      );
      await _notifySaved(file.path, date);
    } catch (e) {
      dev.log('[DASHBOARD/VM] ❌ export: $e');
      Get.snackbar(
        'Lỗi xuất báo cáo',
        e.toString(),
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> _notifySaved(String path, DateTime date) async {
    dev.log('[DASHBOARD/VM] ✅ Saved: $path');
    Get.snackbar(
      'Xuất thành công',
      'Báo cáo tháng ${date.month}/${date.year} đã sẵn sàng.',
      backgroundColor: AppColors.successGreen,
      colorText: AppColors.white,
      duration: const Duration(seconds: 8),
      snackPosition: SnackPosition.BOTTOM,
      mainButton: TextButton(
        onPressed: () => OpenFilex.open(path),
        child: const Text(
          'Mở ngay',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
