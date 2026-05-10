class UserAddressModel {
  final int id;
  final String? label;
  final String fullAddress;
  final bool isDefault;

  const UserAddressModel({
    required this.id,
    this.label,
    required this.fullAddress,
    this.isDefault = false,
  });

  factory UserAddressModel.fromJson(Map<String, dynamic> json) =>
      UserAddressModel(
        id: (json['id'] as num).toInt(),
        label: json['label'] as String? ?? json['title'] as String?,
        fullAddress:
            json['fullAddress'] as String? ?? json['address'] as String? ?? '',
        isDefault: json['isDefault'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'title': label ?? '',
        'address': fullAddress,
        'latitude': 0.0,
        'longitude': 0.0,
      };

  UserAddressModel copyWith(
          {bool? isDefault, String? label, String? fullAddress}) =>
      UserAddressModel(
        id: id,
        label: label ?? this.label,
        fullAddress: fullAddress ?? this.fullAddress,
        isDefault: isDefault ?? this.isDefault,
      );
}
