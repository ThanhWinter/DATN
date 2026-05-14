import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

class ProfileAdminRepository {
  ProfileAdminRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<Map<String, dynamic>> getMyInfo() async {
    final res = await _apiClient.get('/users/my-info');
    return res['result'] as Map<String, dynamic>;
  }

  Future<void> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
  }) async {
    dev.log('[PROFILE_REPO] Updating profile userId=$userId');
    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (phone != null) body['phone'] = phone;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
    await _apiClient.put('/users/$userId', body: body);
    dev.log('[PROFILE_REPO] ✅ Profile updated');
  }

  /// Upload ảnh lên server, trả về URL để lưu vào avatarUrl.
  Future<String> uploadAvatar(List<int> bytes, String filename) async {
    dev.log('[PROFILE_REPO] Uploading avatar: $filename (${bytes.length} bytes)');
    final url = await _apiClient.uploadRaw(
      '/media/upload',
      (
        field: 'file',
        bytes: bytes,
        filename: filename,
        contentType: 'image/jpeg',
      ),
    );
    dev.log('[PROFILE_REPO] ✅ Avatar uploaded: $url');
    return url;
  }

  Future<void> changePassword({
    required String userId,
    required String newPassword,
  }) async {
    dev.log('[PROFILE_REPO] Changing password for userId=$userId');
    await _apiClient.put('/users/$userId', body: {'password': newPassword});
    dev.log('[PROFILE_REPO] ✅ Password changed');
  }
}
