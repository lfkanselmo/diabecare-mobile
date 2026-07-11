import 'package:diabecare_mobile/core/storage/app_database.dart';
import 'package:diabecare_mobile/core/sync/sync_status.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/biological_sex.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/diabetes_type.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/patient.dart';
import 'package:diabecare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:diabecare_mobile/features/vitals/data/local/exercise_log_dao.dart';
import 'package:diabecare_mobile/features/vitals/data/remote/exercise_log_api_client.dart';
import 'package:diabecare_mobile/features/vitals/data/remote/exercise_log_dtos.dart';
import 'package:diabecare_mobile/features/vitals/data/repository_impl/exercise_log_repository_impl.dart';
import 'package:diabecare_mobile/features/vitals/domain/entities/exercise_intensity.dart';
import 'package:diabecare_mobile/features/vitals/domain/entities/exercise_log.dart';
import 'package:diabecare_mobile/features/vitals/domain/entities/exercise_type.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockExerciseLogDao extends Mock implements ExerciseLogDao {}

class _MockExerciseLogApiClient extends Mock implements ExerciseLogApiClient {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockExerciseLogDao dao;
  late _MockExerciseLogApiClient apiClient;
  late _MockAuthRepository authRepository;
  late ExerciseLogRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const ExerciseLogsCompanion());
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
    dao = _MockExerciseLogDao();
    apiClient = _MockExerciseLogApiClient();
    authRepository = _MockAuthRepository();
    when(() => authRepository.loadSession()).thenAnswer(
      (_) async => AuthSession(accessToken: 'a', refreshToken: 'r', role: 'PATIENT', patient: patient),
    );
    repository = ExerciseLogRepositoryImpl(
      dao: dao,
      apiClient: apiClient,
      authRepository: authRepository,
      database: database,
    );
  });

  ExerciseLogRow row({required String id, required String syncStatus}) {
    return ExerciseLogRow(
      id: id,
      exerciseType: 'WALKING',
      intensity: 'MODERATE',
      durationMinutes: 30,
      performedAt: DateTime(2026, 1, 1),
      syncStatus: syncStatus,
      localUpdatedAt: DateTime(2026, 1, 1),
    );
  }

  test('getPending mapea las filas pendientes a PendingChange', () async {
    when(() => dao.getPending()).thenAnswer((_) async => [row(id: 'e1', syncStatus: SyncStatus.pendingCreate.name)]);

    final pending = await repository.getPending();

    expect(pending, hasLength(1));
    expect(pending.first.id, 'e1');
    expect(pending.first.payload, isA<ExerciseLog>());
  });

  test('pushCreate registra en el backend con el ID del cliente y hace upsert de la respuesta', () async {
    when(
      () => apiClient.register(
        patientId: any(named: 'patientId'),
        exerciseType: any(named: 'exerciseType'),
        intensity: any(named: 'intensity'),
        durationMinutes: any(named: 'durationMinutes'),
        performedAt: any(named: 'performedAt'),
        notes: any(named: 'notes'),
        caloriesBurned: any(named: 'caloriesBurned'),
        exerciseId: any(named: 'exerciseId'),
      ),
    ).thenAnswer(
      (_) async => ExerciseLogResponseDto(
        exerciseId: 'e1',
        exerciseType: 'WALKING',
        intensity: 'MODERATE',
        durationMinutes: 30,
        caloriesBurned: 123,
        performedAt: DateTime(2026, 1, 1).toIso8601String(),
      ),
    );
    when(() => dao.upsert(any())).thenAnswer((_) async {});

    final log = ExerciseLog(
      id: 'e1',
      exerciseType: ExerciseType.walking,
      intensity: ExerciseIntensity.moderate,
      durationMinutes: 30,
      performedAt: DateTime(2026, 1, 1),
      syncStatus: SyncStatus.pendingCreate,
    );

    await repository.pushCreate(log);

    verify(() => apiClient.register(
          patientId: 'patient-1',
          exerciseType: 'WALKING',
          intensity: 'MODERATE',
          durationMinutes: 30,
          performedAt: DateTime(2026, 1, 1),
          notes: null,
          caloriesBurned: null,
          exerciseId: 'e1',
        )).called(1);
    verify(() => dao.upsert(any())).called(1);
  });

  test('pushUpdate lanza — no existe edición de ejercicio todavía', () {
    final log = ExerciseLog(
      id: 'e1',
      exerciseType: ExerciseType.walking,
      intensity: ExerciseIntensity.moderate,
      durationMinutes: 30,
      performedAt: DateTime(2026, 1, 1),
      syncStatus: SyncStatus.pendingUpdate,
    );

    expect(() => repository.pushUpdate(log), throwsUnimplementedError);
  });

  test('markSynced delega al dao', () async {
    when(() => dao.markSynced('e1', any())).thenAnswer((_) async {});

    await repository.markSynced('e1', DateTime(2026, 1, 1));

    verify(() => dao.markSynced('e1', DateTime(2026, 1, 1))).called(1);
  });
}
