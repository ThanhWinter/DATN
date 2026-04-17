import "package:core_network/core_network.dart";

class AuthRepository {
  AuthRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      "/admin/auth/login",
      body: {"email": email, "password": password},
    );

    final token = response["token"]?.toString();
    if (token == null || token.isEmpty) {
      throw Exception("Missing token from admin login response");
    }

    return token;
  }
}
