import 'package:drift/drift.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/sync/sync_status.dart';

/// Acceso a la tabla `GlucoseReadings` — capa puramente de persistencia, sin
/// conocimiento de dominio (los mappers viven en `glucose_repository_impl.dart`).
class GlucoseDao {
  GlucoseDao(this._db);

  final AppDatabase _db;

  Stream<List<GlucoseReadingRow>> watchReadings({required DateTime from, required DateTime to}) {
    return (_db.select(_db.glucoseReadings)
          ..where((t) => t.measuredAt.isBetweenValues(from, to))
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]))
        .watch();
  }

  Future<GlucoseReadingRow?> getLatest() {
    return (_db.select(_db.glucoseReadings)
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<GlucoseReadingRow?> getById(String id) {
    return (_db.select(_db.glucoseReadings)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Excluye `syncError` a propósito: un error de validación real no debe
  /// reintentarse en cada ciclo de sync indefinidamente — queda inerte hasta
  /// que una pantalla dedicada (fuera de alcance de esta fase) lo reintente
  /// manualmente (ver ARCHITECTURE.md §4.3).
  Future<List<GlucoseReadingRow>> getPending() {
    final pendingStatuses = [
      SyncStatus.pendingCreate.name,
      SyncStatus.pendingUpdate.name,
      SyncStatus.pendingDelete.name,
    ];
    return (_db.select(_db.glucoseReadings)..where((t) => t.syncStatus.isIn(pendingStatuses))).get();
  }

  Future<void> upsert(GlucoseReadingsCompanion row) {
    return _db.into(_db.glucoseReadings).insertOnConflictUpdate(row);
  }

  Future<void> updateStatus(String id, String? status) {
    return (_db.update(_db.glucoseReadings)..where((t) => t.id.equals(id))).write(
      GlucoseReadingsCompanion(status: Value(status)),
    );
  }

  Future<void> markPendingDelete(String id) {
    return (_db.update(_db.glucoseReadings)..where((t) => t.id.equals(id))).write(
      GlucoseReadingsCompanion(
        syncStatus: Value(SyncStatus.pendingDelete.name),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markSynced(String id, DateTime serverUpdatedAt) {
    return (_db.update(_db.glucoseReadings)..where((t) => t.id.equals(id))).write(
      GlucoseReadingsCompanion(
        syncStatus: Value(SyncStatus.synced.name),
        serverUpdatedAt: Value(serverUpdatedAt),
        syncErrorMessage: const Value(null),
      ),
    );
  }

  Future<void> markSyncError(String id, String message) {
    return (_db.update(_db.glucoseReadings)..where((t) => t.id.equals(id))).write(
      GlucoseReadingsCompanion(
        syncStatus: Value(SyncStatus.syncError.name),
        syncErrorMessage: Value(message),
      ),
    );
  }

  Future<void> deleteById(String id) {
    return (_db.delete(_db.glucoseReadings)..where((t) => t.id.equals(id))).go();
  }
}
