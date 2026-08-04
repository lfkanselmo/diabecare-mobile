import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/sync/sync_status.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/bmi_category.dart';
import '../../domain/entities/hba1c_trend_point.dart';
import '../../domain/entities/vital_sign.dart';
import '../../domain/repositories/vital_sign_repository.dart';
import '../local/vital_sign_dao.dart';
import '../remote/vital_sign_api_client.dart';
import '../remote/vital_sign_dtos.dart';

class VitalSignRepositoryImpl implements VitalSignRepository, SyncableRepository<VitalSign> {
  VitalSignRepositoryImpl({
    required VitalSignDao dao,
    required VitalSignApiClient apiClient,
    required AuthRepository authRepository,
    required AppDatabase database,
    Uuid? uuid,
  }) : _dao = dao,
       _apiClient = apiClient,
       _authRepository = authRepository,
       _database = database,
       _uuid = uuid ?? const Uuid();

  final VitalSignDao _dao;
  final VitalSignApiClient _apiClient;
  final AuthRepository _authRepository;
  final AppDatabase _database;
  final Uuid _uuid;

  static const _resourceName = 'vitals';

  @override
  String get resourceName => _resourceName;

  @override
  Stream<List<VitalSign>> watchVitals({required DateTime from, required DateTime to}) {
    return _dao.watchVitals(from: from, to: to).map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<VitalSign?> getLatest() async {
    final row = await _dao.getLatest();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<VitalSign> register({
    double? weightKg,
    double? heightCm,
    int? systolicBp,
    int? diastolicBp,
    int? heartRate,
    double? hba1c,
    required DateTime measuredAt,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _dao.upsert(
      VitalSignsCompanion.insert(
        id: id,
        weightKg: Value(weightKg),
        heightCm: Value(heightCm),
        systolicBp: Value(systolicBp),
        diastolicBp: Value(diastolicBp),
        heartRate: Value(heartRate),
        hba1c: Value(hba1c),
        measuredAt: measuredAt,
        notes: Value(notes),
        syncStatus: SyncStatus.pendingCreate.name,
        localUpdatedAt: now,
      ),
    );
    final row = await _dao.getById(id);
    return _toDomain(row!);
  }

  @override
  Future<List<Hba1cTrendPoint>> getHba1cTrend({int months = 6}) async {
    final patientId = await _requirePatientId();
    final points = await _apiClient.getHba1cTrend(patientId: patientId, months: months);
    return points
        .map(
          (p) => Hba1cTrendPoint(
            month: p.month,
            estimatedHba1c: p.estimatedHba1c,
            averageGlucose: p.averageGlucose,
            totalReadings: p.totalReadings,
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
    final remoteVitals = await _apiClient.sync(patientId: patientId, since: since);

    for (final dto in remoteVitals) {
      await _dao.upsert(_companionFromDto(dto, SyncStatus.synced));
    }

    await _database
        .into(_database.syncCursors)
        .insertOnConflictUpdate(SyncCursorsCompanion.insert(resource: _resourceName, lastSyncedAt: DateTime.now()));
  }

  @override
  Future<List<PendingChange<VitalSign>>> getPending() async {
    final rows = await _dao.getPending();
    return rows.map((row) {
      final status = SyncStatus.values.firstWhere((s) => s.name == row.syncStatus);
      return PendingChange<VitalSign>(id: row.id, status: status, payload: _toDomain(row));
    }).toList();
  }

  @override
  Future<void> pushCreate(VitalSign payload) async {
    final patientId = await _requirePatientId();
    final dto = await _apiClient.register(
      patientId: patientId,
      weightKg: payload.weightKg,
      heightCm: payload.heightCm,
      systolicBp: payload.systolicBp,
      diastolicBp: payload.diastolicBp,
      heartRate: payload.heartRate,
      hba1c: payload.hba1c,
      measuredAt: payload.measuredAt,
      notes: payload.notes,
      vitalId: payload.id,
    );
    await _dao.upsert(_companionFromDto(dto, SyncStatus.pendingCreate));
  }

  @override
  Future<void> pushUpdate(VitalSign payload) {
    throw UnimplementedError('No existe edición de signos vitales todavía');
  }

  @override
  Future<void> pushDelete(String id) {
    throw UnimplementedError('No existe borrado de signos vitales todavía');
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

  VitalSignsCompanion _companionFromDto(VitalSignResponseDto dto, SyncStatus syncStatus) {
    return VitalSignsCompanion.insert(
      id: dto.vitalId,
      weightKg: Value(dto.weightKg),
      heightCm: Value(dto.heightCm),
      systolicBp: Value(dto.systolicBp),
      diastolicBp: Value(dto.diastolicBp),
      heartRate: Value(dto.heartRate),
      hba1c: Value(dto.hba1c),
      measuredAt: dto.measuredAt,
      notes: Value(dto.notes),
      bmi: Value(dto.bmi),
      bmiCategory: Value(dto.bmiCategory),
      syncStatus: syncStatus.name,
      localUpdatedAt: DateTime.now(),
      serverUpdatedAt: Value(dto.updatedAt),
    );
  }

  VitalSign _toDomain(VitalSignRow row) {
    return VitalSign(
      id: row.id,
      weightKg: row.weightKg,
      heightCm: row.heightCm,
      systolicBp: row.systolicBp,
      diastolicBp: row.diastolicBp,
      heartRate: row.heartRate,
      hba1c: row.hba1c,
      measuredAt: row.measuredAt,
      notes: row.notes,
      bmi: row.bmi,
      bmiCategory: row.bmiCategory == null ? null : BmiCategory.fromWire(row.bmiCategory!),
      syncStatus: SyncStatus.values.firstWhere((s) => s.name == row.syncStatus),
      updatedAt: row.serverUpdatedAt,
    );
  }
}
