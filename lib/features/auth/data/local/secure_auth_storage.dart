import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper sobre `flutter_secure_storage` — replica el comportamiento exacto
/// de `auth.service.ts` (localStorage en la web), incluida la asimetría entre
/// `saveSession` (escribe los 4 valores) y `saveAccessToken` (solo toca los
/// tokens, nunca patient/role — así se comporta el refresh en la web).
class SecureAuthStorage {
  SecureAuthStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'dc_access_token';
  static const _refreshTokenKey = 'dc_refresh_token';
  static const _patientKey = 'dc_patient';
  static const _roleKey = 'dc_role';

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String role,
    String? patientJson,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _roleKey, value: role),
      _storage.write(key: _patientKey, value: patientJson),
    ]);
  }

  /// Solo el refresh actualiza esto — patient/role persisten entre refreshes.
  Future<void> saveAccessToken({required String accessToken, required String refreshToken}) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _patientKey),
      _storage.delete(key: _roleKey),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<String?> getPatientJson() => _storage.read(key: _patientKey);

  Future<String?> getRole() => _storage.read(key: _roleKey);

  Future<bool> isAdmin() async => (await getRole()) == 'ADMIN';

  /// Claim `userId` del JWT actual, o null si no hay token/no se puede decodificar.
  Future<String?> getUserId() async {
    final token = await getAccessToken();
    if (token == null) return null;
    return decodeJwtClaim(token, 'userId') as String?;
  }

  Future<bool> isTokenExpired(String token) async {
    final exp = decodeJwtClaim(token, 'exp');
    if (exp is! int) return true;
    return DateTime.now().millisecondsSinceEpoch >= exp * 1000;
  }
}

/// Decodifica el payload de un JWT sin verificar la firma (solo se usa para
/// leer expiración/claims, igual que `JSON.parse(atob(...))` en la web) y
/// devuelve el valor de una clave específica, o null si algo falla.
dynamic decodeJwtClaim(String token, String claim) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final normalized = base64Url.normalize(parts[1]);
    final payload = jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;
    return payload[claim];
  } catch (_) {
    return null;
  }
}
