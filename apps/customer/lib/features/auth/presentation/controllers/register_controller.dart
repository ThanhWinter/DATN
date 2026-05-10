import "dart:developer" as dev;

import "package:core_network/core_network.dart";
import "package:core_ui/core_ui.dart";
import "package:get/get.dart";
import "package:intl/intl.dart";

import "../../../../app/routes/app_routes.dart";
import "../../data/repositories/auth_repository.dart";

// Phải khớp với @Pattern regex trong RegisterUserRequest.java của backend
const _passwordRegex =
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,16}$';

class RegisterController extends GetxController {
  RegisterController(this._authRepository);

  final AuthRepository _authRepository;

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final selectedDob = Rxn<DateTime>();

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
    if (!_validate(
        firstName, lastName, email, phone, password, confirmPassword)) {
      return;
    }

    dev.log("[AUTH/REGISTER] Attempting register for: $email");
    isLoading.value = true;
    try {
      final dobStr = DateFormat('yyyy-MM-dd').format(selectedDob.value!);
      await _authRepository.register(
        email: email.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phone: phone.trim(),
        password: password,
        dob: dobStr,
      );

      dev.log("[AUTH/REGISTER] ✅ Register success — OTP sent to $email");
      Get.snackbar(
        "Thành công",
        "Vui lòng kiểm tra email để lấy mã xác thực OTP.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        duration: const Duration(seconds: 3),
      );
      // 800ms cho snackbar animation hoàn tất trước khi route transition bắt đầu.
      await Future.delayed(const Duration(milliseconds: 800));
      Get.toNamed(AppRoutes.otpVerification, arguments: email.trim());
    } catch (e) {
      dev.log("[AUTH/REGISTER] ❌ Register failed: $e");
      final message = e is ApiException
          ? _mapErrorCode(e.message)
          : "Đăng ký thất bại. Vui lòng thử lại.";
      Get.snackbar(
        "Đăng ký thất bại",
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
        duration: const Duration(seconds: 3),
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
    if (!GetUtils.isEmail(email.trim())) {
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
    if (!RegExp(_passwordRegex).hasMatch(password)) {
      passwordError.value =
          "Mật khẩu phải từ 8 đến 16 ký tự, có ít nhất một chữ hoa (A-Z), "
          "một chữ thường (a-z), một chữ số và một ký tự đặc biệt trong nhóm "
          "@\$!%*?&. Không được chứa khoảng trắng.";
      isValid = false;
    }
    if (password != confirmPassword) {
      confirmPasswordError.value = "Mật khẩu không khớp";
      isValid = false;
    }
    return isValid;
  }

  String _mapErrorCode(String message) => switch (message) {
        "User already existed!" =>
          "Email này đã được đăng ký. Vui lòng dùng email khác.",
        "Validation failed" =>
          "Thông tin đăng ký không hợp lệ. Vui lòng kiểm tra lại.",
        "Unknow exception!" => "Lỗi máy chủ. Vui lòng thử lại sau.",
        "Kết nối quá lâu. Vui lòng kiểm tra mạng và thử lại." =>
          "Kết nối quá lâu. Vui lòng kiểm tra mạng và thử lại.",
        _ => "Đăng ký thất bại. Vui lòng thử lại.",
      };
}
