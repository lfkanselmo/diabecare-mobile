import 'dart:math';

import 'package:dio/dio.dart';

import 'sync_status.dart';
import 'syncable_repository.dart';

/// Motor genérico de sincronización offline — orquesta cualquier
/// [SyncableRepository] registrado (cada dominio, desde Fase 1 en adelante,
/// implementa la interfaz y se registra acá; glucosa es el primero).
/// Reintenta con backoff exponencial en error de red; en un error de
/// validación real (4xx que no sea de red) marca `syncError` y sigue con el
/// resto — nunca descarta un dato de salud en silencio (ARCHITECTURE.md 4.3).
///
/// El disparo (reconexión detectada, background task) se difiere a cuando
/// exista un dominio real que sincronizar (Fase 1) — acá solo vive el motor.
class SyncService {
  SyncService({
    List<SyncableRepository<dynamic>> repositories = const [],
    int maxRetries = 5,
    Duration Function(int attempt)? backoff,
  }) : _repositories = repositories,
       _maxRetries = maxRetries,
       _backoff = backoff ?? _exponentialBackoff;

  final List<SyncableRepository<dynamic>> _repositories;
  final int _maxRetries;
  final Duration Function(int attempt) _backoff;

  Future<void> syncAll() async {
    for (final repository in _repositories) {
      await _syncRepository(repository);
    }
  }

  Future<void> _syncRepository(SyncableRepository<dynamic> repository) async {
    final pending = await repository.getPending();
    for (final change in pending) {
      await _syncOne(repository, change);
    }
  }

  Future<void> _syncOne(SyncableRepository<dynamic> repository, PendingChange<dynamic> change) async {
    var attempt = 0;
    while (true) {
      try {
        await _push(repository, change);
        await repository.markSynced(change.id, DateTime.now());
        return;
      } on DioException catch (e) {
        final isNetworkError = e.type != DioExceptionType.badResponse;
        if (isNetworkError && attempt < _maxRetries) {
          attempt++;
          await Future<void>.delayed(_backoff(attempt));
          continue;
        }
        await repository.markSyncError(change.id, e.message ?? 'Error de sincronización');
        return;
      }
    }
  }

  Future<void> _push(SyncableRepository<dynamic> repository, PendingChange<dynamic> change) {
    switch (change.status) {
      case SyncStatus.pendingCreate:
        return repository.pushCreate(change.payload);
      case SyncStatus.pendingUpdate:
        return repository.pushUpdate(change.payload);
      case SyncStatus.pendingDelete:
        return repository.pushDelete(change.id);
      case SyncStatus.synced:
      case SyncStatus.syncError:
        return Future.value();
    }
  }

  static Duration _exponentialBackoff(int attempt) {
    final seconds = min(pow(2, attempt).toInt(), 60);
    return Duration(seconds: seconds);
  }
}
