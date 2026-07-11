import 'package:dio/dio.dart';

/// Llamada HTTP a `/api/v1/reports/{patientId}/medical` — contrato exacto de
/// `ReportController`. Devuelve el PDF como bytes crudos.
class ReportApiClient {
  ReportApiClient(this._dio);

  final Dio _dio;

  Future<List<int>> generateMedicalReport({
    required String patientId,
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _dio.get<List<int>>(
      '/reports/$patientId/medical',
      queryParameters: {'from': _dateOnly(from), 'to': _dateOnly(to)},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }

  String _dateOnly(DateTime date) => date.toIso8601String().split('T').first;
}
