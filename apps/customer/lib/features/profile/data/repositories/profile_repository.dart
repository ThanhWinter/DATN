import "dart:developer" as dev;
import 'package:core_network/core_network.dart';

import '../../../../app/services/auth_service.dart';
import '../models/profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._apiClient, this._authService);

  final IApiClient _apiClient;
  final AuthService _authService;

  Future<UserModel> fetchUser() async {
    try {
      final response = await _apiClient.get('/users/my-info');
      // In log để bác check Docker trả về cái gì
      dev.log("[PROFILE] 🟢 API Response: $response");
      
      final result = response['result'] as Map<String, dynamic>?;

      if (result == null) {
        throw const ApiException(
            statusCode: 500, message: 'Dữ liệu người dùng trống');
      }

      final user = UserModel(
        id: _authService.getUserId() ?? '',
        firstName: (result['firstName'] as String?)?.trim() ?? '',
        lastName: (result['lastName'] as String?)?.trim() ?? '',
        email: result['email'] as String? ?? '',
        phone: result['phone'] as String? ?? '',
        avatarUrl: result['avatarUrl'] as String? ?? _authService.avatarUrl,
        totalOrders: (result['totalOrders'] as num?)?.toInt() ?? 0,
        totalSaved: (result['totalSaved'] as num?)?.toDouble() ?? 0.0,
      );

      await _authService.saveUserProfile(user.toJson());
      return user;
    } catch (e) {
      dev.log("[PROFILE] 🔴 API Error: $e");
      
      // Chỉ fallback nếu có cache, không thì để nó báo lỗi cho bác biết đường sửa Docker
      final cachedJson = _authService.getUserProfile();
      if (cachedJson != null) {
        dev.log("[PROFILE] 🟠 Using local cache fallback");
        return UserModel.fromJson(cachedJson);
      }
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    String? avatarUrl,
  }) async {
    await _apiClient.put(
      '/users/$userId',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
    );
  }
}
