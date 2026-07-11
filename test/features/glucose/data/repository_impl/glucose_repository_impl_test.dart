import 'package:diabecare_mobile/core/storage/app_database.dart';
import 'package:diabecare_mobile/core/sync/sync_status.dart';
import 'package:drift/native.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/biological_sex.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/diabetes_type.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/patient.dart';
import 'package:diabecare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:diabecare_mobile/features/glucose/data/local/glucose_dao.dart';
import 'package:diabecare_mobile/features/glucose/data/remote/glucose_api_client.dart';
import 'package:diabecare_mobile/features/glucose/data/remote/glucose_dtos.dart';
import 'package:diabecare_mobile/features/glucose/data/repository_impl/glucose_repository_impl.dart';
import 'package:diabecare_mobile/features/glucose/domain/entities/glucose_reading.dart';
import 'package:diabecare_mobile/features/glucose/domain/entities/glucose_unit.dart';
import 'package:diabecare_mobile/features/glucose/domain/entities/reading_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGlucoseDao extends Mock implements GlucoseDao {}

class _MockGlucoseApiClient extends Mock implements GlucoseApiClient {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockGlucoseDao dao;
  late _MockGlucoseApiClient apiClient;
  late _MockAuthRepository authRepository;
  late GlucoseRepositoryImpl repository;

  // Una sola instancia para todo el archivo — ninguno de estos tests llama a
  // `pullChanges()` (el único método que la toca), y Drift avisa si detecta
  // la misma clase de base de datos instanciada más de una vez.
  final database = AppDatabase(NativeDatabase.memory());

  final patient = Patient(
    patientId: 'patient-1',
    fullName: 'Ana',
    dateOfBirth: DateTime(1990, 1, 1),
    age: 35,
    diabetesType: DiabetesType.type1,
    diagnosisDate: DateTime(2010, 1, 1),
    heightCm: 165,
    targetGlucoseMin: 70,
    targetGlucoseMax: 180,
    activityLevel: 'MODERATE',
    preferredGlucoseUnit: 'MG_DL',
    biologicalSex: BiologicalSex.female,
  );

  setUp(() {
    dao = _MockGlucoseDao();
    apiClient = _MockGlucoseApiClient();
    authRepository = _MockAuthRepository();
    when(() => authRepository.loadSession()).thenAnswer(
      (_) async => AuthSession(accessToken: 'a', refreshToken: 'r', role: 'PATIENT', patient: patient),
    );
    repository = GlucoseRepositoryImpl(
      dao: dao,
      apiClient: apiClient,
      authRepository: authRepository,
      database: database,
    );
  });

  GlucoseReadingRow row({required String id, required String syncStatus, String? status}) {
    return GlucoseReadingRow(
      id: id,
      value: 100,
      unit: 'MG_DL',
      readingType: 'FASTING',
      status: status,
      measuredAt: DateTime(2026, 1, 1),
      syncStatus: syncStatus,
      localUpdatedAt: DateTime(2026, 1, 1),
    );
  }

  test('getPending mapea las filas pendientes a PendingChange', () async {
    when(() => dao.getPending()).thenAnswer((_) async => [row(id: 'r1', syncStatus: SyncStatus.pendingCreate.name)]);

    final pending = await repository.getPending();

    expect(pending, hasLength(1));
    expect(pending.first.id, 'r1');
    expect(pending.first.status, SyncStatus.pendingCreate);
    expect(pending.first.payload, isA<GlucoseReading>());
  });

