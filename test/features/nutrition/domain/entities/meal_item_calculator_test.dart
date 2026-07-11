import 'package:diabecare_mobile/features/nutrition/domain/entities/meal_item_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('escala calorías y carbohidratos por la cantidad ingresada, redondeando a 1 decimal', () {
    final item = MealItemCalculator.buildFromPer100g(
      id: 'i1',
      foodName: 'Arroz blanco cocido',
      quantityGrams: 150,
      caloriesPer100g: 130,
      carbsPer100g: 28.6,
    );

    expect(item.calories, 195.0);
    expect(item.carbohydrates, 42.9);
    expect(item.proteins, isNull);
    expect(item.fats, isNull);
  });

  test('escala proteínas y grasas cuando el alimento las informa', () {
    final item = MealItemCalculator.buildFromPer100g(
      id: 'i1',
      foodName: 'Pechuga de pollo',
      quantityGrams: 50,
      caloriesPer100g: 165,
      carbsPer100g: 0,
      proteinsPer100g: 31,
      fatsPer100g: 3.6,
    );

    expect(item.calories, 82.5);
    expect(item.proteins, 15.5);
    expect(item.fats, 1.8);
  });

  test('con 100g exactos, el valor escalado es igual al valor per100g', () {
    final item = MealItemCalculator.buildFromPer100g(
      id: 'i1',
      foodName: 'Manzana',
      quantityGrams: 100,
      caloriesPer100g: 52,
      carbsPer100g: 13.8,
    );

    expect(item.calories, 52.0);
    expect(item.carbohydrates, 13.8);
  });
}
