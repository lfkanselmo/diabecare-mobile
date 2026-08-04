import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/sync/sync_status.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../../auth/domain/entities/patient.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/dose_unit.dart';
import '../../domain/entities/insulin_calculation_result.dart';
import '../../domain/entities/medication.dart';
import '../../domain/entities/medication_frequency.dart';
import '../../domain/entities/medication_type.dart';
import '../../domain/repositories/medication_repository.dart';
import '../local/medication_dao.dart';
import '../remote/medication_api_client.dart';
import '../remote/medication_dtos.dart';

class MedicationRepositoryImpl implements MedicationRepository, SyncableRepository<Medication> {
  MedicationRepositoryImpl({
    required MedicationDao dao,
    required MedicationApiClient apiClient,
    required AuthRepository authRepository,
    required AppDatabase database,
    Uuid? uuid,
  }) : _dao = dao,
       _apiClient = apiClient,
       _authRepository = authRepository,
       _database = database,
       _uuid = uuid ?? const Uuid();

  final MedicationDao _dao;
  final MedicationApiClient _apiClient;
  final AuthRepository _authRepository;
  final AppDatabase _database;
  final Uuid _uuid;

  static const _resourceName = 'medications';

  @override
  String get resourceName => _resourceName;

  @override
  Stream<List<Medication>> watchActive() {
    return _dao.watchActive().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<Medication> register({
    required String name,
    required MedicationType type,
    required double dose,
    required DoseUnit doseUnit,
    required MedicationFrequency frequency,
    DateTime? startDate,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _dao.upsert(
      MedicationsCompanion.insert(
        id: id,
        name: name,
        type: type.wireValue,
        dose: dose,
        doseUnit: doseUnit.wireValue,
        frequency: frequency.wireValue,
        startDate: Value(startDate),
        active: const Value(true),
        notes: Value(notes),
        syncStatus: SyncStatus.pendingCreate.name,
        localUpdatedAt: now,
      ),
    );
    final row = await _dao.getById(id);
    return _toDomain(row!);
  }

  @override
  Future<void> deactivate(String id) => _dao.markPendingUpdate(id, active: false);

  @override
  Future<void> pullChanges() async {
    final patientId = await _requirePatientId();
    final cursorRow = await (_database.select(
      _database.syncCursors,
    )..where((t) => t.resource.equals(_resourceName))).getSingleOrNull();

    final since = cursorRow?.lastSyncedAt;
    final remoteMedications = await _apiClient.sync(patientId: patientId, since: since);

    for (final dto in remoteMedications) {
      await _dao.upsert(_companionFromDto(dto, SyncStatus.synced));
    }

    await _database
        .into(_database.syncCursors)
        .insertOnConflictUpdate(SyncCursorsCompanion.insert(resource: _resourceName, lastSyncedAt: DateTime.now()));
  }

  @override
  Future<InsulinCalculationResult> calculateInsulinDose({
    required double currentGlucose,
    double? carbsToEat,
    required bool beforeMeal,
  }) async {
    final patientId = await _requirePatientId();
    final dto = await _apiClient.calculate(
      patientId: patientId,
      currentGlucose: currentGlucose,
      carbsToEat: carbsToEat,
      beforeMeal: beforeMeal,
    );
    return InsulinCalculationResult(
      correctionDose: dto.correctionDose,
      mealDose: dto.mealDose,
      totalDose: dto.totalDose,
      explanation: dto.explanation,
      disclaimer: dto.disclaimer,
    );
  }

  @override
  Future<void> updateInsulinProfile({
    required double sensitivityFactor,
    required double carbRatio,
    required double targetGlucose,
  }) async {
    final patientId = await _requirePatientId();
    final json = await _apiClient.updateInsulinProfile(
      patientId: patientId,
      sensitivityFactor: sensitivityFactor,
      carbRatio: carbRatio,
      targetGlucose: targetGlucose,
    );
    await _authRepository.updateCachedPatient(Patient.fromJson(json));
  }

  @override
  Future<List<PendingChange<Medication>>> getPending() async {
    final rows = await _dao.getPending();
    return rows.map((row) {
      final status = SyncStatus.values.firstWhere((s) => s.name == row.syncStatus);
      return PendingChange<Medication>(id: row.id, status: status, payload: _toDomain(row));
    }).toList();
  }

  @override
  Future<void> pushCreate(Medication payload) async {
    final patientId = await _requirePatientId();
    final dto = await _apiClient.register(
      patientId: patientId,
      name: payload.name,
      type: payload.type.wireValue,
      dose: payload.dose,
      doseUnit: payload.doseUnit.wireValue,
      frequency: payload.frequency.wireValue,
      startDate: payload.startDate,
      notes: payload.notes,
      medicationId: payload.id,
    );
    await _dao.upsert(_companionFromDto(dto, SyncStatus.pendingCreate));
  }

  /// Único "update" que existe para medicamentos: la desactivación —
  /// ver `MedicationController.deactivate`.
  @override
  Future<void> pushUpdate(Medication payload) async {
    final patientId = await _requirePatientId();
    await _apiClient.deactivate(patientId: patientId, medicationId: payload.id);
  }

  @override
  Future<void> pushDelete(String id) {
    throw UnimplementedError('Los medicamentos se desactivan, nunca se borran');
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

  MedicationsCompanion _companionFromDto(MedicationResponseDto dto, SyncStatus syncStatus) {
    return MedicationsCompanion.insert(
      id: dto.medicationId,
      name: dto.name,
      type: dto.type,
      dose: dto.dose,
      doseUnit: dto.doseUnit,
      frequency: dto.frequency,
      startDate: Value(dto.startDate),
      active: Value(dto.active),
      notes: Value(dto.notes),
      syncStatus: syncStatus.name,
      localUpdatedAt: DateTime.now(),
      serverUpdatedAt: Value(dto.updatedAt),
    );
  }

  Medication _toDomain(MedicationRow row) {
    return Medication(
      id: row.id,
      name: row.name,
      type: MedicationType.fromWire(row.type),
      dose: row.dose,
      doseUnit: DoseUnit.fromWire(row.doseUnit),
      frequency: MedicationFrequency.fromWire(row.frequency),
      startDate: row.startDate,
      active: row.active,
      notes: row.notes,
      syncStatus: SyncStatus.values.firstWhere((s) => s.name == row.syncStatus),
      updatedAt: row.serverUpdatedAt,
    );
  }
}
