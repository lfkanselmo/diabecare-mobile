import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/local/secure_auth_storage.dart';
import '../../features/auth/data/remote/auth_api_client.dart';
import '../../features/auth/data/repository_impl/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import 'auth_interceptor.dart';
import 'env.dart';
import 'language_interceptor.dart';
import 'refresh_coordinator.dart';
import 'refresh_interceptor.dart';
import 'session_expired_notifier.dart';

part 'network_providers.g.dart';

@Riverpod(keepAlive: true)
SecureAuthStorage secureAuthStorage(Ref ref) => SecureAuthStorage();

@Riverpod(keepAlive: true)
SessionExpiredNotifier sessionExpiredNotifier(Ref ref) => SessionExpiredNotifier();

/// Dio "de solo autenticación" — usado únicamente por [AuthApiClient]. Sin
/// [AuthInterceptor]/[RefreshInterceptor] a propósito: los 6 endpoints de
/// `/auth/**` no necesitan Authorization ni refresh-on-401, y si tuvieran
/// esos interceptors dependerían de `AuthRepository`, que a su vez depende
/// de este mismo Dio — un ciclo en el grafo de providers.
@Riverpod(keepAlive: true)
Dio authDio(Ref ref) {
  final dio = Dio(BaseOptions(baseUrl: Env.apiUrl));
  dio.interceptors.addAll([
    LanguageInterceptor(),
    if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
  ]);
  return dio;
}

@Riverpod(keepAlive: true)
AuthApiClient authApiClient(Ref ref) => AuthApiClient(ref.watch(authDioProvider));

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  apiClient: ref.watch(authApiClientProvider),
  storage: ref.watch(secureAuthStorageProvider),
);

@Riverpod(keepAlive: true)
RefreshCoordinator refreshCoordinator(Ref ref) =>
    RefreshCoordinator(ref.watch(authRepositoryProvider));

/// Dio "de la API autenticada" — todas las llamadas a features (glucosa,
/// comidas, etc. desde Fase 1 en adelante) pasan por este, no por [authDio].
@Riverpod(keepAlive: true)
Dio apiDio(Ref ref) {
  final dio = Dio(BaseOptions(baseUrl: Env.apiUrl));
  dio.interceptors.addAll([
    AuthInterceptor(ref.watch(secureAuthStorageProvider)),
    RefreshInterceptor(
      dio: dio,
      authRepository: ref.watch(authRepositoryProvider),
      refreshCoordinator: ref.watch(refreshCoordinatorProvider),
      onSessionExpired: () => ref.read(sessionExpiredProvider).notify(),
    ),
    LanguageInterceptor(),
    if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
  ]);
  return dio;
}
