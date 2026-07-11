// DTOs de red — mirror exacto de los DTOs de `diabecare-api`
// (`NutritionController`), nombres de campo tal cual.

class MealItemDto {
  MealItemDto({
    required this.foodName,
    required this.quantityGrams,
    required this.calories,
    required this.carbohydrates,
    this.proteins,
    this.fats,
    this.foodCode,
    this.mealItemId,
  });

  final String foodName;
  final double quantityGrams;
  final double calories;
  final double carbohydrates;
  final double? proteins;
  final double? fats;
  final String? foodCode;
  final String? mealItemId;

  Map<String, dynamic> toJson() => {
    'foodName': foodName,
    'quantityGrams': quantityGrams,
    'calories': calories,
    'carbohydrates': carbohydrates,
    'proteins': ?proteins,
    'fats': ?fats,
    'foodCode': ?foodCode,
    'mealItemId': ?mealItemId,
  };
}

class MealItemResponseDto {
  MealItemResponseDto({
    required this.mealItemId,
    required this.foodName,
    required this.quantityGrams,
    required this.calories,
    required this.carbohydrates,
    this.proteins,
    this.fats,
  });

  factory MealItemResponseDto.fromJson(Map<String, dynamic> json) => MealItemResponseDto(
    mealItemId: json['mealItemId'] as String,
    foodName: json['foodName'] as String,
    quantityGrams: (json['quantityGrams'] as num).toDouble(),
    calories: (json['calories'] as num).toDouble(),
    carbohydrates: (json['carbohydrates'] as num).toDouble(),
    proteins: (json['proteins'] as num?)?.toDouble(),
    fats: (json['fats'] as num?)?.toDouble(),
  );

  final String mealItemId;
  final String foodName;
  final double quantityGrams;
  final double calories;
  final double carbohydrates;
  final double? proteins;
  final double? fats;
}

class MealEntryResponseDto {
  MealEntryResponseDto({
    required this.mealId,
    required this.mealType,
    required this.consumedAt,
    required this.items,
    this.notes,
    this.totalCalories,
    this.totalCarbohydrates,
    this.totalProteins,
    this.totalFats,
    this.updatedAt,
  });

  factory MealEntryResponseDto.fromJson(Map<String, dynamic> json) => MealEntryResponseDto(
    mealId: json['mealId'] as String,
    mealType: json['mealType'] as String,
    consumedAt: DateTime.parse(json['consumedAt'] as String),
    notes: json['notes'] as String?,
    totalCalories: (json['totalCalories'] as num?)?.toDouble(),
    totalCarbohydrates: (json['totalCarbohydrates'] as num?)?.toDouble(),
    totalProteins: (json['totalProteins'] as num?)?.toDouble(),
    totalFats: (json['totalFats'] as num?)?.toDouble(),
    items: (json['items'] as List<dynamic>)
        .map((e) => MealItemResponseDto.fromJson(e as Map<String, dynamic>))
        .toList(),
    updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
  );

  final String mealId;
  final String mealType;
  final DateTime consumedAt;
  final String? notes;
  final double? totalCalories;
  final double? totalCarbohydrates;
  final double? totalProteins;
  final double? totalFats;
  final List<MealItemResponseDto> items;
  final DateTime? updatedAt;
}

class DailySummaryResponseDto {
  DailySummaryResponseDto({
    required this.date,
    required this.totalCalories,
    required this.totalCarbohydrates,
    required this.totalProteins,
    required this.totalFats,
    required this.goalReached,
    this.calorieGoal,
  });

  factory DailySummaryResponseDto.fromJson(Map<String, dynamic> json) => DailySummaryResponseDto(
    date: DateTime.parse(json['date'] as String),
    totalCalories: (json['totalCalories'] as num).toDouble(),
    totalCarbohydrates: (json['totalCarbohydrates'] as num).toDouble(),
    totalProteins: (json['totalProteins'] as num).toDouble(),
    totalFats: (json['totalFats'] as num).toDouble(),
    calorieGoal: json['calorieGoal'] as int?,
    goalReached: json['goalReached'] as bool,
  );

  final DateTime date;
  final double totalCalories;
  final double totalCarbohydrates;
  final double totalProteins;
  final double totalFats;
  final int? calorieGoal;
  final bool goalReached;
}
