import '../entities/auth_session.dart';
import '../entities/register_data.dart';

/// A diferencia de `auth.service.ts` (localStorage, síncrono), acá todo es
/// async porque `flutter_secure_storage` lo es — el equivalente síncrono de
/// `isAuthenticated()`/`getToken()` de la web no existe en móvil.
abstract interface class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<AuthSession> register(RegisterData data);

  /// Limpia la sesión local primero y notifica al backend en segundo plano,
  /// sin esperar la respuesta — igual que `navbar.component.ts` en la web.
  Future<void> logout();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({required String token, required String newPassword});

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<bool> isAuthenticated();

  /// Reconstruye la sesión actual desde el storage seguro (para el arranque
  /// de la app y el redirect del router) — null si no hay sesión guardada.
  Future<AuthSession?> loadSession();

  /// Solo se usa desde el `RefreshCoordinator`. Lanza si el refresh token es
  /// inválido/reusado — el llamador debe tratarlo como sesión terminada en
  /// todos los dispositivos (ver `RefreshTokenReuseResponder` del backend).
  Future<String> refreshAccessToken();

  Future<void> clearSession();
}
