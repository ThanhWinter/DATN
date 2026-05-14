import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/personal_info_controller.dart';

class PersonalInfoView extends GetView<PersonalInfoController> {
  const PersonalInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Thông tin cá nhân', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: Get.back,
        ),
        actions: [
          Obx(() => controller.isSaving.value
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryOrange)),
                )
              : TextButton(
                  onPressed: controller.save,
                  child: const Text('Lưu',
                      style: TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar
              Center(
                child: GestureDetector(
                  onTap: controller.pickAvatar,
                  child: Stack(
                    children: [
                      Obx(() {
                        final url = controller.avatarUrl.value;
                        return CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              AppColors.primaryOrange.withValues(alpha: 0.15),
                          backgroundImage:
                              url != null && url.isNotEmpty
                                  ? NetworkImage(url)
                                  : null,
                          child: (url == null || url.isEmpty)
                              ? const Icon(Icons.person,
                                  size: 44, color: AppColors.primaryOrange)
                              : null,
                        );
                      }),
                      Obx(() => controller.isUploadingAvatar.value
                          ? Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white),
                                ),
                              ),
                            )
                          : Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 14, color: AppColors.white),
                              ),
                            )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    controller.adminEmail.value,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textGrey),
                  )),
              const SizedBox(height: 24),
              // Form
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _FormField(
                      label: 'Họ',
                      controller: controller.firstNameCtrl,
                      hint: 'Nhập họ',
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _FormField(
                      label: 'Tên',
                      controller: controller.lastNameCtrl,
                      hint: 'Nhập tên',
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _FormField(
                      label: 'Số điện thoại',
                      controller: controller.phoneCtrl,
                      hint: 'Nhập số điện thoại',
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textGrey)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: AppTextStyles.labelLarge,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.grey300),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
