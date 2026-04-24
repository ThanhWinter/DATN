import 'package:core_network/core_network.dart';

import '../models/profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<UserModel> fetchUser() async {
    final response = await _apiClient.get("/users/my-info");
    final result = response["result"] as Map<String, dynamic>;

    final firstName = (result["firstName"] as String?)?.trim() ?? '';
    final lastName = (result["lastName"] as String?)?.trim() ?? '';
    final fullName = '$lastName $firstName'.trim();

    return UserModel(
      id: result["id"] as String? ?? '',
      fullName: fullName.isEmpty ? 'Người dùng' : fullName,
      email: result["email"] as String? ?? '',
      phone: result["phone"] as String? ?? '',
    );
  }
}
