import 'package:diabecare_mobile/features/auth/data/local/secure_auth_storage.dart';
import 'package:diabecare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:diabecare_mobile/features/profile/data/remote/account_api_client.dart';
import 'package:diabecare_mobile/features/profile/data/remote/device_api_key_api_client.dart';
import 'package:diabecare_mobile/features/profile/data/remote/session_api_client.dart';
import 'package:diabecare_mobile/features/profile/data/remote/session_dtos.dart';
import 'package:diabecare_mobile/features/profile/data/repository_impl/account_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAccountApiClient extends Mock implements AccountApiClient {}

class _MockDeviceApiKeyApiClient extends Mock implements DeviceApiKeyApiClient {}

class _MockSessionApiClient extends Mock implements SessionApiClient {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSecureAuthStorage extends Mock implements SecureAuthStorage {}

void main() {
  late _MockAccountApiClient accountApiClient;
  late _MockDeviceApiKeyApiClient deviceApiKeyApiClient;
  late _MockSessionApiClient sessionApiClient;
  late _MockAuthRepository authRepository;
  late _MockSecureAuthStorage secureAuthStorage;
  late AccountRepositoryImpl repository;

  setUp(() {
    accountApiClient = _MockAccountApiClient();
    deviceApiKeyApiClient = _MockDeviceApiKeyApiClient();
    sessionApiClient = _MockSessionApiClient();
    authRepository = _MockAuthRepository();
    secureAuthStorage = _MockSecureAuthStorage();
    when(() => secureAuthStorage.getUserId()).thenAnswer((_) async => 'user-1');
    when(() => authRepository.clearSession()).thenAnswer((_) async {});
    repository = AccountRepositoryImpl(
      accountApiClient: accountApiClient,
      deviceApiKeyApiClient: deviceApiKeyApiClient,
      sessionApiClient: sessionApiClient,
      authRepository: authRepository,
      secureAuthStorage: secureAuthStorage,
    );
  });

  test('suspendAccount limpia la sesión local tras suspender en el backend', () async {
    when(() => accountApiClient.suspend('user-1')).thenAnswer((_) async {});

    await repository.suspendAccount();

    verify(() => accountApiClient.suspend('user-1')).called(1);
    verify(() => authRepository.clearSession()).called(1);
  });

  test('deleteAccount limpia la sesión local tras eliminar en el backend', () async {
    when(() => accountApiClient.delete('user-1')).thenAnswer((_) async {});

    await repository.deleteAccount();

    verify(() => accountApiClient.delete('user-1')).called(1);
    verify(() => authRepository.clearSession()).called(1);
  });

  test('logoutAllSessions limpia la sesión local tras cerrar todas las sesiones', () async {
    when(() => sessionApiClient.logoutAll('user-1')).thenAnswer((_) async {});

    await repository.logoutAllSessions();

    verify(() => sessionApiClient.logoutAll('user-1')).called(1);
    verify(() => authRepository.clearSession()).called(1);
  });

  test('getActiveSessions mapea las sesiones devueltas por el backend', () async {
    when(() => sessionApiClient.getActiveSessions('user-1')).thenAnswer(
      (_) async => [
        ActiveSessionResponseDto(
          id: 's1',
          deviceLabel: 'iPhone 15',
          lastUsedAt: DateTime(2026, 1, 1),
          createdAt: DateTime(2025, 12, 1),
        ),
      ],
    );

    final sessions = await repository.getActiveSessions();

    expect(sessions, hasLength(1));
    expect(sessions.first.deviceLabel, 'iPhone 15');
  });
}
