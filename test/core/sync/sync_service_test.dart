import 'package:diabecare_mobile/core/sync/sync_service.dart';
import 'package:diabecare_mobile/core/sync/sync_status.dart';
import 'package:diabecare_mobile/core/sync/syncable_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements SyncableRepository<String> {
  _FakeRepository({
    required this.pending,
    this.networkFailuresBeforeSuccess = 0,
    this.permanentFailure = false,
  });

  final List<PendingChange<String>> pending;
  int networkFailuresBeforeSuccess;
  final bool permanentFailure;

  final List<String> syncedIds = [];
  final List<String> erroredIds = [];
  int pushAttempts = 0;

  @override
  String get resourceName => 'fake';

  @override
  Future<List<PendingChange<String>>> getPending() async => pending;

  @override
  Future<void> pushCreate(String payload) async {
    pushAttempts++;
    if (permanentFailure) {
      throw DioException(
        requestOptions: RequestOptions(path: '/fake'),
        type: DioExceptionType.badResponse,
        response: Response<void>(requestOptions: RequestOptions(path: '/fake'), statusCode: 422),
      );
    }
    if (networkFailuresBeforeSuccess > 0) {
      networkFailuresBeforeSuccess--;
      throw DioException(requestOptions: RequestOptions(path: '/fake'), type: DioExceptionType.connectionError);
    }
  }

  @override
  Future<void> pushUpdate(String payload) async {}

  @override
  Future<void> pushDelete(String id) async {}

  @override
  Future<void> markSynced(String id, DateTime serverUpdatedAt) async => syncedIds.add(id);

  @override
  Future<void> markSyncError(String id, String message) async => erroredIds.add(id);
}

void main() {
  test('sincroniza con éxito en el primer intento', () async {
    final repository = _FakeRepository(
      pending: [const PendingChange(id: 'a', status: SyncStatus.pendingCreate, payload: 'payload-a')],
    );
    final service = SyncService(repositories: [repository]);

    await service.syncAll();

    expect(repository.syncedIds, ['a']);
    expect(repository.erroredIds, isEmpty);
    expect(repository.pushAttempts, 1);
  });

  test('reintenta con backoff en error de red y eventualmente sincroniza', () async {
    final repository = _FakeRepository(
      pending: [const PendingChange(id: 'a', status: SyncStatus.pendingCreate, payload: 'payload-a')],
      networkFailuresBeforeSuccess: 2,
    );
    final service = SyncService(
      repositories: [repository],
      backoff: (_) => Duration.zero, // sin esperar segundos reales en el test
    );

    await service.syncAll();

    expect(repository.pushAttempts, 3);
    expect(repository.syncedIds, ['a']);
    expect(repository.erroredIds, isEmpty);
  });

  test('un error de validación (4xx no-red) se marca syncError sin reintentar', () async {
    final repository = _FakeRepository(
      pending: [const PendingChange(id: 'a', status: SyncStatus.pendingCreate, payload: 'payload-a')],
      permanentFailure: true,
    );
    final service = SyncService(repositories: [repository], backoff: (_) => Duration.zero);

    await service.syncAll();

    expect(repository.pushAttempts, 1);
    expect(repository.syncedIds, isEmpty);
    expect(repository.erroredIds, ['a']);
  });

  test('agota los reintentos de red y marca syncError sin descartar el dato', () async {
    final repository = _FakeRepository(
      pending: [const PendingChange(id: 'a', status: SyncStatus.pendingCreate, payload: 'payload-a')],
      networkFailuresBeforeSuccess: 100,
    );
    final service = SyncService(repositories: [repository], maxRetries: 2, backoff: (_) => Duration.zero);

    await service.syncAll();

    expect(repository.pushAttempts, 3); // intento inicial + 2 reintentos
    expect(repository.syncedIds, isEmpty);
    expect(repository.erroredIds, ['a']);
  });
}
