import 'meal_item.dart';

/// Auto-cálculo de macros por cantidad: `valor = round(per100g * qty/100, 1
/// decimal)`, editable a mano después de agregado (ver plan de Fase 2).
class MealItemCalculator {
  const MealItemCalculator._();

  static MealItem buildFromPer100g({
    required String id,
    required String foodName,
    required double quantityGrams,
    required double caloriesPer100g,
    required double carbsPer100g,
    double? proteinsPer100g,
    double? fatsPer100g,
    String? foodCode,
  }) {
    final factor = quantityGrams / 100;
    return MealItem(
      id: id,
      foodName: foodName,
      quantityGrams: quantityGrams,
      calories: _round1(caloriesPer100g * factor),
      carbohydrates: _round1(carbsPer100g * factor),
      proteins: proteinsPer100g == null ? null : _round1(proteinsPer100g * factor),
      fats: fatsPer100g == null ? null : _round1(fatsPer100g * factor),
      foodCode: foodCode,
    );
  }

  static double _round1(double value) => (value * 10).round() / 10;
}
