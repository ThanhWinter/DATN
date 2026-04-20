import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SnapHelperWidget<T> extends StatelessWidget {
  final RxBool isLoading;
  final Rxn<Object>? error;
  final bool Function()? isEmpty;
  final Widget Function() onSuccess;
  final VoidCallback? onRetry;
  final Widget? loadingWidget;
  final String? emptyMessage;
  final Widget? emptyWidget;

  const SnapHelperWidget({
    super.key,
    required this.isLoading,
    required this.onSuccess,
    this.error,
    this.isEmpty,
    this.onRetry,
    this.loadingWidget,
    this.emptyMessage,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return loadingWidget ??
            const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            );
      }

      if (error != null && error!.value != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
              const SizedBox(height: 16),
              Text(
                'Có lỗi xảy ra',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Thử lại', style: AppTextStyles.button),
                ),
              ],
            ],
          ),
        );
      }

      if (isEmpty != null && isEmpty!()) {
        if (emptyWidget != null) return emptyWidget!;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined, size: 48, color: AppColors.grey400),
              const SizedBox(height: 16),
              Text(
                emptyMessage ?? 'Không có dữ liệu',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        );
      }

      return onSuccess();
    });
  }
}
