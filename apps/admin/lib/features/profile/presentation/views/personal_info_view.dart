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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange));
        }
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.primaryOrangeDark,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 20, color: AppColors.white),
                onPressed: Get.back,
              ),
              title: const Text(
                'Thông tin cá nhân',
                style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
              centerTitle: true,
              actions: [
                Obx(() => controller.isSaving.value
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.white)),
                      )
                    : TextButton(
                        onPressed: controller.save,
                        child: const Text('Lưu',
                            style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                      )),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryOrangeDark,
                        AppColors.primaryOrange,
                        AppColors.primaryOrangeLight,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(() {
                          final url = controller.avatarUrl.value;
                          final isUploading =
                              controller.isUploadingAvatar.value;
                          return GestureDetector(
                            onTap: isUploading ? null : controller.pickAvatar,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        AppColors.white.withValues(alpha: 0.2),
                                    border: Border.all(
                                        color: AppColors.white
                                            .withValues(alpha: 0.8),
                                        width: 2.5),
                                  ),
                                  child: ClipOval(
                                    child: isUploading
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: AppColors.white))
                                        : url != null && url.isNotEmpty
                                            ? AppNetworkImage(
                                                url: url,
                                                fit: BoxFit.cover,
                                                errorWidget: const Icon(
                                                    Icons.person,
                                                    size: 40,
                                                    color: AppColors.white),
                                              )
                                            : const Icon(Icons.person,
                                                size: 40,
                                                color: AppColors.white),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.primaryOrange,
                                          width: 1.5),
                                    ),
                                    child: const Icon(Icons.camera_alt,
                                        size: 13,
                                        color: AppColors.primaryOrange),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        Obx(() => Text(
                              controller.adminEmail.value,
                              style: TextStyle(
                                  color:
                                      AppColors.white.withValues(alpha: 0.9),
                                  fontSize: 13),
                            )),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.touch_app,
                                  size: 11, color: AppColors.white),
                              SizedBox(width: 4),
                              Text('Nhấn vào ảnh để thay đổi',
                                  style: TextStyle(
                                      color: AppColors.white, fontSize: 11)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('Thông tin cơ bản'),
                    const SizedBox(height: 10),
                    _StyledField(
                      label: 'Họ',
                      controller: controller.firstNameCtrl,
                      hint: 'Nhập họ',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 12),
                    _StyledField(
                      label: 'Tên',
                      controller: controller.lastNameCtrl,
                      hint: 'Nhập tên',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 12),
                    _StyledField(
                      label: 'Số điện thoại',
                      controller: controller.phoneCtrl,
                      hint: 'Nhập số điện thoại',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 28),
                    Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isSaving.value
                                ? null
                                : controller.save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              disabledBackgroundColor: AppColors.grey300,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: controller.isSaving.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.white))
                                : const Text('Lưu thay đổi',
                                    style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                          ),
                        )),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textGrey,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        fontSize: 11,
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  const _StyledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.textLight),
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
        ),
      ],
    );
  }
}
