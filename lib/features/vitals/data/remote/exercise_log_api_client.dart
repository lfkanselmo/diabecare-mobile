import 'package:dio/dio.dart';

import 'exercise_log_dtos.dart';

/// Llamadas HTTP a `/api/v1/exercise/**` — contrato exacto de
/// `ExerciseController` del backend.
class ExerciseLogApiClient {
  ExerciseLogApiClient(this._dio);

  final Dio _dio;

  Future<ExerciseLogResponseDto> register({
    required String patientId,
    required String exerciseType,
    required String intensity,
    required int durationMinutes,
    required DateTime performedAt,
    String? notes,
    double? caloriesBurned,
    String? exerciseId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/exercise/$patientId',
      data: {
        'exerciseType': exerciseType,
        'intensity': intensity,
        'durationMinutes': durationMinutes,
        'notes': ?notes,
        'performedAt': performedAt.toIso8601String(),
        'caloriesBurned': ?caloriesBurned,
        'exerciseId': ?exerciseId,
      },
    );
    return ExerciseLogResponseDto.fromJson(response.data!);
  }

  Future<List<ExerciseLogResponseDto>> sync({required String patientId, DateTime? since}) async {
    final response = await _dio.get<List<dynamic>>(
      '/exercise/$patientId/sync',
      queryParameters: {if (since != null) 'since': since.toIso8601String()},
    );
    return response.data!.map((e) => ExerciseLogResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }
}
