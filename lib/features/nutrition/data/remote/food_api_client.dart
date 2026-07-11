import 'package:dio/dio.dart';

import 'food_dtos.dart';

/// Llamadas HTTP a `/api/v1/foods/**` y `/api/v1/food-lookup/**` — lecturas
/// de red puras, sin persistencia local.
class FoodApiClient {
  FoodApiClient(this._dio);

  final Dio _dio;

  Future<List<FoodResponseDto>> search(String query) async {
    final response = await _dio.get<List<dynamic>>('/foods/search', queryParameters: {'query': query});
    return response.data!.map((e) => FoodResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ExternalFoodResponseDto?> lookupByBarcode(String barcode) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/food-lookup/barcode/$barcode',
      options: Options(validateStatus: (status) => status == 200 || status == 404),
    );
    if (response.statusCode == 404 || response.data == null) return null;
    return ExternalFoodResponseDto.fromJson(response.data!);
  }
}
