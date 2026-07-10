import 'package:dio/dio.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import 'auth_interceptor.dart';
import 'refresh_coordinator.dart';

/// En un 401 de una ruta no-auth, refresca el access token (coordinado, ver
/// [RefreshCoordinator]) y reintenta la request original. Si el refresh
/// falla — refresh token ausente, expirado o reusado (ver
/// `RefreshTokenReuseResponder` del backend) — limpia la sesión y notifica
/// vía [onSessionExpired], igual que `redirectToLogin()` en `error.interceptor.ts`.
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor({
    required Dio dio,
    required AuthRepository authRepository,
    required RefreshCoordinator refreshCoordinator,
    required void Function() onSessionExpired,
  }) : _dio = dio,
       _authRepository = authRepository,
       _refreshCoordinator = refreshCoordinator,
       _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final AuthRepository _authRepository;
  final RefreshCoordinator _refreshCoordinator;
  final void Function() _onSessionExpired;

  static const _retriedFlag = 'refreshRetried';

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isAuthEndpoint = err.requestOptions.path.contains(AuthInterceptor.authPathSegment);
    final alreadyRetried = err.requestOptions.extra[_retriedFlag] == true;
    if (err.response?.statusCode != 401 || isAuthEndpoint || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshToken = await _authRepository.getRefreshToken();
    if (refreshToken == null) {
      // Sin refresh token no hubo sesión que expirar (misma razón que la web:
      // evita un "sesión expirada" para una llamada sin sesión previa).
      handler.next(err);
      return;
    }

    try {
      final newToken = await _refreshCoordinator.refreshAccessToken();
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newToken';
      // Un solo reintento: si el token recién refrescado también recibe 401,
      // es un problema real (no de expiración), no hay que reintentar en bucle.
      retryOptions.extra[_retriedFlag] = true;
      final response = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } catch (_) {
      await _authRepository.clearSession();
      _onSessionExpired();
      handler.next(err);
    }
  }
}
