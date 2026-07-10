import 'dart:convert';

import 'package:diabecare_mobile/features/auth/data/local/secure_auth_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  final Map<String, String> data = {};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    data[key] = value;
  }

  @override
  Future<String?> read({required String key, required Map<String, String> options}) async => data[key];

  @override
  Future<bool> containsKey({required String key, required Map<String, String> options}) async =>
      data.containsKey(key);

  @override
  Future<void> delete({required String key, required Map<String, String> options}) async {
    data.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({required Map<String, String> options}) async => Map.of(data);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async => data.clear();
}

String _makeJwt(Map<String, dynamic> payload) {
  String encode(Object value) => base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'HS256', 'typ': 'JWT'})}.${encode(payload)}.sig';
}

void main() {
  late _FakeSecureStoragePlatform fakePlatform;
  late SecureAuthStorage storage;

  setUp(() {
    fakePlatform = _FakeSecureStoragePlatform();
    FlutterSecureStoragePlatform.instance = fakePlatform;
    storage = SecureAuthStorage();
  });

  group('decodeJwtClaim', () {
    test('lee el claim userId del payload', () {
      final token = _makeJwt({'userId': 'user-123', 'exp': 9999999999});
      expect(decodeJwtClaim(token, 'userId'), 'user-123');
    });

    test('retorna null para un token malformado', () {
      expect(decodeJwtClaim('no-es-un-jwt', 'userId'), isNull);
    });
  });

  group('isTokenExpired', () {
    test('retorna false para un token con exp futuro', () async {
      final future = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
      final token = _makeJwt({'userId': 'u1', 'exp': future});
      expect(await storage.isTokenExpired(token), isFalse);
    });

    test('retorna true para un token con exp pasado', () async {
      final past = DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
      final token = _makeJwt({'userId': 'u1', 'exp': past});
      expect(await storage.isTokenExpired(token), isTrue);
    });

    test('trata como expirado un token sin claim exp', () async {
      final token = _makeJwt({'userId': 'u1'});
      expect(await storage.isTokenExpired(token), isTrue);
    });
  });

  group('saveSession / saveAccessToken', () {
    test('saveSession escribe los 4 valores', () async {
      await storage.saveSession(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        role: 'PATIENT',
        patientJson: '{"patientId":"p-1"}',
      );

      expect(await storage.getAccessToken(), 'access-1');
      expect(await storage.getRefreshToken(), 'refresh-1');
      expect(await storage.getRole(), 'PATIENT');
      expect(await storage.getPatientJson(), '{"patientId":"p-1"}');
    });

    test('saveAccessToken NO toca patient/role — mismo comportamiento que el refresh de la web', () async {
      await storage.saveSession(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        role: 'PATIENT',
        patientJson: '{"patientId":"p-1"}',
      );

      await storage.saveAccessToken(accessToken: 'access-2', refreshToken: 'refresh-2');

      expect(await storage.getAccessToken(), 'access-2');
      expect(await storage.getRefreshToken(), 'refresh-2');
      expect(await storage.getRole(), 'PATIENT');
      expect(await storage.getPatientJson(), '{"patientId":"p-1"}');
    });

    test('clearSession borra los 4 valores', () async {
      await storage.saveSession(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        role: 'PATIENT',
        patientJson: '{"patientId":"p-1"}',
      );

      await storage.clearSession();

      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(await storage.getRole(), isNull);
      expect(await storage.getPatientJson(), isNull);
    });

    test('isAdmin es true solo cuando el rol guardado es ADMIN', () async {
      await storage.saveSession(accessToken: 'a', refreshToken: 'r', role: 'ADMIN');
      expect(await storage.isAdmin(), isTrue);
    });
  });
}
