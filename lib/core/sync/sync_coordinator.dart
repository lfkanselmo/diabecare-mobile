import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import 'sync_service.dart';

/// Junta el empuje (`SyncService.syncAll`, outbox → servidor) con el jalado
/// (`pullChanges` por dominio, servidor → local) en una sola operación.
///
/// Dispara `runSync()` en 3 momentos — no solo al recuperar conectividad
/// (Fase 0-4 solo cubría ese caso, lo que significaba que dos dispositivos
/// nunca se enteraban de los cambios del otro mientras ambos permanecieran
/// conectados sin que la conexión de ninguno de los dos parpadeara alguna
/// vez — el escenario multi-dispositivo más común de todos, ver Fase 5 en
/// ROADMAP.md):
/// 1. Al arrancar la app, si ya hay conexión (no hace falta esperar una
///    transición que puede no llegar nunca).
/// 2. Al volver a primer plano (`AppLifecycleState.resumed`) — el caso real
///    de "cambié de dispositivo y volví a este".
/// 3. En la transición de sin-conexión a con-conexión (comportamiento
///    original, se mantiene).
class SyncCoordinator with WidgetsBindingObserver {
  SyncCoordinator({
    required SyncService syncService,
    required List<Future<void> Function()> pullers,
    required AuthRepository authRepository,
    Connectivity? connectivity,
  }) : _syncService = syncService,
       _pullers = pullers,
       _authRepository = authRepository,
       _connectivity = connectivity ?? Connectivity();

  final SyncService _syncService;
  final List<Future<void> Function()> _pullers;
  final AuthRepository _authRepository;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasOffline = false;
  bool _isSyncing = false;
  bool _isObserving = false;

  /// No-op si no hay sesión activa (evita que un `StateError` de
  /// "sin paciente en la sesión" quede sin capturar cuando la conectividad
  /// cambia o la app se resume antes del login) o si ya hay un ciclo de
  /// sync en curso (evita empujes/jalados duplicados si dos disparadores
  /// coinciden, p. ej. resumir la app justo cuando vuelve la conexión).
  ///
  /// El flag `_isSyncing` se marca *antes* del primer `await` a propósito:
  /// si se marcara después (p. ej. después de resolver `isAuthenticated()`),
  /// dos llamadas a `runSync()` disparadas en el mismo tick alcanzan a pasar
  /// ambas el chequeo antes de que la primera termine de marcarlo.
  Future<void> runSync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      if (!await _authRepository.isAuthenticated()) return;
      await _syncService.syncAll();
      for (final pull in _pullers) {
        await pull();
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Se suscribe una sola vez (llamar al arrancar la app).
  Future<void> startWatchingConnectivity() async {
    if (!_isObserving) {
      WidgetsBinding.instance.addObserver(this);
      _isObserving = true;
    }

    final initial = await _connectivity.checkConnectivity();
    _wasOffline = initial.every((r) => r == ConnectivityResult.none);
    if (!_wasOffline) {
      unawaited(runSync());
    }

    _subscription ??= _connectivity.onConnectivityChanged.listen((results) {
      final isOffline = results.every((r) => r == ConnectivityResult.none);
      if (_wasOffline && !isOffline) {
        unawaited(runSync());
      }
      _wasOffline = isOffline;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(runSync());
    }
  }

  void dispose() {
    if (_isObserving) {
      WidgetsBinding.instance.removeObserver(this);
      _isObserving = false;
    }
    _subscription?.cancel();
  }
}
