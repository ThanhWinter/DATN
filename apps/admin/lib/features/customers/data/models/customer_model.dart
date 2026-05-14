import 'package:core_utils/core_utils.dart';

class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.createdAt,
    this.gender = 0,
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.roles = const [],
    this.isActive = true,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime createdAt;
  final int gender;
  final int totalOrders;
  final double totalSpent;
  final List<String> roles;
  final bool isActive;

  bool get isAdmin => roles.contains('ADMIN');
  bool get isLocked => !isActive;

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id']?.toString() ?? json['email'] as String,
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        email: json['email'] as String,
        phone: json['phone'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? parseApiDateTime(json['createdAt'])
            : DateTime.now(),
        gender: (json['gender'] as num?)?.toInt() ?? 0,
        totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
        totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0,
        roles: (json['roles'] as List<dynamic>? ?? []).cast<String>(),
        isActive: (json['isActive'] as bool?) ?? true,
      );
}
