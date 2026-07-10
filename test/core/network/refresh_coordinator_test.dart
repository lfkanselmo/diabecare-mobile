import 'package:diabecare_mobile/core/network/refresh_coordinator.dart';
import 'package:diabecare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository authRepository;
  late RefreshCoordinator coordinator;

  setUp(() {
    authRepository = _MockAuthRepository();
    coordinator = RefreshCoordinator(authRepository);
  });

  test('llamadas concurrentes comparten un único refresh en curso', () async {
    var callCount = 0;
    when(() => authRepository.refreshAccessToken()).thenAnswer((_) async {
      callCount++;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return 'new-token';
    });

    final results = await Future.wait([
      coordinator.refreshAccessToken(),
      coordinator.refreshAccessToken(),
      coordinator.refreshAccessToken(),
    ]);

    expect(callCount, 1);
    expect(results, ['new-token', 'new-token', 'new-token']);
  });

  test('un refresh posterior (tras terminar el anterior) sí dispara una llamada nueva', () async {
    var callCount = 0;
    when(() => authRepository.refreshAccessToken()).thenAnswer((_) async {
      callCount++;
      return 'token-$callCount';
    });

    final first = await coordinator.refreshAccessToken();
    final second = await coordinator.refreshAccessToken();

    expect(callCount, 2);
    expect(first, 'token-1');
    expect(second, 'token-2');
  });

  test('si el refresh falla, el siguiente intento dispara una llamada nueva (no queda cacheado el error)', () async {
    var callCount = 0;
    when(() => authRepository.refreshAccessToken()).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) throw StateError('NO_REFRESH_TOKEN');
      return 'token-ok';
    });

    await expectLater(coordinator.refreshAccessToken(), throwsA(isA<StateError>()));
    final result = await coordinator.refreshAccessToken();

    expect(callCount, 2);
    expect(result, 'token-ok');
  });
}
