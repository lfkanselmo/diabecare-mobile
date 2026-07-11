class MealItem {
  const MealItem({
    required this.id,
    required this.foodName,
    required this.quantityGrams,
    required this.calories,
    required this.carbohydrates,
    this.proteins,
    this.fats,
    this.foodCode,
  });

  final String id;
  final String foodName;
  final double quantityGrams;
  final double calories;
  final double carbohydrates;
  final double? proteins;
  final double? fats;
  final String? foodCode;

  Map<String, dynamic> toJson() => {
    'id': id,
    'foodName': foodName,
    'quantityGrams': quantityGrams,
    'calories': calories,
    'carbohydrates': carbohydrates,
    'proteins': proteins,
    'fats': fats,
    'foodCode': foodCode,
  };

  factory MealItem.fromJson(Map<String, dynamic> json) => MealItem(
    id: json['id'] as String,
    foodName: json['foodName'] as String,
    quantityGrams: (json['quantityGrams'] as num).toDouble(),
    calories: (json['calories'] as num).toDouble(),
    carbohydrates: (json['carbohydrates'] as num).toDouble(),
    proteins: (json['proteins'] as num?)?.toDouble(),
    fats: (json['fats'] as num?)?.toDouble(),
    foodCode: json['foodCode'] as String?,
  );
}
