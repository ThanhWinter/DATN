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

  String get fullName => '$firstName $lastName';
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();
}
