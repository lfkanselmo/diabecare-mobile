import 'package:dio/dio.dart';

import 'auth_dtos.dart';

/// Llamadas HTTP a `/api/v1/auth/**` — contrato exacto de `AuthController`
/// del backend (todas estas rutas son públicas a nivel de filtro JWT).
class AuthApiClient {
  AuthApiClient(this._dio);

  final Dio _dio;

  Future<AuthResponseDto> login({required String email, required String password}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponseDto.fromJson(response.data!);
  }

  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>('/auth/register', data: request.toJson());
    return AuthResponseDto.fromJson(response.data!);
  }

  Future<RefreshTokenResponseDto> refresh(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return RefreshTokenResponseDto.fromJson(response.data!);
  }

  /// Fire-and-forget por el llamador (ver `AuthRepositoryImpl.logout`) — los
  /// errores de esta llamada no deben bloquear el logout local.
  Future<void> logout(String refreshToken) {
    return _dio.post<void>('/auth/logout', data: {'refreshToken': refreshToken});
  }

  Future<void> forgotPassword(String email) {
    return _dio.post<void>('/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword({required String token, required String newPassword}) {
    return _dio.post<void>(
      '/auth/reset-password',
      data: {'token': token, 'newPassword': newPassword},
    );
  }
}
