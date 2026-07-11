import 'package:dio/dio.dart';

import 'medication_dtos.dart';

/// Llamadas HTTP a `/api/v1/medications/**`, `/api/v1/insulin/**` y
/// `PATCH /patients/{patientId}/insulin-profile` — contrato exacto de
/// `MedicationController`/`InsulinController`/`PatientController`.
class MedicationApiClient {
  MedicationApiClient(this._dio);

  final Dio _dio;

  Future<MedicationResponseDto> register({
    required String patientId,
    required String name,
    required String type,
    required double dose,
    required String doseUnit,
    required String frequency,
    DateTime? startDate,
    String? notes,
    String? medicationId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/medications/$patientId',
      data: {
        'name': name,
        'type': type,
        'dose': dose,
        'doseUnit': doseUnit,
        'frequency': frequency,
        'startDate': ?startDate?.toIso8601String().split('T').first,
        'notes': ?notes,
        'medicationId': ?medicationId,
      },
    );
    return MedicationResponseDto.fromJson(response.data!);
  }

  Future<List<MedicationResponseDto>> sync({required String patientId, DateTime? since}) async {
    final response = await _dio.get<List<dynamic>>(
      '/medications/$patientId/sync',
      queryParameters: {if (since != null) 'since': since.toIso8601String()},
    );
    return response.data!.map((e) => MedicationResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> deactivate({required String patientId, required String medicationId}) {
    return _dio.delete<void>('/medications/$patientId/$medicationId');
  }

  Future<InsulinCalculationResponseDto> calculate({
    required String patientId,
    required double currentGlucose,
    double? carbsToEat,
    required bool beforeMeal,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/insulin/$patientId/calculate',
      data: {'currentGlucose': currentGlucose, 'carbsToEat': ?carbsToEat, 'beforeMeal': beforeMeal},
    );
    return InsulinCalculationResponseDto.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> updateInsulinProfile({
    required String patientId,
    required double sensitivityFactor,
    required double carbRatio,
    required double targetGlucose,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/patients/$patientId/insulin-profile',
      data: {'sensitivityFactor': sensitivityFactor, 'carbRatio': carbRatio, 'targetGlucose': targetGlucose},
    );
    return response.data!;
  }
}
