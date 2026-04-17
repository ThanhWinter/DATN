import "package:get/get.dart";

import "../../data/repositories/auth_repository.dart";

class AuthController extends GetxController {
  AuthController(this._repository);

  final AuthRepository _repository;

  final isLoading = false.obs;
  final errorMessage = "".obs;
  final token = "".obs;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      token.value = await _repository.login(email: email, password: password);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
