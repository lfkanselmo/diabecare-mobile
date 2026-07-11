import 'package:dio/dio.dart';

import 'session_dtos.dart';

/// Llamadas HTTP a `/api/v1/auth/sessions/**` y `/auth/logout-all` — a
/// diferencia del resto de `AuthController` (login/registro/refresh/
/// forgot-password), estos 2 endpoints requieren JWT — por eso usan el
/// `Dio` autenticado (`apiDio`), no el `authDio` sin interceptors que usa
/// `AuthApiClient`.
class SessionApiClient {
  SessionApiClient(this._dio);

  final Dio _dio;

  Future<List<ActiveSessionResponseDto>> getActiveSessions(String userId) async {
    final response = await _dio.get<List<dynamic>>('/auth/sessions/$userId');
    return response.data!.map((e) => ActiveSessionResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> logoutAll(String userId) {
    return _dio.post<void>('/auth/logout-all', data: {'userId': userId});
  }
}
