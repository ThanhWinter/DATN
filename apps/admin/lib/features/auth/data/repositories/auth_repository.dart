class AuthRepository {
  Future<String> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: mock data
    if (email.isNotEmpty && password.isNotEmpty) {
      return 'mock_admin_token_${DateTime.now().millisecondsSinceEpoch}';
    }
    throw Exception('Email hoặc mật khẩu không đúng');
  }
}
