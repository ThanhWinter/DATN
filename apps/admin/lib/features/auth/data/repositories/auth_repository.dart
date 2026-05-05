import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/auth_models.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<TokenResponse> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    dev.log(
        '[AUTH/REPO] Admin login request for: $email (rememberMe: $rememberMe)');
    final response = await _apiClient.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
        'rememberMe': rememberMe,
      },
    );
    return TokenResponse.fromJson(response['result']);
  }

  Future<void> registerAdmin({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String dob,
    required int gender,
  }) async {
    dev.log('[AUTH/REPO] Admin register: $email');
    await _apiClient.post(
      '/auth/register-admin',
      body: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'dob': dob,
        'gender': gender,
      },
    );
  }

  Future<void> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    dev.log('[AUTH/REPO] Verify OTP for: $email');
    await _apiClient.post(
      '/auth/verify-register',
      body: {'email': email, 'otpCode': otpCode},
    );
  }

  Future<void> resendOtp({
    required String email,
    required String type,
  }) async {
    dev.log('[AUTH/REPO] Resend OTP ($type) to: $email');
    await _apiClient.post(
      '/auth/resend-otp',
      body: {'email': email, 'type': type},
    );
  }

  Future<void> logout({required String token}) async {
    dev.log('[AUTH/REPO] Admin logout request');
    await _apiClient.post('/auth/logout', body: {'token': token});
  }

  Future<void> unregisterDevice(String fcmToken) async {
    dev.log('[AUTH/REPO] Unregistering FCM device token');
    await _apiClient.delete(
      '/user/devices/unregister?fcmToken=${Uri.encodeQueryComponent(fcmToken)}',
    );
    dev.log('[AUTH/REPO] ✅ Device unregistered');
  }

  Future<void> forgotPassword({required String email}) async {
    dev.log('[AUTH/REPO] Admin forgot password request for: $email');
    await _apiClient.post(
      '/auth/forgot-password',
      body: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    dev.log('[AUTH/REPO] Admin reset password request for: $email');
    await _apiClient.post(
      '/auth/reset-password',
      body: {
        'email': email,
        'otpCode': otpCode,
        'newPassword': newPassword,
      },
    );
  }
}
