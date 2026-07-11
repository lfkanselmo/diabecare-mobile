import 'package:dio/dio.dart';

import 'caregiver_dtos.dart';

/// Llamadas HTTP a `/api/v1/caregivers/**` — contrato exacto de
/// `CaregiverController` del backend.
class CaregiverApiClient {
  CaregiverApiClient(this._dio);

  final Dio _dio;

  Future<CaregiverInviteResponseDto> createInvite(String patientId) async {
    final response = await _dio.post<Map<String, dynamic>>('/caregivers/$patientId/invites');
    return CaregiverInviteResponseDto.fromJson(response.data!);
  }

  Future<List<CaregiverLinkResponseDto>> getLinks(String patientId) async {
    final response = await _dio.get<List<dynamic>>('/caregivers/$patientId/links');
    return response.data!.map((e) => CaregiverLinkResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> revokeLink({required String patientId, required String linkId}) {
    return _dio.delete<void>('/caregivers/$patientId/links/$linkId');
  }

  Future<RedeemCaregiverInviteResponseDto> redeem(String code) async {
    final response = await _dio.post<Map<String, dynamic>>('/caregivers/redeem', data: {'code': code});
    return RedeemCaregiverInviteResponseDto.fromJson(response.data!);
  }

  Future<List<PatientAccessResponseDto>> getMyPatients() async {
    final response = await _dio.get<List<dynamic>>('/caregivers/my-patients');
    return response.data!.map((e) => PatientAccessResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }
}
