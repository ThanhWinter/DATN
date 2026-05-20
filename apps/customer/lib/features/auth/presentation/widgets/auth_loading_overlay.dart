import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Loading overlay dùng chung cho tất cả màn hình auth.
/// Đặt trong Stack, bên trên nội dung chính.
class AuthLoadingOverlay extends StatelessWidget {
  const AuthLoadingOverlay({super.key, required this.isLoading});

  final RxBool isLoading;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => isLoading.value
          ? Container(
              color: AppColors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 3,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
