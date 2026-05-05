import 'package:get/get.dart';

import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/dashboard/data/repositories/statistic_repository.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // StatisticRepository đã được MainBinding đăng ký — dùng lại, không tạo mới
    Get.lazyPut<DashboardController>(
      () => DashboardController(Get.find<StatisticRepository>()),
    );
  }
}
