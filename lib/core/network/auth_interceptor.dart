import 'package:dio/dio.dart';

import '../../features/auth/data/local/secure_auth_storage.dart';

/// Agrega `Authorization: Bearer <token>` a cada request, salvo las de
/// `/auth/**` (login/registro/refresh no deben mandar un token viejo).
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

  static const authPathSegment = '/auth/';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!options.path.contains(authPathSegment)) {
      final token = await _storage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
