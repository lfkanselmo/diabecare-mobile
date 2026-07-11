import 'package:drift/drift.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/sync/sync_status.dart';

/// Acceso a la tabla `Medications` — capa puramente de persistencia.
class MedicationDao {
  MedicationDao(this._db);

  final AppDatabase _db;

  Stream<List<MedicationRow>> watchActive() {
    return (_db.select(_db.medications)
          ..where((t) => t.active.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<MedicationRow?> getById(String id) {
    return (_db.select(_db.medications)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<MedicationRow>> getPending() {
    final pendingStatuses = [
      SyncStatus.pendingCreate.name,
      SyncStatus.pendingUpdate.name,
      SyncStatus.pendingDelete.name,
    ];
    return (_db.select(_db.medications)..where((t) => t.syncStatus.isIn(pendingStatuses))).get();
  }

  Future<void> upsert(MedicationsCompanion row) {
    return _db.into(_db.medications).insertOnConflictUpdate(row);
  }

  Future<void> markPendingUpdate(String id, {required bool active}) {
    return (_db.update(_db.medications)..where((t) => t.id.equals(id))).write(
      MedicationsCompanion(
        active: Value(active),
        syncStatus: Value(SyncStatus.pendingUpdate.name),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markSynced(String id, DateTime serverUpdatedAt) {
    return (_db.update(_db.medications)..where((t) => t.id.equals(id))).write(
      MedicationsCompanion(
        syncStatus: Value(SyncStatus.synced.name),
        serverUpdatedAt: Value(serverUpdatedAt),
        syncErrorMessage: const Value(null),
      ),
    );
  }

  Future<void> markSyncError(String id, String message) {
    return (_db.update(_db.medications)..where((t) => t.id.equals(id))).write(
      MedicationsCompanion(
        syncStatus: Value(SyncStatus.syncError.name),
        syncErrorMessage: Value(message),
      ),
    );
  }
}
