import 'package:core_network/core_network.dart';

import '../../../../app/services/auth_service.dart';
import '../models/profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._apiClient, this._authService);

  final IApiClient _apiClient;
  final AuthService _authService;

  Future<UserModel> fetchUser() async {
    final response = await _apiClient.get('/users/my-info');
    final result = response['result'] as Map<String, dynamic>;

    return UserModel(
      id: _authService.getUserId() ?? '',
      firstName: (result['firstName'] as String?)?.trim() ?? '',
      lastName: (result['lastName'] as String?)?.trim() ?? '',
      email: result['email'] as String? ?? '',
      phone: result['phone'] as String? ?? '',
      avatarUrl: _authService.avatarUrl,
    );
  }

  Future<void> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    await _apiClient.put(
      '/users/$userId',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      },
    );
  }
}
