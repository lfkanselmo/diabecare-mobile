import 'dart:async';
import 'dart:convert';

import '../../domain/entities/auth_session.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/register_data.dart';
import '../../domain/repositories/auth_repository.dart';
import '../local/secure_auth_storage.dart';
import '../remote/auth_api_client.dart';
import '../remote/auth_dtos.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthApiClient apiClient, required SecureAuthStorage storage})
    : _apiClient = apiClient,
      _storage = storage;

  final AuthApiClient _apiClient;
  final SecureAuthStorage _storage;

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    final dto = await _apiClient.login(email: email, password: password);
    return _persist(dto);
  }

  @override
  Future<AuthSession> register(RegisterData data) async {
    final dto = await _apiClient.register(RegisterRequestDto(data));
    return _persist(dto);
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    await _storage.clearSession();
    if (refreshToken != null) {
      // No se espera la respuesta — igual que `navbar.component.ts` en la web,
      // la sesión local ya se limpió y el usuario ya navegó a login.
      unawaited(_apiClient.logout(refreshToken).catchError((_) {}));
    }
  }

  @override
  Future<void> forgotPassword(String email) => _apiClient.forgotPassword(email);

  @override
  Future<void> resetPassword({required String token, required String newPassword}) {
    return _apiClient.resetPassword(token: token, newPassword: newPassword);
  }

  @override
  Future<String?> getAccessToken() => _storage.getAccessToken();

  @override
  Future<String?> getRefreshToken() => _storage.getRefreshToken();

  @override
  Future<bool> isAuthenticated() async {
    final token = await _storage.getAccessToken();
    if (token == null) return false;
    return !(await _storage.isTokenExpired(token));
  }

  @override
  Future<AuthSession?> loadSession() async {
    final accessToken = await _storage.getAccessToken();
    final refreshToken = await _storage.getRefreshToken();
    if (accessToken == null || refreshToken == null) return null;

    final role = await _storage.getRole() ?? '';
    final patientJson = await _storage.getPatientJson();
    final patient = _decodePatient(patientJson);

    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      role: role,
      patient: patient,
    );
  }

  @override
  Future<String> refreshAccessToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      throw StateError('NO_REFRESH_TOKEN');
    }
    final dto = await _apiClient.refresh(refreshToken);
    await _storage.saveAccessToken(accessToken: dto.accessToken, refreshToken: dto.refreshToken);
    return dto.accessToken;
  }

  @override
  Future<void> clearSession() => _storage.clearSession();

  @override
  Future<void> updateCachedPatient(Patient patient) => _storage.savePatient(jsonEncode(patient.toJson()));

  Future<AuthSession> _persist(AuthResponseDto dto) async {
    await _storage.saveSession(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      role: dto.role,
      patientJson: dto.patientJson == null ? null : jsonEncode(dto.patientJson),
    );

    return AuthSession(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      role: dto.role,
      patient: dto.patientJson == null ? null : Patient.fromJson(dto.patientJson!),
    );
  }

  Patient? _decodePatient(String? patientJson) {
    if (patientJson == null) return null;
    return Patient.fromJson(jsonDecode(patientJson) as Map<String, dynamic>);
  }
}
