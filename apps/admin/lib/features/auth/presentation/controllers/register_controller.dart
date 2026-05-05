import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/auth_repository.dart';

class RegisterController extends GetxController {
  RegisterController(this._repository);

  final AuthRepository _repository;

  final selectedDob = Rxn<DateTime>();
  final selectedGender = 1.obs; // 1: Nam, 0: Nữ
  final isLoading = false.obs;

  final firstNameError = ''.obs;
  final lastNameError = ''.obs;
  final emailError = ''.obs;
  final phoneError = ''.obs;
  final dobError = ''.obs;
  final passwordError = ''.obs;
  final confirmPasswordError = ''.obs;

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final registerSuccess = false.obs;
  String _pendingEmail = '';
  String get pendingEmail => _pendingEmail;

  static final _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,16}$',
  );
  static final _phoneRegex = RegExp(r'^\d{10}$');

  void selectGender(int value) => selectedGender.value = value;
  void togglePassword() => isPasswordVisible.toggle();
  void toggleConfirmPassword() => isConfirmPasswordVisible.toggle();

  void setDob(DateTime date) {
    selectedDob.value = date;
    dobError.value = '';
  }

  String get dobDisplay => selectedDob.value == null
      ? ''
      : DateFormat('dd/MM/yyyy').format(selectedDob.value!);

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    registerSuccess.value = false;
    if (!_validate(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
    )) {
      return;
    }

    isLoading.value = true;
    try {
      final dob = DateFormat('yyyy-MM-dd').format(selectedDob.value!);
      await _repository.registerAdmin(
        email: email.trim(),
        password: password.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phone: phone.trim(),
        dob: dob,
        gender: selectedGender.value,
      );

      dev.log('[REGISTER] Admin OTP sent to ${email.trim()}');
      _pendingEmail = email.trim();
      registerSuccess.value = true;
    } catch (e) {
      dev.log('[REGISTER] Admin failed: $e');
      final message = e is ApiException
          ? _mapError(e.message)
          : 'Đăng ký thất bại. Vui lòng thử lại.';
      Get.snackbar(
        'Đăng ký thất bại',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) {
    firstNameError.value = '';
    lastNameError.value = '';
    emailError.value = '';
    phoneError.value = '';
    dobError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';

    bool isValid = true;

    if (lastName.trim().isEmpty) {
      lastNameError.value = 'Vui lòng nhập họ';
      isValid = false;
    }
    if (firstName.trim().isEmpty) {
      firstNameError.value = 'Vui lòng nhập tên';
      isValid = false;
    }
    if (email.trim().isEmpty) {
      emailError.value = 'Vui lòng nhập email';
      isValid = false;
    } else if (!GetUtils.isEmail(email.trim())) {
      emailError.value = 'Email không hợp lệ';
      isValid = false;
    }
    if (phone.trim().isEmpty) {
      phoneError.value = 'Vui lòng nhập số điện thoại';
      isValid = false;
    } else if (!_phoneRegex.hasMatch(phone.trim())) {
      phoneError.value = 'Số điện thoại phải 10 chữ số';
      isValid = false;
    }
    if (selectedDob.value == null) {
      dobError.value = 'Vui lòng chọn ngày sinh';
      isValid = false;
    }
    if (password.isEmpty) {
      passwordError.value = 'Vui lòng nhập mật khẩu';
      isValid = false;
    } else if (!_passwordRegex.hasMatch(password)) {
      passwordError.value = 'Mật khẩu 8–16 ký tự, gồm chữ hoa, thường, số, ký tự đặc biệt';
      isValid = false;
    }
    if (confirmPassword != password) {
      confirmPasswordError.value = 'Mật khẩu xác nhận không khớp';
      isValid = false;
    }

    return isValid;
  }

  String _mapError(String message) => switch (message) {
        'User existed!' => 'Email này đã được đăng ký.',
        'INVALID_EMAIL' => 'Định dạng email không hợp lệ.',
        'INVALID_PASSWORD' => 'Mật khẩu không đúng định dạng yêu cầu.',
        'INVALID_PHONE' => 'Số điện thoại không hợp lệ.',
        _ => 'Đăng ký thất bại. Vui lòng thử lại.',
      };
}
