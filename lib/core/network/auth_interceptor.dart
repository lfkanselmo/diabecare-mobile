import 'package:dio/dio.dart';

import '../../features/auth/data/local/secure_auth_storage.dart';

/// Agrega `Authorization: Bearer <token>` a cada request, salvo los 6
/// endpoints públicos de `AuthController` (login/registro/refresh/logout/
/// forgot-password/reset-password no deben mandar un token viejo).
///
/// Mirror exacto de `PublicEndpoints.PUBLIC_AUTH_ENDPOINTS` en el backend —
/// a propósito NO se usa un substring/wildcard `/auth/`: `/auth/sessions/
/// {userId}` y `/auth/logout-all` sí requieren JWT, y un wildcard los dejaba
/// sin el header, causando un 401 silencioso en la pantalla de cuenta (spinner
/// infinito en "Active sessions"/"Log out of all devices").
///
/// Depende directamente de [SecureAuthStorage] (no de `AuthRepository`) a
/// propósito: `AuthRepository` depende de `AuthApiClient`, que depende de un
/// `Dio` — si este interceptor dependiera de `AuthRepository`, el `Dio` que
/// lo usa formaría un ciclo en el grafo de providers de Riverpod. Solo
/// `RefreshInterceptor` necesita el repositorio completo (para llamar
/// `/auth/refresh`), y usa un `Dio` interno separado para eso.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final SecureAuthStorage _storage;

  static const publicAuthPaths = {
    '/auth/register',
    '/auth/login',
    '/auth/refresh',
    '/auth/logout',
    '/auth/forgot-password',
    '/auth/reset-password',
  };

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!publicAuthPaths.contains(options.path)) {
      final token = await _storage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
