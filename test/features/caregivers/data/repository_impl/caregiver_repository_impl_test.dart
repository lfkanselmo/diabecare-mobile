import 'package:diabecare_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/biological_sex.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/diabetes_type.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/patient.dart';
import 'package:diabecare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:diabecare_mobile/features/caregivers/data/remote/caregiver_api_client.dart';
import 'package:diabecare_mobile/features/caregivers/data/remote/caregiver_dtos.dart';
import 'package:diabecare_mobile/features/caregivers/data/repository_impl/caregiver_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCaregiverApiClient extends Mock implements CaregiverApiClient {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockCaregiverApiClient apiClient;
  late _MockAuthRepository authRepository;
  late CaregiverRepositoryImpl repository;

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
    apiClient = _MockCaregiverApiClient();
    authRepository = _MockAuthRepository();
    when(() => authRepository.loadSession()).thenAnswer(
      (_) async => AuthSession(accessToken: 'a', refreshToken: 'r', role: 'PATIENT', patient: patient),
    );
    repository = CaregiverRepositoryImpl(apiClient: apiClient, authRepository: authRepository);
  });

  test('createInvite delega al backend con el patientId de la sesión activa', () async {
    when(
      () => apiClient.createInvite('patient-1'),
    ).thenAnswer((_) async => CaregiverInviteResponseDto(code: 'ABC123', expiresAt: DateTime(2026, 2, 1)));

    final invite = await repository.createInvite();

    verify(() => apiClient.createInvite('patient-1')).called(1);
    expect(invite.code, 'ABC123');
  });

  test('getLinks mapea la lista de vínculos', () async {
    when(() => apiClient.getLinks('patient-1')).thenAnswer(
      (_) async => [
        CaregiverLinkResponseDto(
          linkId: 'l1',
          caregiverUserId: 'u1',
          caregiverName: 'Juan',
          caregiverEmail: 'juan@example.com',
          linkedAt: DateTime(2026, 1, 1),
        ),
      ],
    );

    final links = await repository.getLinks();

    expect(links, hasLength(1));
    expect(links.first.caregiverName, 'Juan');
  });

  test('revokeLink delega al backend con patientId y linkId', () async {
    when(
      () => apiClient.revokeLink(patientId: any(named: 'patientId'), linkId: any(named: 'linkId')),
    ).thenAnswer((_) async {});

    await repository.revokeLink('l1');

    verify(() => apiClient.revokeLink(patientId: 'patient-1', linkId: 'l1')).called(1);
  });

  test('redeem retorna el resultado del canje sin depender de la sesión propia', () async {
    when(
      () => apiClient.redeem('CODE1'),
    ).thenAnswer((_) async => RedeemCaregiverInviteResponseDto(patientId: 'other-patient', patientFullName: 'Luis'));

    final result = await repository.redeem('CODE1');

    expect(result.patientId, 'other-patient');
    expect(result.patientFullName, 'Luis');
    verifyNever(() => authRepository.loadSession());
  });
}
