import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'sync_service.dart';

/// Junta el empuje (`SyncService.syncAll`, outbox → servidor) con el jalado
/// (`pullChanges` por dominio, servidor → local) en una sola operación, y la
/// dispara al recuperar conectividad — ARCHITECTURE.md §4.3/4.4 tratan
/// ambos flujos como parte del mismo ciclo de sincronización.
class SyncCoordinator {
  SyncCoordinator({
    required SyncService syncService,
    required List<Future<void> Function()> pullers,
    Connectivity? connectivity,
  }) : _syncService = syncService,
       _pullers = pullers,
       _connectivity = connectivity ?? Connectivity();

  final SyncService _syncService;
  final List<Future<void> Function()> _pullers;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasOffline = false;

  Future<void> runSync() async {
    await _syncService.syncAll();
    for (final pull in _pullers) {
      await pull();
    }
  }

  /// Se suscribe una sola vez (llamar al arrancar la app) — corre `runSync`
  /// cada vez que se pasa de sin-conexión a con-conexión.
  void startWatchingConnectivity() {
    _subscription ??= _connectivity.onConnectivityChanged.listen((results) {
      final isOffline = results.every((r) => r == ConnectivityResult.none);
      if (_wasOffline && !isOffline) {
        unawaited(runSync());
      }
      _wasOffline = isOffline;
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
