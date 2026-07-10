import 'package:diabecare_mobile/features/auth/data/local/secure_auth_storage.dart';
import 'package:diabecare_mobile/features/auth/data/remote/auth_api_client.dart';
import 'package:diabecare_mobile/features/auth/data/remote/auth_dtos.dart';
import 'package:diabecare_mobile/features/auth/data/repository_impl/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthApiClient extends Mock implements AuthApiClient {}

class _MockSecureAuthStorage extends Mock implements SecureAuthStorage {}

void main() {
  late _MockAuthApiClient apiClient;
  late _MockSecureAuthStorage storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    apiClient = _MockAuthApiClient();
    storage = _MockSecureAuthStorage();
    repository = AuthRepositoryImpl(apiClient: apiClient, storage: storage);
  });

  test('login persiste la sesión y retorna un AuthSession con el patient decodificado', () async {
    when(
      () => apiClient.login(email: any(named: 'email'), password: any(named: 'password')),
    ).thenAnswer(
      (_) async => AuthResponseDto(
        accessToken: 'access-1',
        tokenType: 'Bearer',
        expiresIn: 900000,
        refreshToken: 'refresh-1',
        refreshExpiresIn: 604800000,
        patientJson: {
          'patientId': 'p-1',
          'fullName': 'Ana',
          'dateOfBirth': '1990-01-01',
          'age': 35,
          'diabetesType': 'TYPE_1',
          'diagnosisDate': '2010-01-01',
          'heightCm': 165.0,
          'targetGlucoseMin': 70.0,
          'targetGlucoseMax': 180.0,
          'activityLevel': 'MODERATE',
          'preferredGlucoseUnit': 'MG_DL',
          'biologicalSex': 'FEMALE',
        },
        role: 'PATIENT',
      ),
    );
    when(
      () => storage.saveSession(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
        role: any(named: 'role'),
        patientJson: any(named: 'patientJson'),
      ),
    ).thenAnswer((_) async {});

    final session = await repository.login(email: 'a@a.com', password: 'secret1234');

    expect(session.accessToken, 'access-1');
    expect(session.patient?.fullName, 'Ana');
    verify(
      () => storage.saveSession(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        role: 'PATIENT',
        patientJson: any(named: 'patientJson'),
      ),
    ).called(1);
  });

  test('logout limpia la sesión local antes de notificar al backend (fire-and-forget)', () async {
    when(() => storage.getRefreshToken()).thenAnswer((_) async => 'refresh-1');
    when(() => storage.clearSession()).thenAnswer((_) async {});
    when(() => apiClient.logout(any())).thenAnswer((_) async {});

    await repository.logout();

    verify(() => storage.clearSession()).called(1);
    verify(() => apiClient.logout('refresh-1')).called(1);
  });

  test('refreshAccessToken lanza si no hay refresh token guardado', () async {
    when(() => storage.getRefreshToken()).thenAnswer((_) async => null);

    expect(() => repository.refreshAccessToken(), throwsA(isA<StateError>()));
  });

  test('refreshAccessToken persiste solo los tokens nuevos (no toca patient/role)', () async {
    when(() => storage.getRefreshToken()).thenAnswer((_) async => 'old-refresh');
    when(() => apiClient.refresh('old-refresh')).thenAnswer(
      (_) async => RefreshTokenResponseDto(
        accessToken: 'new-access',
        tokenType: 'Bearer',
        expiresIn: 900000,
        refreshToken: 'new-refresh',
        refreshExpiresIn: 604800000,
      ),
    );
    when(
      () => storage.saveAccessToken(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});

    final newToken = await repository.refreshAccessToken();

    expect(newToken, 'new-access');
    verify(
      () => storage.saveAccessToken(accessToken: 'new-access', refreshToken: 'new-refresh'),
    ).called(1);
  });
}
