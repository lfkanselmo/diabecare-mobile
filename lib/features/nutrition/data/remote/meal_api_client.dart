import 'package:dio/dio.dart';

import 'meal_dtos.dart';

/// Llamadas HTTP a `/api/v1/nutrition/**` — contrato exacto de
/// `NutritionController` del backend.
class MealApiClient {
  MealApiClient(this._dio);

  final Dio _dio;

  Future<MealEntryResponseDto> register({
    required String patientId,
    required String mealType,
    required DateTime consumedAt,
    required List<MealItemDto> items,
    String? notes,
    String? mealId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/nutrition/$patientId/meals',
      data: {
        'mealType': mealType,
        'consumedAt': consumedAt.toIso8601String(),
        'notes': ?notes,
        'items': items.map((i) => i.toJson()).toList(),
        'mealId': ?mealId,
      },
    );
    return MealEntryResponseDto.fromJson(response.data!);
  }

  Future<List<MealEntryResponseDto>> sync({required String patientId, DateTime? since}) async {
    final response = await _dio.get<List<dynamic>>(
      '/nutrition/$patientId/meals/sync',
      queryParameters: {if (since != null) 'since': since.toIso8601String()},
    );
    return response.data!.map((e) => MealEntryResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DailySummaryResponseDto> getDailySummary({required String patientId, required DateTime date}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/nutrition/$patientId/summary',
      queryParameters: {'date': _dateOnly(date)},
    );
    return DailySummaryResponseDto.fromJson(response.data!);
  }

  String _dateOnly(DateTime date) => date.toIso8601String().split('T').first;
}
