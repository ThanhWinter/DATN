import "package:core_ui/core_ui.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";

import "../controllers/otp_controller.dart";

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // ValueNotifier per box — KHÔNG dùng setState toàn widget, tránh xung đột animation.
  final List<ValueNotifier<bool>> _focusedNotifiers =
      List.generate(6, (_) => ValueNotifier(false));
  final List<ValueNotifier<bool>> _hasValueNotifiers =
      List.generate(6, (_) => ValueNotifier(false));

  late final OtpController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OtpController>();

    for (int i = 0; i < 6; i++) {
      final index = i;

      // Backspace trên ô trống → xóa ô trước và lùi focus.
      _focusNodes[index].onKeyEvent = (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[index].text.isEmpty &&
            index > 0) {
          _controllers[index - 1].clear();
          _hasValueNotifiers[index - 1].value = false;
          _focusNodes[index - 1].requestFocus();
          _onOtpChanged();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };

      // Cập nhật notifier — KHÔNG gọi setState.
      _focusNodes[index].addListener(() {
        _focusedNotifiers[index].value = _focusNodes[index].hasFocus;
        if (_focusNodes[index].hasFocus && _controllers[index].text.isNotEmpty) {
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    for (var n in _focusedNotifiers) {
      n.dispose();
    }
    for (var n in _hasValueNotifiers) {
      n.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged() {
    final otp = _controllers.map((c) => c.text).join();
    controller.onOtpChanged(otp);
    if (otp.length == 6) {
      FocusScope.of(context).unfocus();
      controller.verify();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background Image ───────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              "assets/images/otp_bg.jpg",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.primaryOrangeDark,
              ),
            ),
          ),

          // ── Dark overlay ──────────────────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),

          // ── Nội dung chính ─────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),

                        Text(
                          "Xác thực OTP",
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Obx(() => RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.75),
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(
                                      text: "Mã xác thực đã được gửi đến\n"),
                                  TextSpan(
                                    text: controller.email.value,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.accentGold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )),

                        const SizedBox(height: 52),

                        _buildOtpInput(),

                        const SizedBox(height: 52),

                        Obx(() => GradientActionButton(
                              icon: Icons.verified_user_outlined,
                              iconColor: AppColors.primaryOrange,
                              text: "Xác thực ngay",
                              isPrimary: true,
                              onTap: controller.isLoading.value
                                  ? () {}
                                  : controller.verify,
                            )),

                        const SizedBox(height: 28),

                        Obx(() {
                          final countdown = controller.resendCountdown.value;
                          final isResending = controller.isResending.value;

                          return Center(
                            child: TextButton(
                              onPressed: (countdown > 0 || isResending)
                                  ? null
                                  : controller.resendOtp,
                              child: isResending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: AppColors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      countdown > 0
                                          ? "Gửi lại sau ${countdown}s"
                                          : "Chưa nhận được mã? Gửi lại",
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: countdown > 0
                                            ? AppColors.white
                                                .withValues(alpha: 0.45)
                                            : AppColors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Loading Overlay ────────────────────────────────────────────────
          Obx(() => controller.isLoading.value
              ? Container(
                  color: AppColors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 3,
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
        onPressed: Get.back,
      ),
    );
  }

  Widget _buildOtpInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        // AnimatedBuilder lắng nghe 2 notifier — chỉ rebuild 1 box, không ảnh hưởng
        // route transition animation của màn hình.
        return AnimatedBuilder(
          animation: Listenable.merge(
              [_focusedNotifiers[index], _hasValueNotifiers[index]]),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            onChanged: (value) {
              _hasValueNotifiers[index].value = value.isNotEmpty;
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
              _onOtpChanged();
            },
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: "",
            ),
          ),
          builder: (_, child) {
            final isFocused = _focusedNotifiers[index].value;
            final hasValue = _hasValueNotifiers[index].value;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 60,
              decoration: BoxDecoration(
                color: isFocused
                    ? AppColors.white.withValues(alpha: 0.22)
                    : hasValue
                        ? AppColors.white.withValues(alpha: 0.16)
                        : AppColors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFocused
                      ? AppColors.accentGold
                      : hasValue
                          ? AppColors.white.withValues(alpha: 0.5)
                          : AppColors.white.withValues(alpha: 0.2),
                  width: isFocused ? 2 : 1.2,
                ),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.accentGold.withValues(alpha: 0.35),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: child,
            );
          },
        );
      }),
    );
  }
}
