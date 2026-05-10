import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/edit_profile_controller.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: Text(
          'Chỉnh sửa hồ sơ',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AvatarDisplay(),
              const SizedBox(height: 8),
              Text(
                'Ảnh đại diện chỉ đọc — không đổi ảnh trên app khách (upload media chỉ dành cho quản trị viên).',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textGrey,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text('Họ', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              _Field(
                controller: controller.lastNameController,
                hint: 'Nhập họ...',
                icon: Icons.person_outline,
                action: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              const Text('Tên', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              _Field(
                controller: controller.firstNameController,
                hint: 'Nhập tên...',
                icon: Icons.person_outline,
                action: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              const Text('Số điện thoại', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              _Field(
                controller: controller.phoneController,
                hint: 'Nhập số điện thoại...',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                action: TextInputAction.done,
              ),
              const SizedBox(height: 28),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Lưu thay đổi',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.saveProfile,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarDisplay extends StatelessWidget {
  const _AvatarDisplay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() {
        final profileController = Get.find<ProfileController>();
        final url = profileController.user.value?.avatarUrl;

        return Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.grey200,
            border: Border.all(color: AppColors.primaryOrange, width: 2),
          ),
          child: ClipOval(
            child: url != null && url.isNotEmpty
                ? AppNetworkImage(
                    url: url,
                    fit: BoxFit.cover,
                    errorWidget: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.grey400,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.grey400,
                  ),
          ),
        );
      }),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.action = TextInputAction.next,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction action;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: action,
      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textLight),
        prefixIcon: Icon(icon, color: AppColors.primaryOrange, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.primaryOrange, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }
}
