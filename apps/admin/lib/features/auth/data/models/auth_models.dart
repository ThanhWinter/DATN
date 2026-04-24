class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final bool authenticated;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.authenticated,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      authenticated: json['authenticated'] ?? false,
    );
  }
}
