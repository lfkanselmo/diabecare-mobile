import 'package:dio/dio.dart';

import 'menstrual_cycle_dtos.dart';

/// Llamadas HTTP a `/api/v1/menstrual-cycle/**` — contrato exacto de
/// `MenstrualCycleController` del backend. Sin persistencia local ni
/// sync — todo se calcula server-side (mismo patrón que stats/AGP).
class MenstrualCycleApiClient {
  MenstrualCycleApiClient(this._dio);

  final Dio _dio;

  Future<MenstrualCycleStatusResponseDto> register({
    required String patientId,
    required DateTime startDate,
    String? notes,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/menstrual-cycle/$patientId',
      data: {'startDate': _dateOnly(startDate), 'notes': ?notes},
    );
    return MenstrualCycleStatusResponseDto.fromJson(response.data!);
  }

  Future<MenstrualCycleStatusResponseDto> finishPeriod({required String patientId, required DateTime endDate}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/menstrual-cycle/$patientId/finish-period',
      data: {'endDate': _dateOnly(endDate)},
    );
    return MenstrualCycleStatusResponseDto.fromJson(response.data!);
  }

  Future<CycleDayEntryResponseDto> registerDayEntry({
    required String patientId,
    required DateTime entryDate,
    required String flowIntensity,
    String? notes,
    required List<({String symptom, String severity})> symptoms,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/menstrual-cycle/$patientId/days',
      data: {
        'entryDate': _dateOnly(entryDate),
        'flowIntensity': flowIntensity,
        'notes': ?notes,
        'symptoms': symptoms.map((s) => {'symptom': s.symptom, 'severity': s.severity}).toList(),
      },
    );
    return CycleDayEntryResponseDto.fromJson(response.data!);
  }

  Future<MenstrualCycleStatusResponseDto> getStatus({required String patientId}) async {
    final response = await _dio.get<Map<String, dynamic>>('/menstrual-cycle/$patientId/status');
    return MenstrualCycleStatusResponseDto.fromJson(response.data!);
  }

  Future<List<CyclePhaseDayResponseDto>> getPhaseCalendar({
    required String patientId,
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/menstrual-cycle/$patientId/phase-calendar',
      queryParameters: {'from': _dateOnly(from), 'to': _dateOnly(to)},
    );
    return response.data!.map((e) => CyclePhaseDayResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  String _dateOnly(DateTime date) => date.toIso8601String().split('T').first;
}
