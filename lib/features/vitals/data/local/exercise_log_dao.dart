import 'package:drift/drift.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/sync/sync_status.dart';

class ExerciseLogDao {
  ExerciseLogDao(this._db);

  final AppDatabase _db;

  Stream<List<ExerciseLogRow>> watchLogs({required DateTime from, required DateTime to}) {
    return (_db.select(_db.exerciseLogs)
          ..where((t) => t.performedAt.isBetweenValues(from, to))
          ..orderBy([(t) => OrderingTerm.desc(t.performedAt)]))
        .watch();
  }

  Future<ExerciseLogRow?> getById(String id) {
    return (_db.select(_db.exerciseLogs)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<ExerciseLogRow>> getPending() {
    final pendingStatuses = [
      SyncStatus.pendingCreate.name,
      SyncStatus.pendingUpdate.name,
      SyncStatus.pendingDelete.name,
    ];
    return (_db.select(_db.exerciseLogs)..where((t) => t.syncStatus.isIn(pendingStatuses))).get();
  }

  Future<void> upsert(ExerciseLogsCompanion row) {
    return _db.into(_db.exerciseLogs).insertOnConflictUpdate(row);
  }

  Future<void> markSynced(String id, DateTime serverUpdatedAt) {
    return (_db.update(_db.exerciseLogs)..where((t) => t.id.equals(id))).write(
      ExerciseLogsCompanion(
        syncStatus: Value(SyncStatus.synced.name),
        serverUpdatedAt: Value(serverUpdatedAt),
        syncErrorMessage: const Value(null),
      ),
    );
  }

  Future<void> markSyncError(String id, String message) {
    return (_db.update(_db.exerciseLogs)..where((t) => t.id.equals(id))).write(
      ExerciseLogsCompanion(
        syncStatus: Value(SyncStatus.syncError.name),
        syncErrorMessage: Value(message),
      ),
    );
  }
}
