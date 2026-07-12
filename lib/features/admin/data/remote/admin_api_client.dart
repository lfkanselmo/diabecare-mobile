import 'package:dio/dio.dart';

import 'admin_dtos.dart';

/// Llamadas HTTP a `/api/v1/admin/**` y `POST /system-config/reload` —
/// contrato exacto de `AdminController`/`SystemConfigController`. El
/// backend ya protege ambos con `@PreAuthorize("hasRole('ADMIN')")`.
class AdminApiClient {
  AdminApiClient(this._dio);

  final Dio _dio;

  Future<AdminUserPageResponseDto> getUsers({int page = 0, int size = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/users',
      queryParameters: {'page': page, 'size': size},
    );
    return AdminUserPageResponseDto.fromJson(response.data!);
  }

  Future<void> changeUserRole({required String userId, required String role}) {
    return _dio.patch<void>('/admin/users/$userId/role', data: {'role': role});
  }

  Future<void> reloadSystemConfig() {
    return _dio.post<void>('/system-config/reload');
  }
}
