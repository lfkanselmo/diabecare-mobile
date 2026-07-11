import 'package:drift/drift.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/sync/sync_status.dart';

/// Acceso a la tabla `VitalSigns` — capa puramente de persistencia.
class VitalSignDao {
  VitalSignDao(this._db);

  final AppDatabase _db;

  Stream<List<VitalSignRow>> watchVitals({required DateTime from, required DateTime to}) {
    return (_db.select(_db.vitalSigns)
          ..where((t) => t.measuredAt.isBetweenValues(from, to))
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]))
        .watch();
  }

  Future<VitalSignRow?> getLatest() {
    return (_db.select(_db.vitalSigns)
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<VitalSignRow?> getById(String id) {
    return (_db.select(_db.vitalSigns)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<VitalSignRow>> getPending() {
    final pendingStatuses = [
      SyncStatus.pendingCreate.name,
      SyncStatus.pendingUpdate.name,
      SyncStatus.pendingDelete.name,
    ];
    return (_db.select(_db.vitalSigns)..where((t) => t.syncStatus.isIn(pendingStatuses))).get();
  }

  Future<void> upsert(VitalSignsCompanion row) {
    return _db.into(_db.vitalSigns).insertOnConflictUpdate(row);
  }

  Future<void> markSynced(String id, DateTime serverUpdatedAt) {
    return (_db.update(_db.vitalSigns)..where((t) => t.id.equals(id))).write(
      VitalSignsCompanion(
        syncStatus: Value(SyncStatus.synced.name),
        serverUpdatedAt: Value(serverUpdatedAt),
        syncErrorMessage: const Value(null),
      ),
    );
  }

  Future<void> markSyncError(String id, String message) {
    return (_db.update(_db.vitalSigns)..where((t) => t.id.equals(id))).write(
      VitalSignsCompanion(
        syncStatus: Value(SyncStatus.syncError.name),
        syncErrorMessage: Value(message),
      ),
    );
  }
}
