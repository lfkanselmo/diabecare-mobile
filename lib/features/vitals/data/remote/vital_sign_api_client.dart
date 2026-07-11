import 'package:dio/dio.dart';

import 'vital_sign_dtos.dart';

/// Llamadas HTTP a `/api/v1/vitals/**` — contrato exacto de
/// `VitalSignController` del backend.
class VitalSignApiClient {
  VitalSignApiClient(this._dio);

  final Dio _dio;

  Future<VitalSignResponseDto> register({
    required String patientId,
    double? weightKg,
    double? heightCm,
    int? systolicBp,
    int? diastolicBp,
    int? heartRate,
    double? hba1c,
    required DateTime measuredAt,
    String? notes,
    String? vitalId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/vitals/$patientId',
      data: {
        'weightKg': ?weightKg,
        'heightCm': ?heightCm,
        'systolicBp': ?systolicBp,
        'diastolicBp': ?diastolicBp,
        'heartRate': ?heartRate,
        'hba1c': ?hba1c,
        'measuredAt': measuredAt.toIso8601String(),
        'notes': ?notes,
        'vitalId': ?vitalId,
      },
    );
    return VitalSignResponseDto.fromJson(response.data!);
  }

  Future<List<VitalSignResponseDto>> sync({required String patientId, DateTime? since}) async {
    final response = await _dio.get<List<dynamic>>(
      '/vitals/$patientId/sync',
      queryParameters: {if (since != null) 'since': since.toIso8601String()},
    );
    return response.data!.map((e) => VitalSignResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<VitalSignResponseDto?> getLatest({required String patientId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/vitals/$patientId/latest',
      options: Options(validateStatus: (status) => status == 200 || status == 204),
    );
    if (response.statusCode == 204 || response.data == null) return null;
    return VitalSignResponseDto.fromJson(response.data!);
  }

  Future<List<Hba1cTrendResponseDto>> getHba1cTrend({required String patientId, int months = 6}) async {
    final response = await _dio.get<List<dynamic>>(
      '/vitals/$patientId/hba1c-trend',
      queryParameters: {'months': months},
    );
    return response.data!.map((e) => Hba1cTrendResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }
}
