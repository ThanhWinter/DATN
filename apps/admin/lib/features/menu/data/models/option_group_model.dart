class OptionItemModel {
  const OptionItemModel({
    required this.id,
    required this.name,
    required this.priceAdjustment,
  });

  final int id;
  final String name;
  final double priceAdjustment;

  factory OptionItemModel.fromJson(Map<String, dynamic> json) => OptionItemModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        priceAdjustment: (json['priceAdjustment'] as num).toDouble(),
      );
}

class OptionGroupModel {
  const OptionGroupModel({
    required this.id,
    required this.foodId,
    required this.name,
    required this.minSelect,
    required this.maxSelect,
    required this.items,
  });

  final int id;
  final int foodId;
  final String name;
  final int minSelect;
  final int maxSelect;
  final List<OptionItemModel> items;

  bool get isRequired => minSelect >= 1;
  bool get isMultiSelect => maxSelect > 1;

  factory OptionGroupModel.fromJson(Map<String, dynamic> json) => OptionGroupModel(
        id: (json['id'] as num).toInt(),
        foodId: (json['foodId'] as num).toInt(),
        name: json['name'] as String,
        minSelect: (json['minSelect'] as num? ?? 0).toInt(),
        maxSelect: (json['maxSelect'] as num? ?? 1).toInt(),
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => OptionItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
