import 'package:dio/dio.dart';

import 'glucose_dtos.dart';

/// Llamadas HTTP a `/api/v1/glucose/**` — contrato exacto de
/// `GlucoseController` del backend. Usa el `apiDio` autenticado de Fase 0
/// (Authorization + refresh automático ya resueltos por los interceptors).
class GlucoseApiClient {
  GlucoseApiClient(this._dio);

  final Dio _dio;

  Future<GlucoseReadingResponseDto> register({
    required String patientId,
    required double value,
    required String unit,
    required String readingType,
    required DateTime measuredAt,
    String? notes,
    String? deviceSource,
    String? readingId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/glucose/$patientId',
      data: {
        'value': value,
        'unit': unit,
        'readingType': readingType,
        'measuredAt': measuredAt.toIso8601String(),
        'notes': ?notes,
        'deviceSource': ?deviceSource,
        'readingId': ?readingId,
      },
    );
    return GlucoseReadingResponseDto.fromJson(response.data!);
  }

  Future<void> delete({required String patientId, required String readingId}) {
    return _dio.delete<void>('/glucose/$patientId/$readingId');
  }

  Future<List<GlucoseReadingResponseDto>> sync({required String patientId, DateTime? since}) async {
    final response = await _dio.get<List<dynamic>>(
      '/glucose/$patientId/sync',
      queryParameters: {if (since != null) 'since': since.toIso8601String()},
    );
    return response.data!.map((e) => GlucoseReadingResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<GlucoseStatsResponseDto> getStats({
    required String patientId,
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/glucose/$patientId/stats',
      queryParameters: {'from': from.toIso8601String(), 'to': to.toIso8601String()},
    );
    return GlucoseStatsResponseDto.fromJson(response.data!);
  }

  Future<List<AgpBucketResponseDto>> getAgpProfile({
    required String patientId,
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/glucose/$patientId/agp-profile',
      queryParameters: {'from': from.toIso8601String(), 'to': to.toIso8601String()},
    );
    return response.data!.map((e) => AgpBucketResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<GlucoseReadingResponseDto?> getLatest({required String patientId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/glucose/$patientId/latest',
      options: Options(validateStatus: (status) => status == 200 || status == 204),
    );
    if (response.statusCode == 204 || response.data == null) return null;
    return GlucoseReadingResponseDto.fromJson(response.data!);
  }
}
