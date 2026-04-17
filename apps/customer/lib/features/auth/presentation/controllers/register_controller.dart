import "package:get/get.dart";

class RegisterController extends GetxController {
  // ── Loading & Visibility State ───────────────────────────────────────────
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final selectedDob = Rxn<DateTime>();

  // ── Validation Error State ───────────────────────────────────────────────
  final lastNameError = "".obs;
  final firstNameError = "".obs;
  final emailError = "".obs;
  final phoneError = "".obs;
  final dobError = "".obs;
  final passwordError = "".obs;
  final confirmPasswordError = "".obs;

  void togglePassword() => isPasswordVisible.toggle();
  void toggleConfirmPassword() => isConfirmPasswordVisible.toggle();

  void setDob(DateTime date) {
    selectedDob.value = date;
    dobError.value = "";
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    if (!_validate(firstName, lastName, email, phone, password, confirmPassword)) return;
    isLoading.value = true;
    try {
      // TODO: Call repository.signUp(firstName, lastName, email, phone, password, selectedDob.value)
      await Future.delayed(const Duration(milliseconds: 500));
      Get.snackbar(
        "Thành công",
        "Hệ thống đã gửi mã OTP đến email của bạn.",
        snackPosition: SnackPosition.TOP,
      );
      // TODO: await Future.delayed(const Duration(milliseconds: 500)); Get.toNamed(AppRoutes.otpVerification, arguments: email.trim())
    } catch (e) {
      Get.snackbar(
        "Lỗi đăng ký",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate(
    String firstName,
    String lastName,
    String email,
    String phone,
    String password,
    String confirmPassword,
  ) {
    bool isValid = true;
    firstNameError.value = "";
    lastNameError.value = "";
    emailError.value = "";
    phoneError.value = "";
    dobError.value = "";
    passwordError.value = "";
    confirmPasswordError.value = "";

    if (firstName.trim().isEmpty) {
      firstNameError.value = "Vui lòng nhập tên";
      isValid = false;
    }
    if (lastName.trim().isEmpty) {
      lastNameError.value = "Vui lòng nhập họ";
      isValid = false;
    }
    if (!GetUtils.isEmail(email)) {
      emailError.value = "Email không hợp lệ";
      isValid = false;
    }
    if (phone.trim().length < 10) {
      phoneError.value = "Số điện thoại không hợp lệ";
      isValid = false;
    }
    if (selectedDob.value == null) {
      dobError.value = "Vui lòng chọn ngày sinh";
      isValid = false;
    }
    if (password.length < 6) {
      passwordError.value = "Mật khẩu tối thiểu 6 ký tự";
      isValid = false;
    }
    if (password != confirmPassword) {
      confirmPasswordError.value = "Mật khẩu không khớp";
      isValid = false;
    }
    return isValid;
  }
}
