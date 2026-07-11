import 'package:dio/dio.dart';

import 'device_api_key_dtos.dart';

/// Llamadas HTTP a `/api/v1/device-keys/**` — contrato exacto de
/// `DeviceApiKeyController` del backend.
class DeviceApiKeyApiClient {
  DeviceApiKeyApiClient(this._dio);

  final Dio _dio;

  Future<GeneratedDeviceApiKeyResponseDto> generate({required String patientId, required String label}) async {
    final response = await _dio.post<Map<String, dynamic>>('/device-keys/$patientId', data: {'label': label});
    return GeneratedDeviceApiKeyResponseDto.fromJson(response.data!);
  }

  Future<List<DeviceApiKeyResponseDto>> list(String patientId) async {
    final response = await _dio.get<List<dynamic>>('/device-keys/$patientId');
    return response.data!.map((e) => DeviceApiKeyResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> revoke({required String patientId, required String keyId}) {
    return _dio.delete<void>('/device-keys/$patientId/$keyId');
  }
}
