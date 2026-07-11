import 'package:diabecare_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/biological_sex.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/diabetes_type.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/patient.dart';
import 'package:diabecare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:diabecare_mobile/features/menstrual_cycle/data/remote/menstrual_cycle_api_client.dart';
import 'package:diabecare_mobile/features/menstrual_cycle/data/remote/menstrual_cycle_dtos.dart';
import 'package:diabecare_mobile/features/menstrual_cycle/data/repository_impl/menstrual_cycle_repository_impl.dart';
import 'package:diabecare_mobile/features/menstrual_cycle/domain/entities/cycle_symptom.dart';
import 'package:diabecare_mobile/features/menstrual_cycle/domain/entities/flow_intensity.dart';
import 'package:diabecare_mobile/features/menstrual_cycle/domain/entities/symptom_severity.dart';
import 'package:diabecare_mobile/features/menstrual_cycle/domain/repositories/menstrual_cycle_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMenstrualCycleApiClient extends Mock implements MenstrualCycleApiClient {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockMenstrualCycleApiClient apiClient;
  late _MockAuthRepository authRepository;
  late MenstrualCycleRepositoryImpl repository;

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
    apiClient = _MockMenstrualCycleApiClient();
    authRepository = _MockAuthRepository();
    when(() => authRepository.loadSession()).thenAnswer(
      (_) async => AuthSession(accessToken: 'a', refreshToken: 'r', role: 'PATIENT', patient: patient),
    );
    repository = MenstrualCycleRepositoryImpl(apiClient: apiClient, authRepository: authRepository);
  });

  MenstrualCycleStatusResponseDto statusDto({bool isOngoing = false}) {
    return MenstrualCycleStatusResponseDto(
      currentPhase: 'FOLLICULAR',
      currentPhaseLabel: 'Folicular',
      dayOfCycle: 8,
      isOngoing: isOngoing,
      isOpenTooLong: false,
      isProjectionStale: false,
      nextCycleStart: DateTime(2026, 2, 1),
      daysUntilNextCycle: 20,
      glucoseGuidance: 'Mayor sensibilidad a la insulina',
      history: const [],
    );
  }

  test('registerCycle delega al backend con el patientId de la sesión activa', () async {
    when(
      () => apiClient.register(patientId: any(named: 'patientId'), startDate: any(named: 'startDate'), notes: any(named: 'notes')),
    ).thenAnswer((_) async => statusDto(isOngoing: true));

    final result = await repository.registerCycle(startDate: DateTime(2026, 1, 1));

    verify(() => apiClient.register(patientId: 'patient-1', startDate: DateTime(2026, 1, 1), notes: null)).called(1);
    expect(result.isOngoing, isTrue);
  });

  test('registerDayEntry traduce los SymptomInput de dominio al formato del wire', () async {
    when(
      () => apiClient.registerDayEntry(
        patientId: any(named: 'patientId'),
        entryDate: any(named: 'entryDate'),
        flowIntensity: any(named: 'flowIntensity'),
        notes: any(named: 'notes'),
        symptoms: any(named: 'symptoms'),
      ),
    ).thenAnswer(
      (_) async => CycleDayEntryResponseDto(
        dayEntryId: 'd1',
        entryDate: DateTime(2026, 1, 5),
        flowIntensity: 'MODERATE',
        flowIntensityLabel: 'Moderado',
        symptoms: const [],
      ),
    );

    await repository.registerDayEntry(
      entryDate: DateTime(2026, 1, 5),
      flowIntensity: FlowIntensity.moderate,
      symptoms: const [SymptomInput(symptom: CycleSymptom.cramps, severity: SymptomSeverity.mild)],
    );

    final captured = verify(
      () => apiClient.registerDayEntry(
        patientId: 'patient-1',
        entryDate: DateTime(2026, 1, 5),
        flowIntensity: 'MODERATE',
        notes: null,
        symptoms: captureAny(named: 'symptoms'),
      ),
    ).captured;
    final symptoms = captured.single as List<({String symptom, String severity})>;
    expect(symptoms.single.symptom, 'CRAMPS');
    expect(symptoms.single.severity, 'MILD');
  });

  test('getStatus mapea la fase actual y el historial', () async {
    when(() => apiClient.getStatus(patientId: any(named: 'patientId'))).thenAnswer((_) async => statusDto());

    final status = await repository.getStatus();

    expect(status.dayOfCycle, 8);
    expect(status.glucoseGuidance, 'Mayor sensibilidad a la insulina');
  });
}
