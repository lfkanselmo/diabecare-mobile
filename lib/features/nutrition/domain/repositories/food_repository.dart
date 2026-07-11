import '../entities/food.dart';

/// Lecturas de red puras, sin persistencia local (ARCHITECTURE.md §4.6).
abstract interface class FoodRepository {
  Future<List<Food>> search(String query);

  Future<ExternalFoodInfo?> lookupByBarcode(String barcode);
}
