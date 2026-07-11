import '../../../../core/sync/sync_status.dart';
import 'meal_item.dart';
import 'meal_type.dart';

/// `totalCalories`/etc son calculados por el servidor a partir de `items` —
/// nulos hasta que la comida se sincroniza (offline-first, igual que
/// `status`/`updatedAt` en `GlucoseReading`).
class MealEntry {
  const MealEntry({
    required this.id,
    required this.mealType,
    required this.consumedAt,
    required this.items,
    required this.syncStatus,
    this.notes,
    this.totalCalories,
    this.totalCarbohydrates,
    this.totalProteins,
    this.totalFats,
    this.updatedAt,
  });

  final String id;
  final MealType mealType;
  final DateTime consumedAt;
  final List<MealItem> items;
  final SyncStatus syncStatus;
  final String? notes;
  final double? totalCalories;
  final double? totalCarbohydrates;
  final double? totalProteins;
  final double? totalFats;
  final DateTime? updatedAt;
}
