import 'package:get/get.dart';

import '../theme/app_colors.dart';

abstract final class AppSnackbar {
  static void error(String title, String message, {Duration? duration}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.errorRed,
      colorText: AppColors.white,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void success(String title, String message, {Duration? duration}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.successGreen,
      colorText: AppColors.white,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}
