import "dart:developer" as dev;
import "package:core_network/core_network.dart";
import "../models/auth_models.dart";

class AuthRepository {
  AuthRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<TokenResponse> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    dev.log("[AUTH/REPO] Login request for: $email (rememberMe: $rememberMe)");
    final response = await _apiClient.post(
      "/auth/login",
      body: {
        "email": email,
        "password": password,
        "rememberMe": rememberMe,
      },
    );
    return TokenResponse.fromJson(response["result"]);
  }

  Future<String> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String dob,
  }) async {
    dev.log("[AUTH/REPO] Register request for: $email");
    final response = await _apiClient.post(
      "/auth/register-customer",
      body: {
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "phone": phone,
        "password": password,
        "dob": dob,
        "gender": 1,
      },
    );
    return response["message"] ?? "Registration successful";
  }

  Future<void> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    dev.log("[AUTH/REPO] Verifying OTP for: $email");
    await _apiClient.post(
      "/auth/verify-register",
      body: {"email": email, "otpCode": otpCode},
    );
  }

  /// Gửi lại mã OTP.
  /// [type] phải là "REGISTER" hoặc "FORGOT_PASSWORD".
  Future<void> resendOtp({
    required String email,
    required String type,
  }) async {
    dev.log("[AUTH/REPO] Resending OTP ($type) to: $email");
    await _apiClient.post(
      "/auth/resend-otp",
      body: {"email": email, "type": type},
    );
  }

  /// Gửi token lên server để invalidate (đưa vào blacklist).
  Future<void> logout({required String token}) async {
    dev.log("[AUTH/REPO] Logout request");
    await _apiClient.post(
      "/auth/logout",
      body: {"token": token},
    );
  }

  Future<void> forgotPassword({required String email}) async {
    dev.log("[AUTH/REPO] Forgot password request for: $email");
    await _apiClient.post(
      "/auth/forgot-password",
      body: {"email": email},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    dev.log("[AUTH/REPO] Resetting password for: $email");
    await _apiClient.post(
      "/auth/reset-password",
      body: {
        "email": email,
        "otpCode": otpCode,
        "newPassword": newPassword,
      },
    );
  }

}
