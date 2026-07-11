import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/caregiver_invite.dart';
import '../../domain/entities/caregiver_link.dart';
import '../../domain/repositories/caregiver_repository.dart';
import '../remote/caregiver_api_client.dart';

class CaregiverRepositoryImpl implements CaregiverRepository {
  CaregiverRepositoryImpl({required CaregiverApiClient apiClient, required AuthRepository authRepository})
    : _apiClient = apiClient,
      _authRepository = authRepository;

  final CaregiverApiClient _apiClient;
  final AuthRepository _authRepository;

  @override
  Future<CaregiverInvite> createInvite() async {
    final patientId = await _requirePatientId();
    final dto = await _apiClient.createInvite(patientId);
    return CaregiverInvite(code: dto.code, expiresAt: dto.expiresAt);
  }

  @override
  Future<List<CaregiverLink>> getLinks() async {
    final patientId = await _requirePatientId();
    final links = await _apiClient.getLinks(patientId);
    return links
        .map(
          (l) => CaregiverLink(
            linkId: l.linkId,
            caregiverUserId: l.caregiverUserId,
            caregiverName: l.caregiverName,
            caregiverEmail: l.caregiverEmail,
            linkedAt: l.linkedAt,
          ),
        )
        .toList();
  }

  @override
  Future<void> revokeLink(String linkId) async {
    final patientId = await _requirePatientId();
    await _apiClient.revokeLink(patientId: patientId, linkId: linkId);
  }

  @override
  Future<RedeemCaregiverInviteResult> redeem(String code) async {
    final dto = await _apiClient.redeem(code);
    return RedeemCaregiverInviteResult(patientId: dto.patientId, patientFullName: dto.patientFullName);
  }

  @override
  Future<List<PatientAccess>> getMyPatients() async {
    final patients = await _apiClient.getMyPatients();
    return patients
        .map((p) => PatientAccess(patientId: p.patientId, patientFullName: p.patientFullName, linkedAt: p.linkedAt))
        .toList();
  }

  Future<String> _requirePatientId() async {
    final session = await _authRepository.loadSession();
    final patientId = session?.patient?.patientId;
    if (patientId == null) {
      throw StateError('No hay un paciente asociado a la sesión actual');
    }
    return patientId;
  }
}
