import 'package:diabecare_mobile/core/storage/app_database.dart';
import 'package:diabecare_mobile/core/sync/sync_status.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/biological_sex.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/diabetes_type.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/patient.dart';
import 'package:diabecare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:diabecare_mobile/features/medications/data/local/medication_dao.dart';
import 'package:diabecare_mobile/features/medications/data/remote/medication_api_client.dart';
import 'package:diabecare_mobile/features/medications/data/remote/medication_dtos.dart';
import 'package:diabecare_mobile/features/medications/data/repository_impl/medication_repository_impl.dart';
import 'package:diabecare_mobile/features/medications/domain/entities/dose_unit.dart';
import 'package:diabecare_mobile/features/medications/domain/entities/medication.dart';
import 'package:diabecare_mobile/features/medications/domain/entities/medication_frequency.dart';
import 'package:diabecare_mobile/features/medications/domain/entities/medication_type.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMedicationDao extends Mock implements MedicationDao {}

class _MockMedicationApiClient extends Mock implements MedicationApiClient {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockMedicationDao dao;
  late _MockMedicationApiClient apiClient;
  late _MockAuthRepository authRepository;
  late MedicationRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const MedicationsCompanion());
  });

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
    dao = _MockMedicationDao();
    apiClient = _MockMedicationApiClient();
    authRepository = _MockAuthRepository();
    when(() => authRepository.loadSession()).thenAnswer(
      (_) async => AuthSession(accessToken: 'a', refreshToken: 'r', role: 'PATIENT', patient: patient),
    );
    repository = MedicationRepositoryImpl(
      dao: dao,
      apiClient: apiClient,
      authRepository: authRepository,
      database: database,
    );
  });

  MedicationRow row({required String id, required String syncStatus, bool active = true}) {
    return MedicationRow(
      id: id,
      name: 'Metformina',
      type: 'ORAL',
      dose: 500,
      doseUnit: 'MG',
      frequency: 'TWICE_DAILY',
      active: active,
      syncStatus: syncStatus,
      localUpdatedAt: DateTime(2026, 1, 1),
    );
  }

  test('getPending mapea las filas pendientes a PendingChange', () async {
    when(() => dao.getPending()).thenAnswer((_) async => [row(id: 'med1', syncStatus: SyncStatus.pendingCreate.name)]);

    final pending = await repository.getPending();

    expect(pending, hasLength(1));
    expect(pending.first.id, 'med1');
    expect(pending.first.payload, isA<Medication>());
  });

  test('pushCreate registra en el backend con el ID del cliente y hace upsert de la respuesta', () async {
    when(
      () => apiClient.register(
        patientId: any(named: 'patientId'),
        name: any(named: 'name'),
        type: any(named: 'type'),
        dose: any(named: 'dose'),
        doseUnit: any(named: 'doseUnit'),
        frequency: any(named: 'frequency'),
        startDate: any(named: 'startDate'),
        notes: any(named: 'notes'),
        medicationId: any(named: 'medicationId'),
      ),
    ).thenAnswer(
      (_) async => MedicationResponseDto(
        medicationId: 'med1',
        name: 'Metformina',
        type: 'ORAL',
        dose: 500,
        doseUnit: 'MG',
        frequency: 'TWICE_DAILY',
        active: true,
      ),
    );
    when(() => dao.upsert(any())).thenAnswer((_) async {});

    final medication = Medication(
      id: 'med1',
      name: 'Metformina',
      type: MedicationType.oral,
      dose: 500,
      doseUnit: DoseUnit.mg,
      frequency: MedicationFrequency.twiceDaily,
      active: true,
      syncStatus: SyncStatus.pendingCreate,
    );

    await repository.pushCreate(medication);

    verify(() => apiClient.register(
          patientId: 'patient-1',
          name: 'Metformina',
          type: 'ORAL',
          dose: 500,
          doseUnit: 'MG',
          frequency: 'TWICE_DAILY',
          startDate: null,
          notes: null,
          medicationId: 'med1',
        )).called(1);
    verify(() => dao.upsert(any())).called(1);
  });

  test('pushUpdate llama al endpoint de desactivación — es el único "update" que existe', () async {
    when(
      () => apiClient.deactivate(patientId: any(named: 'patientId'), medicationId: any(named: 'medicationId')),
    ).thenAnswer((_) async {});

    final medication = Medication(
      id: 'med1',
      name: 'Metformina',
      type: MedicationType.oral,
      dose: 500,
      doseUnit: DoseUnit.mg,
      frequency: MedicationFrequency.twiceDaily,
      active: false,
      syncStatus: SyncStatus.pendingUpdate,
    );

    await repository.pushUpdate(medication);

    verify(() => apiClient.deactivate(patientId: 'patient-1', medicationId: 'med1')).called(1);
  });

  test('deactivate marca la fila como pendingUpdate con active en false', () async {
    when(() => dao.markPendingUpdate('med1', active: false)).thenAnswer((_) async {});

    await repository.deactivate('med1');

    verify(() => dao.markPendingUpdate('med1', active: false)).called(1);
  });

  test('pushDelete lanza — los medicamentos se desactivan, nunca se borran', () {
    expect(() => repository.pushDelete('med1'), throwsUnimplementedError);
  });
}
