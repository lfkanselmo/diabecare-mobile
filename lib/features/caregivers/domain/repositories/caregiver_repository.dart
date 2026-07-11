import '../entities/caregiver_invite.dart';
import '../entities/caregiver_link.dart';

/// Dominio 100% online, sin persistencia local ni sync — invitaciones/links
/// se resuelven siempre contra el servidor.
abstract interface class CaregiverRepository {
  Future<CaregiverInvite> createInvite();

  Future<List<CaregiverLink>> getLinks();

  Future<void> revokeLink(String linkId);

  Future<RedeemCaregiverInviteResult> redeem(String code);

  Future<List<PatientAccess>> getMyPatients();
}
