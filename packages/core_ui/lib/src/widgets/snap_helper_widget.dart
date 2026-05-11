import 'package:flutter/foundation.dart';
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
  final Future<void> Function()? onRefresh;
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
    this.onRefresh,
    this.loadingWidget,
    this.emptyMessage,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Obx chỉ track isLoading + error — KHÔNG bao giờ track reactive reads bên trong onSuccess()
    // onSuccess() được gọi trong _SnapContent.build(), nằm ngoài phạm vi Obx này
    return Obx(() => _SnapContent<T>(
          loading: isLoading.value,
          error: error?.value,
          empty: isEmpty?.call() ?? false,
          onSuccess: onSuccess,
          onRetry: onRetry,
          onRefresh: onRefresh,
          loadingWidget: loadingWidget,
          emptyMessage: emptyMessage,
          emptyWidget: emptyWidget,
        ));
  }

  static String _extractMessage(Object err) {
    final raw = err.toString();
    if (kDebugMode) {
      if (raw.contains('ApiException')) {
        final match = RegExp(r'ApiException\((\d+)\): (.+)').firstMatch(raw);
        if (match != null) return 'Lỗi ${match.group(1)}: ${match.group(2)}';
      }
      if (raw.contains('SocketException') ||
          raw.contains('Connection refused') ||
          raw.contains('Failed host lookup')) {
        return 'Không kết nối được server.\nKiểm tra backend có đang chạy không.';
      }
      if (raw.contains('TimeoutException')) {
        return 'Server phản hồi quá lâu. Kiểm tra mạng hoặc backend.';
      }
      return raw.length > 120 ? '${raw.substring(0, 120)}…' : raw;
    }
    if (raw.contains('SocketException') ||
        raw.contains('Connection refused') ||
        raw.contains('Failed host lookup')) {
      return 'Không có kết nối mạng. Vui lòng kiểm tra lại.';
    }
    return 'Vui lòng kiểm tra kết nối và thử lại.';
  }
}

// ── _SnapContent ──────────────────────────────────────────────────────────────
// Widget thuần (không Obx) — onSuccess() được gọi ở đây, ngoài reactive scope
// của Obx bên trên, nên các .obs bên trong onSuccess không tạo subscription rác.

class _SnapContent<T> extends StatelessWidget {
  final bool loading;
  final Object? error;
  final bool empty;
  final Widget Function() onSuccess;
  final VoidCallback? onRetry;
  final Future<void> Function()? onRefresh;
  final Widget? loadingWidget;
  final String? emptyMessage;
  final Widget? emptyWidget;

  const _SnapContent({
    required this.loading,
    required this.error,
    required this.empty,
    required this.onSuccess,
    this.onRetry,
    this.onRefresh,
    this.loadingWidget,
    this.emptyMessage,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return loadingWidget ??
          const Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          );
    }

    if (error != null) {
      final detail = SnapHelperWidget._extractMessage(error!);
      Widget errorContent = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off_rounded,
                    size: 36, color: AppColors.errorRed),
              ),
              const SizedBox(height: 20),
              const Text(
                'Không thể tải dữ liệu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                detail,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null || onRefresh != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (onRetry != null) onRetry!();
                    if (onRefresh != null) onRefresh!();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      );

      if (onRefresh != null) {
        return RefreshIndicator(
          onRefresh: onRefresh!,
          color: AppColors.primaryOrange,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: errorContent,
              ),
            ],
          ),
        );
      }
      return errorContent;
    }

    if (empty) {
      Widget emptyContent = emptyWidget ?? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined,
                size: 48, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(emptyMessage ?? 'Không có dữ liệu',
                style: AppTextStyles.bodyMedium),
          ],
        ),
      );

      if (onRefresh != null) {
        return RefreshIndicator(
          onRefresh: onRefresh!,
          color: AppColors.primaryOrange,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: emptyContent,
              ),
            ],
          ),
        );
      }
      return emptyContent;
    }

    return onSuccess();
  }
}
