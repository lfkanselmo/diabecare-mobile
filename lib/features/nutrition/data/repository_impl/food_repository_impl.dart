import '../../domain/entities/food.dart';
import '../../domain/repositories/food_repository.dart';
import '../remote/food_api_client.dart';

class FoodRepositoryImpl implements FoodRepository {
  FoodRepositoryImpl(this._apiClient);

  final FoodApiClient _apiClient;

  @override
  Future<List<Food>> search(String query) async {
    final results = await _apiClient.search(query);
    return results
        .map(
          (dto) => Food(
            id: dto.foodId,
            name: dto.name,
            category: dto.category,
            caloriesPer100g: dto.caloriesPer100g,
            carbsPer100g: dto.carbsPer100g,
            proteinsPer100g: dto.proteinsPer100g,
            fatsPer100g: dto.fatsPer100g,
            fiberPer100g: dto.fiberPer100g,
            sodiumPer100g: dto.sodiumPer100g,
          ),
        )
        .toList();
  }

  @override
  Future<ExternalFoodInfo?> lookupByBarcode(String barcode) async {
    final dto = await _apiClient.lookupByBarcode(barcode);
    if (dto == null) return null;
    return ExternalFoodInfo(
      barcode: dto.barcode,
      name: dto.name,
      brand: dto.brand,
      caloriesPer100g: dto.caloriesPer100g,
      carbsPer100g: dto.carbsPer100g,
      proteinsPer100g: dto.proteinsPer100g,
      fatsPer100g: dto.fatsPer100g,
    );
  }
}
