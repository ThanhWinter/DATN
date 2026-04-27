class OptionItemModel {
  final int id;
  final String name;
  final double priceAdjustment;

  const OptionItemModel({
    required this.id,
    required this.name,
    required this.priceAdjustment,
  });

  factory OptionItemModel.fromJson(Map<String, dynamic> json) {
    return OptionItemModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      priceAdjustment: (json['priceAdjustment'] as num).toDouble(),
    );
  }
}

class OptionGroupModel {
  final int id;
  final String name;
  final int minSelect;
  final int maxSelect;
  final List<OptionItemModel> items;

  const OptionGroupModel({
    required this.id,
    required this.name,
    required this.minSelect,
    required this.maxSelect,
    required this.items,
  });

  bool get isRequired => minSelect > 0;
  bool get isMultiSelect => maxSelect > 1;

  factory OptionGroupModel.fromJson(Map<String, dynamic> json) {
    return OptionGroupModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      minSelect: (json['minSelect'] as num?)?.toInt() ?? 0,
      maxSelect: (json['maxSelect'] as num?)?.toInt() ?? 1,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OptionItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
