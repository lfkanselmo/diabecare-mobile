// DTOs de red — mirror exacto de `FoodController`/`FoodLookupController`.

class FoodResponseDto {
  FoodResponseDto({
    required this.foodId,
    required this.name,
    required this.category,
    required this.caloriesPer100g,
    required this.carbsPer100g,
    required this.proteinsPer100g,
    required this.fatsPer100g,
    this.fiberPer100g,
    this.sodiumPer100g,
  });

  factory FoodResponseDto.fromJson(Map<String, dynamic> json) => FoodResponseDto(
    foodId: json['foodId'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    caloriesPer100g: (json['caloriesPer100g'] as num).toDouble(),
    carbsPer100g: (json['carbsPer100g'] as num).toDouble(),
    proteinsPer100g: (json['proteinsPer100g'] as num).toDouble(),
    fatsPer100g: (json['fatsPer100g'] as num).toDouble(),
    fiberPer100g: (json['fiberPer100g'] as num?)?.toDouble(),
    sodiumPer100g: (json['sodiumPer100g'] as num?)?.toDouble(),
  );

  final String foodId;
  final String name;
  final String category;
  final double caloriesPer100g;
  final double carbsPer100g;
  final double proteinsPer100g;
  final double fatsPer100g;
  final double? fiberPer100g;
  final double? sodiumPer100g;
}

class ExternalFoodResponseDto {
  ExternalFoodResponseDto({
    required this.barcode,
    required this.name,
    required this.caloriesPer100g,
    required this.carbsPer100g,
    this.brand,
    this.proteinsPer100g,
    this.fatsPer100g,
  });

  factory ExternalFoodResponseDto.fromJson(Map<String, dynamic> json) => ExternalFoodResponseDto(
    barcode: json['barcode'] as String,
    name: json['name'] as String,
    brand: json['brand'] as String?,
    caloriesPer100g: (json['caloriesPer100g'] as num).toDouble(),
    carbsPer100g: (json['carbsPer100g'] as num).toDouble(),
    proteinsPer100g: (json['proteinsPer100g'] as num?)?.toDouble(),
    fatsPer100g: (json['fatsPer100g'] as num?)?.toDouble(),
  );

  final String barcode;
  final String name;
  final String? brand;
  final double caloriesPer100g;
  final double carbsPer100g;
  final double? proteinsPer100g;
  final double? fatsPer100g;
}
