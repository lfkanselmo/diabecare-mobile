import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/sync/sync_status.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/glucose_reading.dart';
import '../../domain/entities/glucose_stats.dart';
import '../../domain/entities/glucose_status.dart';
import '../../domain/entities/glucose_unit.dart';
import '../../domain/entities/reading_type.dart';
import '../../domain/repositories/glucose_repository.dart';
import '../local/glucose_dao.dart';
import '../remote/glucose_api_client.dart';

class GlucoseRepositoryImpl implements GlucoseRepository, SyncableRepository<GlucoseReading> {
  GlucoseRepositoryImpl({
    required GlucoseDao dao,
    required GlucoseApiClient apiClient,
    required AuthRepository authRepository,
    required AppDatabase database,
    Uuid? uuid,
  }) : _dao = dao,
       _apiClient = apiClient,
       _authRepository = authRepository,
       _database = database,
       _uuid = uuid ?? const Uuid();

  final GlucoseDao _dao;
  final GlucoseApiClient _apiClient;
  final AuthRepository _authRepository;
  final AppDatabase _database;
  final Uuid _uuid;

  static const _resourceName = 'glucose';

  @override
  String get resourceName => _resourceName;

  @override
  Stream<List<GlucoseReading>> watchReadings({required DateTime from, required DateTime to}) {
    return _dao.watchReadings(from: from, to: to).map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<GlucoseReading?> getLatest() async {
    final row = await _dao.getLatest();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<GlucoseReading> register({
    required double value,
    required GlucoseUnit unit,
    required ReadingType readingType,
    required DateTime measuredAt,
    String? notes,
    String? deviceSource,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _dao.upsert(
      GlucoseReadingsCompanion.insert(
        id: id,
        value: value,
        unit: unit.wireValue,
        readingType: readingType.wireValue,
        measuredAt: measuredAt,
        notes: Value(notes),
        deviceSource: Value(deviceSource),
        syncStatus: SyncStatus.pendingCreate.name,
        localUpdatedAt: now,
      ),
    );
    final row = await _dao.getById(id);
    return _toDomain(row!);
  }

  @override
  Future<void> delete(String id) async {
    final row = await _dao.getById(id);
    if (row == null) return;
    if (row.syncStatus == SyncStatus.pendingCreate.name) {
      // Nunca llegó a existir en el servidor — se borra directo, sin encolar nada.
      await _dao.deleteById(id);
    } else {
      await _dao.markPendingDelete(id);
    }
  }

  @override
  Future<GlucoseStats> getStats({required DateTime from, required DateTime to}) async {
    final patientId = await _requirePatientId();
    final dto = await _apiClient.getStats(patientId: patientId, from: from, to: to);
    return GlucoseStats(
      average: dto.average,
      standardDeviation: dto.standardDeviation,
      coefficientOfVariation: dto.coefficientOfVariation,
      estimatedHba1c: dto.estimatedHba1c,
      timeInRangePercent: dto.timeInRangePercent,
      timeBelowRangePercent: dto.timeBelowRangePercent,
      timeAboveRangePercent: dto.timeAboveRangePercent,
      totalReadings: dto.totalReadings,
    );
  }

  @override
  Future<List<AgpBucket>> getAgpProfile({required DateTime from, required DateTime to}) async {
    final patientId = await _requirePatientId();
    final buckets = await _apiClient.getAgpProfile(patientId: patientId, from: from, to: to);
    return buckets
        .map(
          (b) => AgpBucket(
            hour: b.hour,
            readingCount: b.readingCount,
            p10: b.p10,
            p25: b.p25,
            median: b.median,
            p75: b.p75,
            p90: b.p90,
          ),
        )
        .toList();
  }

  @override
  Future<void> pullChanges() async {
    final patientId = await _requirePatientId();
    final cursorRow = await (_database.select(
      _database.syncCursors,
    )..where((t) => t.resource.equals(_resourceName))).getSingleOrNull();

    final since = cursorRow?.lastSyncedAt;
    final remoteReadings = await _apiClient.sync(patientId: patientId, since: since);

    for (final dto in remoteReadings) {
      await _dao.upsert(
        GlucoseReadingsCompanion.insert(
          id: dto.readingId,
          value: dto.value,
          unit: dto.unit,
          readingType: dto.readingType,
          status: Value(dto.status),
          measuredAt: dto.measuredAt,
          notes: Value(dto.notes),
          deviceSource: Value(dto.deviceSource),
          syncStatus: SyncStatus.synced.name,
          localUpdatedAt: DateTime.now(),
          serverUpdatedAt: Value(dto.updatedAt),
        ),
      );
    }

    // El cursor solo avanza si el batch completo se procesó sin lanzar —
    // si algo falla a mitad de camino, el próximo intento vuelve a pedir
    // desde el mismo `since` (idempotente por upsert).
    await _database
        .into(_database.syncCursors)
        .insertOnConflictUpdate(SyncCursorsCompanion.insert(resource: _resourceName, lastSyncedAt: DateTime.now()));
  }

  // ── SyncableRepository<GlucoseReading> ──

  @override
  Future<List<PendingChange<GlucoseReading>>> getPending() async {
    final rows = await _dao.getPending();
    return rows.map((row) {
      final status = SyncStatus.values.firstWhere((s) => s.name == row.syncStatus);
      return PendingChange<GlucoseReading>(id: row.id, status: status, payload: _toDomain(row));
    }).toList();
  }

  @override
  Future<void> pushCreate(GlucoseReading payload) async {
    final patientId = await _requirePatientId();
    final dto = await _apiClient.register(
      patientId: patientId,
      value: payload.value,
      unit: payload.unit.wireValue,
      readingType: payload.readingType.wireValue,
      measuredAt: payload.measuredAt,
      notes: payload.notes,
      deviceSource: payload.deviceSource,
      readingId: payload.id,
    );
    await _dao.updateStatus(payload.id, dto.status);
  }

  @override
  Future<void> pushUpdate(GlucoseReading payload) {
    // No hay endpoint de edición de lecturas todavía (ni en el backend ni en
    // el roadmap mobile) — ningún camino de la app marca `pendingUpdate`.
    throw UnimplementedError('No existe edición de lecturas de glucosa todavía');
  }

  @override
  Future<void> pushDelete(String id) async {
    final patientId = await _requirePatientId();
    await _apiClient.delete(patientId: patientId, readingId: id);
  }

  @override
  Future<void> markSynced(String id, DateTime serverUpdatedAt) async {
    final row = await _dao.getById(id);
    if (row == null) return;
    if (row.syncStatus == SyncStatus.pendingDelete.name) {
      await _dao.deleteById(id);
    } else {
      await _dao.markSynced(id, serverUpdatedAt);
    }
  }

  @override
  Future<void> markSyncError(String id, String message) => _dao.markSyncError(id, message);

  // ── Helpers ──

  Future<String> _requirePatientId() async {
    final session = await _authRepository.loadSession();
    final patientId = session?.patient?.patientId;
    if (patientId == null) {
      throw StateError('No hay un paciente asociado a la sesión actual');
    }
    return patientId;
  }

  GlucoseReading _toDomain(GlucoseReadingRow row) {
    return GlucoseReading(
      id: row.id,
      value: row.value,
      unit: GlucoseUnit.fromWire(row.unit),
      readingType: ReadingType.fromWire(row.readingType),
      status: row.status == null ? null : GlucoseStatus.fromWire(row.status!),
      measuredAt: row.measuredAt,
      syncStatus: SyncStatus.values.firstWhere((s) => s.name == row.syncStatus),
      notes: row.notes,
      deviceSource: row.deviceSource,
      updatedAt: row.serverUpdatedAt,
    );
  }
}
