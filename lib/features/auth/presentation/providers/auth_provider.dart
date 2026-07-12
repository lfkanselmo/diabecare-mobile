import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/register_data.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

/// Fuente de verdad del estado de sesión para la UI — el router y los
/// interceptors de red no dependen de esto (dependen directamente de
/// `AuthRepository`/`SecureAuthStorage` para evitar ciclos, ver
/// `network_providers.dart`), pero sí lo invalidan/refrescan a través de él.
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  Future<AuthSession?> build() {
    return ref.watch(authRepositoryProvider).loadSession();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.login(email: email, password: password),
    );
    _syncAfterAuthChangeIfNeeded();
  }

  Future<void> register(RegisterData data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.register(data));
    _syncAfterAuthChangeIfNeeded();
  }

  /// El primer login/registro en un dispositivo es, junto con volver a
  /// primer plano, uno de los 2 momentos reales en que un dispositivo nuevo
  /// necesita jalar todo el histórico existente sin esperar a que la
  /// conectividad parpadee (ver `SyncCoordinator`, Fase 5 en ROADMAP.md).
  void _syncAfterAuthChangeIfNeeded() {
    if (state.hasValue && state.value != null) {
      unawaited(ref.read(syncCoordinatorProvider).runSync());
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncData(null);
  }
}
