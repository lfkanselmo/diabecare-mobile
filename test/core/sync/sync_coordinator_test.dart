import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:diabecare_mobile/core/sync/sync_coordinator.dart';
import 'package:diabecare_mobile/core/sync/sync_service.dart';
import 'package:diabecare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSyncService extends Mock implements SyncService {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockSyncService syncService;
  late _MockAuthRepository authRepository;
  late _MockConnectivity connectivity;
  late List<String> pullOrder;
  late SyncCoordinator coordinator;

  SyncCoordinator buildCoordinator() {
    pullOrder = [];
    return SyncCoordinator(
      syncService: syncService,
      authRepository: authRepository,
      connectivity: connectivity,
      pullers: [
        () async => pullOrder.add('first'),
        () async => pullOrder.add('second'),
      ],
    );
  }

  setUp(() {
    syncService = _MockSyncService();
    authRepository = _MockAuthRepository();
    connectivity = _MockConnectivity();
    when(() => syncService.syncAll()).thenAnswer((_) async {});
    when(() => authRepository.isAuthenticated()).thenAnswer((_) async => true);
    when(() => connectivity.onConnectivityChanged).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() => coordinator.dispose());

  test('runSync no hace nada si no hay sesión activa — evita un StateError sin capturar', () async {
    when(() => authRepository.isAuthenticated()).thenAnswer((_) async => false);
    coordinator = buildCoordinator();

    await coordinator.runSync();

    verifyNever(() => syncService.syncAll());
    expect(pullOrder, isEmpty);
  });

  test('runSync empuja (syncAll) antes de jalar (pullers), en orden', () async {
    coordinator = buildCoordinator();

    await coordinator.runSync();

    verify(() => syncService.syncAll()).called(1);
    expect(pullOrder, ['first', 'second']);
  });

  test('runSync es reentrante-seguro: una segunda llamada mientras la primera sigue en curso es un no-op', () async {
    final syncAllCalls = <void>[];
    when(() => syncService.syncAll()).thenAnswer((_) async {
      syncAllCalls.add(null);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    coordinator = buildCoordinator();

    final first = coordinator.runSync();
    final second = coordinator.runSync();
    await Future.wait([first, second]);

    expect(syncAllCalls, hasLength(1));
  });

  test('startWatchingConnectivity dispara un sync inicial si ya hay conexión al arrancar', () async {
    when(() => connectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.wifi]);
    coordinator = buildCoordinator();

    await coordinator.startWatchingConnectivity();
    await Future<void>.delayed(Duration.zero);

    verify(() => syncService.syncAll()).called(1);
  });

  test('startWatchingConnectivity NO dispara un sync inicial si arranca sin conexión', () async {
    when(() => connectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.none]);
    coordinator = buildCoordinator();

    await coordinator.startWatchingConnectivity();
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => syncService.syncAll());
  });

  test('volver a primer plano dispara un sync — cubre el caso de cambiar de dispositivo y volver', () async {
    when(() => connectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.none]);
    coordinator = buildCoordinator();
    await coordinator.startWatchingConnectivity();

    coordinator.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);

    verify(() => syncService.syncAll()).called(1);
  });
}