  test('pushCreate registra en el backend con el ID del cliente y guarda el status devuelto', () async {
    when(
      () => apiClient.register(
        patientId: any(named: 'patientId'),
        value: any(named: 'value'),
        unit: any(named: 'unit'),
        readingType: any(named: 'readingType'),
        measuredAt: any(named: 'measuredAt'),
        notes: any(named: 'notes'),
        deviceSource: any(named: 'deviceSource'),
        readingId: any(named: 'readingId'),
      ),
    ).thenAnswer(
      (_) async => GlucoseReadingResponseDto(
        readingId: 'r1',
        value: 100,
        unit: 'MG_DL',
        readingType: 'FASTING',
        status: 'NORMAL',
        measuredAt: DateTime(2026, 1, 1),
        notes: null,
        deviceSource: null,
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    when(() => dao.updateStatus(any(), any())).thenAnswer((_) async {});

    final reading = GlucoseReading(
      id: 'r1',
      value: 100,
      unit: GlucoseUnit.mgDl,
      readingType: ReadingType.fasting,
      measuredAt: DateTime(2026, 1, 1),
      syncStatus: SyncStatus.pendingCreate,
    );

    await repository.pushCreate(reading);

    verify(
      () => apiClient.register(
        patientId: 'patient-1',
        value: 100,
        unit: 'MG_DL',
        readingType: 'FASTING',
        measuredAt: DateTime(2026, 1, 1),
        notes: null,
        deviceSource: null,
        readingId: 'r1',
      ),
    ).called(1);
    verify(() => dao.updateStatus('r1', 'NORMAL')).called(1);
  });

  test('markSynced borra la fila si estaba pendingDelete, en vez de marcarla synced', () async {
    when(() => dao.getById('r1')).thenAnswer((_) async => row(id: 'r1', syncStatus: SyncStatus.pendingDelete.name));
    when(() => dao.deleteById('r1')).thenAnswer((_) async {});

    await repository.markSynced('r1', DateTime(2026, 1, 1));

    verify(() => dao.deleteById('r1')).called(1);
    verifyNever(() => dao.markSynced(any(), any()));
  });

  test('markSynced marca synced normalmente si no era un delete', () async {
    when(() => dao.getById('r1')).thenAnswer((_) async => row(id: 'r1', syncStatus: SyncStatus.pendingCreate.name));
    when(() => dao.markSynced('r1', any())).thenAnswer((_) async {});

    await repository.markSynced('r1', DateTime(2026, 1, 1));

    verify(() => dao.markSynced('r1', DateTime(2026, 1, 1))).called(1);
    verifyNever(() => dao.deleteById(any()));
  });

  test('pushDelete llama al backend con el patientId de la sesión activa', () async {
    when(
      () => apiClient.delete(patientId: any(named: 'patientId'), readingId: any(named: 'readingId')),
    ).thenAnswer((_) async {});

    await repository.pushDelete('r1');

    verify(() => apiClient.delete(patientId: 'patient-1', readingId: 'r1')).called(1);
  });

  test('pushUpdate lanza — no existe edición de lecturas todavía', () {
    final reading = GlucoseReading(
      id: 'r1',
      value: 100,
      unit: GlucoseUnit.mgDl,
      readingType: ReadingType.fasting,
      measuredAt: DateTime(2026, 1, 1),
      syncStatus: SyncStatus.pendingUpdate,
    );

    expect(() => repository.pushUpdate(reading), throwsUnimplementedError);
  });

  test('delete borra directo una lectura pendingCreate (nunca llegó al servidor)', () async {
    when(() => dao.getById('r1')).thenAnswer((_) async => row(id: 'r1', syncStatus: SyncStatus.pendingCreate.name));
    when(() => dao.deleteById('r1')).thenAnswer((_) async {});

    await repository.delete('r1');

    verify(() => dao.deleteById('r1')).called(1);
    verifyNever(() => dao.markPendingDelete(any()));
  });

  test('delete marca pendingDelete una lectura ya sincronizada', () async {
    when(() => dao.getById('r1')).thenAnswer((_) async => row(id: 'r1', syncStatus: SyncStatus.synced.name));
    when(() => dao.markPendingDelete('r1')).thenAnswer((_) async {});

    await repository.delete('r1');

    verify(() => dao.markPendingDelete('r1')).called(1);
    verifyNever(() => dao.deleteById(any()));
  });
}
