/// Resultado de búsqueda en el catálogo de alimentos (`GET /foods/search`) —
/// lectura de red pura, sin persistencia local (ARCHITECTURE.md §4.6).
class Food {
  const Food({
    required this.id,
    required this.name,
    required this.category,
    required this.caloriesPer100g,
    required this.carbsPer100g,
    required this.proteinsPer100g,
    required this.fatsPer100g,
    this.fiberPer100g,
    this.sodiumPer100g,
  });

  final String id;
  final String name;
  final String category;
  final double caloriesPer100g;
  final double carbsPer100g;
  final double proteinsPer100g;
  final double fatsPer100g;
  final double? fiberPer100g;
  final double? sodiumPer100g;
}

/// Resultado de búsqueda por código de barras (`GET /food-lookup/barcode/{barcode}`),
/// proveniente de una fuente externa (OpenFoodFacts) — no tiene `id` propio del catálogo.
class ExternalFoodInfo {
  const ExternalFoodInfo({
    required this.barcode,
    required this.name,
    required this.caloriesPer100g,
    required this.carbsPer100g,
    this.brand,
    this.proteinsPer100g,
    this.fatsPer100g,
  });

  final String barcode;
  final String name;
  final String? brand;
  final double caloriesPer100g;
  final double carbsPer100g;
  final double? proteinsPer100g;
  final double? fatsPer100g;
}
