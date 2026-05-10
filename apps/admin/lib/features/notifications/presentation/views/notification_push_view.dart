import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/notification_push_controller.dart';

class NotificationPushView extends GetView<NotificationPushController> {
  const NotificationPushView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Gửi thông báo', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info banner ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primaryOrange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.primaryOrange, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Thông báo sẽ được gửi đến TẤT CẢ khách hàng đang cài đặt ứng dụng.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primaryOrangeDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Form ─────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tiêu đề *', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.titleCtrl,
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: Khuyến mãi hôm nay!',
                      hintStyle: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey400),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      counterStyle: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey400),
                    ),
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  const Text('Nội dung *', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.bodyCtrl,
                    maxLines: 5,
                    maxLength: 300,
                    decoration: InputDecoration(
                      hintText:
                          'Ví dụ: Giảm 20% tất cả đơn hàng trong hôm nay...',
                      hintStyle: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey400),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      counterStyle: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey400),
                      alignLabelWithHint: true,
                    ),
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Preview ──────────────────────────────────────────────────
            Obx(() {
              final title = controller.titlePreview.value;
              final body = controller.bodyPreview.value;
              if (title.isEmpty && body.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Xem trước', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.grey300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.restaurant,
                              color: AppColors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.isNotEmpty ? title : '...',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                body.isNotEmpty ? body : '...',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textGrey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }),

            // ── Send button ───────────────────────────────────────────────
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        controller.canSend.value && !controller.isSending.value
                            ? controller.sendBroadcast
                            : null,
                    icon: controller.isSending.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: AppColors.white),
                          )
                        : const Icon(Icons.send_rounded,
                            color: AppColors.white),
                    label: Text(
                      controller.isSending.value
                          ? 'Đang gửi...'
                          : 'Gửi đến tất cả khách hàng',
                      style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      disabledBackgroundColor: AppColors.grey300,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
