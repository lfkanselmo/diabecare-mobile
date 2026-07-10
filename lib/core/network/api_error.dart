import 'package:dio/dio.dart';

/// Extrae el campo `code` de un error de la API (`ApiError` del backend:
/// `{ "code": "...", "message": "..." }`), o null si el error no viene de
/// una respuesta HTTP con ese shape — mismo patrón que ya usa
/// `login.component.ts` en la web (`err.error.code`).
String? extractApiErrorCode(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return data['code'] as String?;
    }
  }
  return null;
}
