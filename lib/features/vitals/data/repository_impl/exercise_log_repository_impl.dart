import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/sync/sync_status.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/exercise_intensity.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/exercise_type.dart';
import '../../domain/repositories/exercise_log_repository.dart';
import '../local/exercise_log_dao.dart';
import '../remote/exercise_log_api_client.dart';
import '../remote/exercise_log_dtos.dart';

class ExerciseLogRepositoryImpl implements ExerciseLogRepository, SyncableRepository<ExerciseLog> {
  ExerciseLogRepositoryImpl({
    required ExerciseLogDao dao,
    required ExerciseLogApiClient apiClient,
    required AuthRepository authRepository,
    required AppDatabase database,
    Uuid? uuid,
  }) : _dao = dao,
       _apiClient = apiClient,
       _authRepository = authRepository,
       _database = database,
       _uuid = uuid ?? const Uuid();

  final ExerciseLogDao _dao;
  final ExerciseLogApiClient _apiClient;
  final AuthRepository _authRepository;
  final AppDatabase _database;
  final Uuid _uuid;

  static const _resourceName = 'exercise';

  @override
  String get resourceName => _resourceName;

  @override
  Stream<List<ExerciseLog>> watchLogs({required DateTime from, required DateTime to}) {
    return _dao.watchLogs(from: from, to: to).map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<ExerciseLog> register({
    required ExerciseType exerciseType,
    required ExerciseIntensity intensity,
    required int durationMinutes,
    required DateTime performedAt,
    String? notes,
    double? caloriesBurnedOverride,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _dao.upsert(
      ExerciseLogsCompanion.insert(
        id: id,
        exerciseType: exerciseType.wireValue,
        intensity: intensity.wireValue,
        durationMinutes: durationMinutes,
        caloriesBurned: Value(caloriesBurnedOverride),
        notes: Value(notes),
        performedAt: performedAt,
        syncStatus: SyncStatus.pendingCreate.name,
        localUpdatedAt: now,
      ),
    );
    final row = await _dao.getById(id);
    return _toDomain(row!);
  }

  @override
  Future<void> pullChanges() async {
    final patientId = await _requirePatientId();
    final cursorRow = await (_database.select(
      _database.syncCursors,
    )..where((t) => t.resource.equals(_resourceName))).getSingleOrNull();

    final since = cursorRow?.lastSyncedAt;
    final remoteLogs = await _apiClient.sync(patientId: patientId, since: since);

    for (final dto in remoteLogs) {
      await _dao.upsert(_companionFromDto(dto, SyncStatus.synced));
    }

    await _database
        .into(_database.syncCursors)
        .insertOnConflictUpdate(SyncCursorsCompanion.insert(resource: _resourceName, lastSyncedAt: DateTime.now()));
  }

  @override
  Future<List<PendingChange<ExerciseLog>>> getPending() async {
    final rows = await _dao.getPending();
    return rows.map((row) {
      final status = SyncStatus.values.firstWhere((s) => s.name == row.syncStatus);
      return PendingChange<ExerciseLog>(id: row.id, status: status, payload: _toDomain(row));
    }).toList();
  }

  @override
  Future<void> pushCreate(ExerciseLog payload) async {
    final patientId = await _requirePatientId();
    final dto = await _apiClient.register(
      patientId: patientId,
      exerciseType: payload.exerciseType.wireValue,
      intensity: payload.intensity.wireValue,
      durationMinutes: payload.durationMinutes,
      performedAt: payload.performedAt,
      notes: payload.notes,
      caloriesBurned: payload.caloriesBurned,
      exerciseId: payload.id,
    );
    await _dao.upsert(_companionFromDto(dto, SyncStatus.pendingCreate));
  }

  @override
  Future<void> pushUpdate(ExerciseLog payload) {
    throw UnimplementedError('No existe edición de ejercicio todavía');
  }

  @override
  Future<void> pushDelete(String id) {
    throw UnimplementedError('No existe borrado de ejercicio todavía');
  }

  @override
  Future<void> markSynced(String id, DateTime serverUpdatedAt) => _dao.markSynced(id, serverUpdatedAt);

  @override
  Future<void> markSyncError(String id, String message) => _dao.markSyncError(id, message);

  Future<String> _requirePatientId() async {
    final session = await _authRepository.loadSession();
    final patientId = session?.patient?.patientId;
    if (patientId == null) {
      throw StateError('No hay un paciente asociado a la sesión actual');
    }
    return patientId;
  }

  ExerciseLogsCompanion _companionFromDto(ExerciseLogResponseDto dto, SyncStatus syncStatus) {
    return ExerciseLogsCompanion.insert(
      id: dto.exerciseId,
      exerciseType: dto.exerciseType,
      intensity: dto.intensity,
      durationMinutes: dto.durationMinutes,
      caloriesBurned: Value(dto.caloriesBurned),
      notes: Value(dto.notes),
      performedAt: DateTime.parse(dto.performedAt),
      syncStatus: syncStatus.name,
      localUpdatedAt: DateTime.now(),
      serverUpdatedAt: Value(dto.updatedAt),
    );
  }

  ExerciseLog _toDomain(ExerciseLogRow row) {
    return ExerciseLog(
      id: row.id,
      exerciseType: ExerciseType.fromWire(row.exerciseType),
      intensity: ExerciseIntensity.fromWire(row.intensity),
      durationMinutes: row.durationMinutes,
      caloriesBurned: row.caloriesBurned,
      notes: row.notes,
      performedAt: row.performedAt,
      syncStatus: SyncStatus.values.firstWhere((s) => s.name == row.syncStatus),
      updatedAt: row.serverUpdatedAt,
    );
  }
}
