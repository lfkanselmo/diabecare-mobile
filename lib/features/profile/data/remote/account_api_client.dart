import 'package:dio/dio.dart';

/// Llamadas HTTP a `/api/v1/account/**` — contrato exacto de
/// `AccountController` del backend.
class AccountApiClient {
  AccountApiClient(this._dio);

  final Dio _dio;

  Future<void> suspend(String userId) {
    return _dio.patch<void>('/account/$userId/suspend');
  }

  Future<void> delete(String userId) {
    return _dio.delete<void>('/account/$userId');
  }

  Future<List<int>> exportData(String userId) async {
    final response = await _dio.get<List<int>>(
      '/account/$userId/export',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }
}
