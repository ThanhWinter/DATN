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

class UserResponse {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String? dob;

  UserResponse({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.dob,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      dob: _parseDob(json['dob']),
    );
  }

  // LocalDate từ backend có thể về dạng "2000-01-15" (string) hoặc [2000,1,15] (array)
  static String? _parseDob(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List && value.length >= 3) {
      final y = value[0];
      final m = value[1].toString().padLeft(2, '0');
      final d = value[2].toString().padLeft(2, '0');
      return '$y-$m-$d';
    }
    return null;
  }
}
