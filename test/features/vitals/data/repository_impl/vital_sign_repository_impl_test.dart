import 'package:diabecare_mobile/core/storage/app_database.dart';
import 'package:diabecare_mobile/core/sync/sync_status.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/biological_sex.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/diabetes_type.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/patient.dart';
import 'package:diabecare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:diabecare_mobile/features/vitals/data/local/vital_sign_dao.dart';
import 'package:diabecare_mobile/features/vitals/data/remote/vital_sign_api_client.dart';
import 'package:diabecare_mobile/features/vitals/data/remote/vital_sign_dtos.dart';
import 'package:diabecare_mobile/features/vitals/data/repository_impl/vital_sign_repository_impl.dart';
import 'package:diabecare_mobile/features/vitals/domain/entities/vital_sign.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVitalSignDao extends Mock implements VitalSignDao {}

class _MockVitalSignApiClient extends Mock implements VitalSignApiClient {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockVitalSignDao dao;
  late _MockVitalSignApiClient apiClient;
  late _MockAuthRepository authRepository;
  late VitalSignRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const VitalSignsCompanion());
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
    dao = _MockVitalSignDao();
    apiClient = _MockVitalSignApiClient();
    authRepository = _MockAuthRepository();
    when(() => authRepository.loadSession()).thenAnswer(
      (_) async => AuthSession(accessToken: 'a', refreshToken: 'r', role: 'PATIENT', patient: patient),
    );
    repository = VitalSignRepositoryImpl(
      dao: dao,
      apiClient: apiClient,
      authRepository: authRepository,
      database: database,
    );
  });

  VitalSignRow row({required String id, required String syncStatus}) {
    return VitalSignRow(
      id: id,
      measuredAt: DateTime(2026, 1, 1),
      weightKg: 70,
      syncStatus: syncStatus,
      localUpdatedAt: DateTime(2026, 1, 1),
    );
  }

  test('getPending mapea las filas pendientes a PendingChange', () async {
    when(() => dao.getPending()).thenAnswer((_) async => [row(id: 'v1', syncStatus: SyncStatus.pendingCreate.name)]);

    final pending = await repository.getPending();

    expect(pending, hasLength(1));
    expect(pending.first.id, 'v1');
    expect(pending.first.payload, isA<VitalSign>());
  });

  test('pushCreate registra en el backend con el ID del cliente y hace upsert de la respuesta', () async {
    when(
      () => apiClient.register(
        patientId: any(named: 'patientId'),
        weightKg: any(named: 'weightKg'),
        heightCm: any(named: 'heightCm'),
        systolicBp: any(named: 'systolicBp'),
        diastolicBp: any(named: 'diastolicBp'),
        heartRate: any(named: 'heartRate'),
        hba1c: any(named: 'hba1c'),
        measuredAt: any(named: 'measuredAt'),
        notes: any(named: 'notes'),
        vitalId: any(named: 'vitalId'),
      ),
    ).thenAnswer(
      (_) async => VitalSignResponseDto(vitalId: 'v1', measuredAt: DateTime(2026, 1, 1), weightKg: 70, bmi: 24.5),
    );
    when(() => dao.upsert(any())).thenAnswer((_) async {});

    final vital = VitalSign(
      id: 'v1',
      measuredAt: DateTime(2026, 1, 1),
      weightKg: 70,
      syncStatus: SyncStatus.pendingCreate,
    );

    await repository.pushCreate(vital);

    verify(() => apiClient.register(
          patientId: 'patient-1',
          weightKg: 70,
          heightCm: null,
          systolicBp: null,
          diastolicBp: null,
          heartRate: null,
          hba1c: null,
          measuredAt: DateTime(2026, 1, 1),
          notes: null,
          vitalId: 'v1',
        )).called(1);
    verify(() => dao.upsert(any())).called(1);
  });

  test('pushUpdate lanza — no existe edición de signos vitales todavía', () {
    final vital = VitalSign(id: 'v1', measuredAt: DateTime(2026, 1, 1), syncStatus: SyncStatus.pendingUpdate);

    expect(() => repository.pushUpdate(vital), throwsUnimplementedError);
  });

  test('markSynced delega al dao', () async {
    when(() => dao.markSynced('v1', any())).thenAnswer((_) async {});

    await repository.markSynced('v1', DateTime(2026, 1, 1));

    verify(() => dao.markSynced('v1', DateTime(2026, 1, 1))).called(1);
  });
}
