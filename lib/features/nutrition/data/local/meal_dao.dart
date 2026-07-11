import 'package:drift/drift.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/sync/sync_status.dart';

/// Acceso a la tabla `MealEntries` — capa puramente de persistencia, sin
/// conocimiento de dominio (los mappers viven en `meal_repository_impl.dart`).
class MealDao {
  MealDao(this._db);

  final AppDatabase _db;

  Stream<List<MealEntryRow>> watchMeals({required DateTime from, required DateTime to}) {
    return (_db.select(_db.mealEntries)
          ..where((t) => t.consumedAt.isBetweenValues(from, to))
          ..orderBy([(t) => OrderingTerm.desc(t.consumedAt)]))
        .watch();
  }

  Future<MealEntryRow?> getById(String id) {
    return (_db.select(_db.mealEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<MealEntryRow>> getPending() {
    final pendingStatuses = [
      SyncStatus.pendingCreate.name,
      SyncStatus.pendingUpdate.name,
      SyncStatus.pendingDelete.name,
    ];
    return (_db.select(_db.mealEntries)..where((t) => t.syncStatus.isIn(pendingStatuses))).get();
  }

  Future<void> upsert(MealEntriesCompanion row) {
    return _db.into(_db.mealEntries).insertOnConflictUpdate(row);
  }

  Future<void> markSynced(String id, DateTime serverUpdatedAt) {
    return (_db.update(_db.mealEntries)..where((t) => t.id.equals(id))).write(
      MealEntriesCompanion(
        syncStatus: Value(SyncStatus.synced.name),
        serverUpdatedAt: Value(serverUpdatedAt),
        syncErrorMessage: const Value(null),
      ),
    );
  }

  Future<void> markSyncError(String id, String message) {
    return (_db.update(_db.mealEntries)..where((t) => t.id.equals(id))).write(
      MealEntriesCompanion(
        syncStatus: Value(SyncStatus.syncError.name),
        syncErrorMessage: Value(message),
      ),
    );
  }
}
