import '../entities/daily_summary.dart';
import '../entities/meal_entry.dart';
import '../entities/meal_item.dart';
import '../entities/meal_type.dart';

/// `watchMeals` lee siempre de la caché local (Drift) — nunca directo de red
/// (igual patrón que `GlucoseRepository`). `getDailySummary` es una agregación
/// que solo el servidor puede calcular — red-first, sin contraparte local.
abstract interface class MealRepository {
  Stream<List<MealEntry>> watchMeals({required DateTime from, required DateTime to});

  /// Genera el ID localmente (comida + cada item), inserta con `pendingCreate`
  /// y encola el envío al backend.
  Future<MealEntry> register({
    required MealType mealType,
    required DateTime consumedAt,
    required List<MealItem> items,
    String? notes,
  });

  Future<DailySummary> getDailySummary(DateTime date);

  /// Trae del backend todo lo creado/modificado desde el último cursor
  /// (`/meals/sync?since=`) y hace upsert local.
  Future<void> pullChanges();
}
